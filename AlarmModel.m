//
//  AlarmModel.m
//  GPSAlarm
//
//  Created by Chris Hughes on 03/09/2009.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <AudioToolbox/AudioToolbox.h>
#import <CoreLocation/CoreLocation.h>
#import <MapKit/MapKit.h>

#import "AlarmModel.h"

#import "MapViewAdditions.h"
#import "LocationController.h"
#import "DistanceModel.h"
#import "RingtoneModel.h"

@implementation AlarmModel

@synthesize pinArray, alarmTimer;


- (AlarmModel *)init {
	if ((self = [super init])) {
		self.alarmTimer = nil;
		
		if ([self loadState] == NO)
			pinArray = [[NSMutableArray alloc] init];
	}
	return self;
}

#pragma mark SINGLETON

+ (id)sharedInstance {
    static dispatch_once_t pred;
    static AlarmModel *sharedInstance = nil;
    dispatch_once(&pred, ^{
        sharedInstance = [[AlarmModel alloc] init];
    });
    return sharedInstance;
}

- (void)dealloc {
    abort();
}

#pragma mark --  Manage state 

+ (NSString *)getPathToStateDB {
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *documentsDirectory = [paths objectAtIndex:0];
	NSString *stateFile = [documentsDirectory stringByAppendingPathComponent:@"AlarmModel.state"];
	return stateFile;
}

- (BOOL)loadState {
	NSString *stateDBFile = [AlarmModel getPathToStateDB];
    NSFileManager *const fileManager = [NSFileManager defaultManager];		
	const BOOL exists = [fileManager fileExistsAtPath:stateDBFile];
	if (exists == NO)
		return NO;
	
	NSMutableArray *stateArray = [NSKeyedUnarchiver unarchiveObjectWithFile:stateDBFile];
	if (stateArray == nil)
		return NO;
	self.pinArray = stateArray;
	return YES;
}

- (void)saveState {
	/*
	 NSFileManager *fileManager = [NSFileManager defaultManager];			
	 BOOL fileExists = [fileManager fileExistsAtPath:stateDBFile];
	 if (fileExists)
	 [fileManager removeItemAtPath:stateDBFile error:nil];			
	 return;
	 }
	 */
    
    // When we save our state to persistent storage, disable any active alarms
    // This is just to stop alarms firing annoyingly on application startup
/*    NSArray *tmpArray = [NSArray arrayWithArray:pinArray];
    for (LocationPin *pin in tmpArray) {
        pin.alarmOn = NO;
    }
 */
    
	NSString *filename = [AlarmModel getPathToStateDB];
	if ([NSKeyedArchiver archiveRootObject:pinArray toFile:filename] != YES) {
		NSAssert(0, @"NSKeyedArchiver failed\n");
	}
}

#pragma mark NSCoding

-(id)initWithCoder: (NSCoder *) coder {
	if (self = [super init])
	{
		self.pinArray = [coder decodeObject];
	}
	return self;
}

- (void)encodeWithCoder:(NSCoder *)coder {
	[coder encodeObject:pinArray];
}

#pragma mark Alarm Model

- (BOOL)alarmIsOn {
	if ([self destinationPin] == nil) 
		return NO;
	return YES;
}

- (void)alarmOn:(BOOL)isOn withIndex:(NSInteger)index {
    DLog(@"alarmOn: %d index: %d", isOn, index);
	for (NSInteger pinIndex = 0 ; pinIndex < [pinArray count] ; pinIndex++) {
		LocationPin *pin = [pinArray objectAtIndex:pinIndex];
		if (pinIndex == index) {
			pin.alarmOn = isOn;
		} else {
			pin.alarmOn = NO;
		}
	}
	if (isOn == YES) {
        [[LocationController sharedInstance] startUpdates];
        [[UIApplication sharedApplication] cancelAllLocalNotifications];        // Cancel all outstanding notifications
		[self checkAlarm];
    }
}

- (LocationPin *)destinationPin {
	for (LocationPin *pin in pinArray) {
		if (pin.alarmOn == YES)
			return pin;
	}
	return nil;
}

#pragma mark -- handle alarm firing --

// Fire off a second vibration
- (void)alarmTimerFired:(NSTimer *)timer {
    [timer invalidate];
	self.alarmTimer = nil;

	[self vibrateDevice];
}

- (void)fireAlarm {
    DLog(@"AlarmModel - fireAlarm()");
    
	LocationPin *destPin = [self destinationPin];
	RingtoneModel *rm = [RingtoneModel sharedInstance];
    UIApplication *app = [UIApplication sharedApplication];
    
    UIApplicationState appState = [app applicationState];
    
    // If the application is currently active, fire alarm 
    // Otherwise fire a local notification
    if (appState == UIApplicationStateActive) {
        DLog(@"App is active");
        [rm loadRingtone:[destPin ringtoneTitle]];
        [rm startRingtone];
        
        // Vibrate the device once now and in 3 seconds
        [self vibrateDevice];
        self.alarmTimer = [NSTimer scheduledTimerWithTimeInterval:3.0f target:self selector:@selector(alarmTimerFired:) userInfo:nil repeats:NO];
        
        [self raiseAlarmAlertViewWithTitle:[destPin title]];
    } else {
        DLog(@"App is NOT active");

        NSString *soundName = UILocalNotificationDefaultSoundName;
        if ([destPin ringtoneTitle] != nil) {
            soundName = [rm pathForMP4:[destPin ringtoneTitle]];
        }
        DLog(@"Alarm: %@", soundName);
        
        UILocalNotification *notification = [[UILocalNotification alloc] init];
        notification.fireDate = nil;
        notification.timeZone = [NSTimeZone defaultTimeZone];
        notification.repeatInterval = 0;
        notification.repeatCalendar = [NSCalendar currentCalendar];
        notification.soundName = soundName; // UILocalNotificationDefaultSoundName; // @"";
        notification.alertBody = destPin.title;
        notification.userInfo = [NSDictionary dictionaryWithObject:[destPin ringtoneTitle] forKey:@"ringtoneTitle"];
        
        [app presentLocalNotificationNow:notification];
    }
    
    // Turn off the alarm
    destPin.alarmOn = NO;
}

- (void)quenchAlarm {
	// Kill the alarm repeat timer
	[self.alarmTimer invalidate];
	self.alarmTimer = nil;
	
	// Stop ringtone
	RingtoneModel *rm = [RingtoneModel sharedInstance];
	[rm stopRingtone];
}

#ifdef DEBUG_DELAY_ALARM_FIRE

static NSTimer *_alarmTimer = nil;

- (void)debugFireAlarm:(NSTimer *)timer {
	[self fireAlarm];
	_alarmTimer = nil;
}

#endif

- (void)checkAlarm {
	LocationPin *destPin = [self destinationPin];
	if (destPin == nil)
		return;
	LocationController *lc = [LocationController sharedInstance];
	if ([lc hasUserLocation] == NO)
		return;

	NSInteger proximity = [DistanceModel getMetresForType:[destPin distanceType]];
	CLLocationDistance distance = [MKMapView distanceFromCoordinate:[lc currentCoordinate] toCoordinate:[destPin coordinate]];
	DLog(@"AlarmModel - checkAlarm() - Distance is %f (proximity is %d)", distance, proximity);
	
	// Configure the LocationController accuracy depending on how far we are from the destination
	[lc setAccuracyForDistance:distance];
	
	if (distance < proximity) {
#ifdef DEBUG_DELAY_ALARM_FIRE
		if (_alarmTimer != nil) 
			return;
		_alarmTimer = [NSTimer scheduledTimerWithTimeInterval:5.0f target:self selector:@selector(debugFireAlarm:) userInfo:nil repeats:NO];
#else
		[self fireAlarm];
#endif
	}
}

#pragma mark -- Device handling

// Vibrate the device for a short period of time
// If vibration is not supported, this will just be ignored
- (void)vibrateDevice {
	AudioServicesPlaySystemSound (kSystemSoundID_Vibrate);
}

#pragma mark AlertView

#pragma mark -- Handle alert views --

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
	[self quenchAlarm];
}

- (void)raiseAlarmAlertViewWithTitle:(NSString *)message {
	NSString *titleString = NSLocalizedString(@"AlarmTitle", @"Alarm!");
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:titleString
													message:message delegate:self cancelButtonTitle:@"OK"
                                                        otherButtonTitles:nil];
	[alert show];
}

@end
