//
//  GPSAlarmAppDelegate.m
//  GPSAlarm
//
//  Created by Chris Hughes on 25/08/2009.
//  Copyright __MyCompanyName__ 2009. All rights reserved.
//

#import "GPSAlarmAppDelegate.h"
#import "AlarmViewController.h"
#import "SecondViewController.h"
#import "AlarmModel.h"
#import "DistanceModel.h"
#import "LocationController.h"

#import <AudioToolbox/AudioToolbox.h>

@implementation GPSAlarmAppDelegate

@synthesize window, tabBarController, alarmViewController, secondViewController;


- (void)applicationDidBecomeActive:(UIApplication *)application {
	DLog(@"Become active");
    LocationController *lc = [LocationController sharedInstance];
    [lc startUpdates];
}

- (void)applicationWillResignActive:(UIApplication *)application {
	DLog(@"willresignactive");
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    DLog(@"didenterbackground");
    
    AlarmModel *am = [AlarmModel sharedInstance];
    LocationPin *destPin = [am destinationPin];
    if (destPin == nil) {  // No current destination, so we stop Location updates
        LocationController *lc = [LocationController sharedInstance];
        [lc stopUpdates];
    }

    [[AlarmModel sharedInstance] saveState];
}

/*
- (void)applicationWillEnterForeground:(UIApplication *)application {
    DLog(@"will enter foreground");
}*/

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
// - (void)applicationDidFinishLaunching:(UIApplication *)application {
    DLog(@"");
    // Add the tab bar controller's current view as a subview of the window
    [window addSubview:tabBarController.view];

	// Load userdefaults (units to be used)
	NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
	DistanceUnits units = [userDefaults integerForKey:@"distanceUnitsPref"];
	[DistanceModel setDistanceUnits:units];
    
    // Clear any previous notifications
    [[UIApplication sharedApplication] cancelAllLocalNotifications];
    
    if (launchOptions != nil)
        DLog(@"launchOptions: %@", launchOptions); // UIApplicationLaunchOptionsLocationKey
    
    return YES;
}

- (void)applicationWillTerminate:(UIApplication *)application {
    DLog(@"WillTerminate");
	// Save our current state (list of bookmarks and any alarm currently on)
	[[AlarmModel sharedInstance] saveState];
}

//
// We only send a local notification on firing the alarm
// If the application is in the foreground, this gets called - so we process a local alarm
// This also gets called if the user responds to the local notification while the app isn't active
//
- (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification {
    DLog(@"Application didReceiveLocalNotification - %@", [notification alertBody]);

//    NSString *ringtoneTitle = [[notification userInfo] objectForKey:@"ringtoneTitle"];
//    AlarmModel *am = [AlarmModel sharedInstance];
//    [am fireLocalAlarmWithTitle:[notification alertBody] withRingtoneTitle:ringtoneTitle];
}

/*
// Optional UITabBarControllerDelegate method
- (void)tabBarController:(UITabBarController *)tabBarController didSelectViewController:(UIViewController *)viewController {
}
*/


#pragma mark ---


@end

#ifdef DEBUG

void CHLog(NSString *format, ...) {
    static NSString *fileName = nil;
    va_list args;
    va_start(args, format);
    NSString *contents = [[NSString alloc] initWithFormat:format arguments:args];
    va_end(args);

    NSLog(@"%@", contents);

    if (!fileName) {
        NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
        dateFormat.locale = [NSLocale currentLocale];
        dateFormat.timeZone = [NSTimeZone localTimeZone];
        dateFormat.timeStyle = NSDateFormatterShortStyle;
        dateFormat.dateStyle = NSDateFormatterNoStyle;
        dateFormat.locale = [NSLocale currentLocale];
        NSString *file = [NSString stringWithFormat:@"runlog-%@.txt", [dateFormat stringFromDate:[NSDate date]]];
        
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentsDirectory = [paths objectAtIndex:0];
        fileName = [documentsDirectory stringByAppendingPathComponent:file];

        NSFileManager *fileManager = [NSFileManager defaultManager];
        [fileManager createFileAtPath:fileName contents:nil attributes:nil];
    }
    
    NSFileHandle *fileHandle = [NSFileHandle fileHandleForUpdatingAtPath:fileName];
    [fileHandle writeData:[contents dataUsingEncoding:NSUTF8StringEncoding]];
}

#endif

