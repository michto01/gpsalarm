//
//  LocationController.m
//  GPSAlarm
//
//  Created by Chris Hughes on 28/08/2009.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "LocationController.h"

#import "DistanceModel.h"
#import "AlarmModel.h"

@implementation LocationController

@synthesize locationManager, currentCoordinate, delegate, hasUserLocation, lastError, lastErrorDate;
@synthesize currentAccuracy, regionMonitoringAvailable;

#pragma mark --

- (id) init {
	self = [super init];
	if (self != nil) {
		self.hasUserLocation = NO;

//		self.errorAlertView = nil;
		self.lastError = nil;
		self.lastErrorDate = nil;
//		self.errorTimer = nil;
        
		self.locationManager = [[CLLocationManager alloc] init];
		locationManager.delegate = self; // Tells the location manager to send updates to this object
		[self setAccuracyForDistance:2000.0f];

        self.regionMonitoringAvailable = [CLLocationManager regionMonitoringAvailable];
        DLog(@"Region Monitoring Available: %d", [self isRegionMonitoringAvailable]);

#ifdef DEBUG_SIMULATE_ERRORS
		DLog(@"DEBUG_SIMULATE_ERRORS - Starting to simulate errors in Location Controller");
		[self simulateErrors];
#endif
	}
	return self;
}

#pragma mark ERROR SIMULATION

#ifdef DEBUG_SIMULATE_ERRORS

- (void)simulateErrorCallback:(NSTimer *)timer {
	DLog(@"Injecting error");
	NSError *myError = [NSError errorWithDomain:kCLErrorDomain code:kCLErrorLocationUnknown userInfo:nil];
	[self locationManager:[self locationManager] didFailWithError:myError];
	
	CGFloat r = 240 + random() % 60;
	[NSTimer scheduledTimerWithTimeInterval:r target:self selector:@selector(simulateErrorCallback:) userInfo:nil repeats:NO];	
}

- (void)simulateErrors {
	[self simulateErrorCallback:nil];
}

#endif

#pragma mark SINGLETON

+ (id)sharedInstance {
    static dispatch_once_t pred;
    static LocationController *sharedInstance = nil;
    dispatch_once(&pred, ^{
        sharedInstance = [[LocationController alloc] init];
    });
    return sharedInstance;
}

- (void)dealloc {
    abort();
}

#pragma mark -- CLLocationManager Delegate

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation {
	DLog(@"%@", newLocation);
	// Horizontal coordinates
	if (signbit(newLocation.horizontalAccuracy)) {
		// Negative accuracy means an invalid or unavailable measurement
	} else {
		// If this is the first update, turn off further updates (until more are requested)
		self.lastError = nil;
		self.lastErrorDate = nil;
		self.hasUserLocation = YES;
		self.currentCoordinate = newLocation.coordinate;
		if ([self delegate] != nil)
			[self.delegate currentLocationUpdate:currentCoordinate];
/*		if ([self errorTimer] != nil) {
			[self.errorTimer invalidate];
			self.errorTimer = nil;
		}
 */
		// CoreLocation returns positive for North & East, negative for South & West
/*		[update appendFormat:LocStr(@"LatLongFormat"), // This format takes 4 args: 2 pairs of the form coordinate + compass direction
		 fabs(newLocation.coordinate.latitude), signbit(newLocation.coordinate.latitude) ? LocStr(@"South") : LocStr(@"North"),
		 fabs(newLocation.coordinate.longitude),	signbit(newLocation.coordinate.longitude) ? LocStr(@"West") : LocStr(@"East")];
		[update appendString:@"\n"];
		[update appendFormat:LocStr(@"MeterAccuracyFormat"), newLocation.horizontalAccuracy]; */
	}

	// Calculate disatance moved and time elapsed, but only if we have an "old" location
	//
	// NOTE: Timestamps are based on when queries start, not when they return. CoreLocation will query your
	// location based on several methods. Sometimes, queries can come back in a different order from which
	// they were placed, which means the timestamp on the "old" location can sometimes be newer than on the
	// "new" location. For the example, we will clamp the timeElapsed to zero to avoid showing negative times
	// in the UI.
	//
/*	if (oldLocation != nil) {
		CLLocationDistance distanceMoved = [newLocation getDistanceFrom:oldLocation];
		NSTimeInterval timeElapsed = [newLocation.timestamp timeIntervalSinceDate:oldLocation.timestamp];
		
		[update appendFormat:LocStr(@"LocationChangedFormat"), distanceMoved];
		if (signbit(timeElapsed)) {
			[update appendString:LocStr(@"FromPreviousMeasurement")];
		} else {
			[update appendFormat:LocStr(@"TimeElapsedFormat"), timeElapsed];
		}
		[update appendString:@"\n\n"];
	}
*/	
}

// Called when there is an error getting the location
- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
//	DLog(@"Got error: %@", error);
	
	NSString *errorString = nil;
	if ([error domain] == kCLErrorDomain) {
		switch ([error code]) {
				// This error code is usually returned whenever user taps "Don't Allow" in response to
				// being told your app wants to access the current location. Once this happens, you cannot
				// attempt to get the location again until the app has quit and relaunched.
				//
				// "Don't Allow" on two successive app launches is the same as saying "never allow". The user
				// can reset this for all apps by going to Settings > General > Reset > Reset Location Warnings.
				//
			case kCLErrorDenied:
				errorString = NSLocalizedString(@"User denied use of location services!", @"LocationControllerUserDenied");
				[self raiseAlertView];
				break;
				
				// This error code is usually returned whenever the device has no data or WiFi connectivity,
				// or when the location cannot be determined for some other reason.
				//
				// CoreLocation will keep trying, so you can keep waiting, or prompt the user.
				//
			case kCLErrorLocationUnknown:
				errorString = NSLocalizedString(@"Unable to find location!", @"LocationControllerError");
				break;
				
				// We shouldn't ever get an unknown error code, but just in case...
				//
			default:
				errorString = NSLocalizedString(@"Unknown error!", @"LocationControllerUnknownError");
				break;
		}
	} else {
		errorString = [error localizedDescription];
	}
	
	// Send the update to our delegate
	self.hasUserLocation = NO;
	if ([self delegate] != nil)
		[self.delegate errorUpdate:errorString];
	self.lastError = errorString;
	self.lastErrorDate = [NSDate date];
}

#pragma mark AlertView

- (void)raiseAlertView {
	NSString *msg = NSLocalizedString(@"Cannot work without location services!  Please enable and re-run application.", @"LocationControllerUserDeniedMessage");
	NSString *titleString = NSLocalizedString(@"Error", @"Location Controller Alert View title 'Error'");
	// Only display a new alert if we don't already have one
	UIAlertView *errorAlertView = [[UIAlertView alloc] initWithTitle:titleString message:msg delegate:nil 
										  cancelButtonTitle:@"OK" otherButtonTitles:nil];
	[errorAlertView show];
}

#pragma mark --

- (void)setAccuracyForDistance:(CLLocationDistance)distance {
	LCAccuracy newAccuracy;
	
	if (distance > 1000) { // 1km+
		newAccuracy = LCAccuracyFar;
	} else if (distance > 100) { // 100m+
		newAccuracy = LCAccuracyMedium;
	} else { // 0-200m
		newAccuracy = LCAccuracyNear;
	}
	
    DLog(@"AlarmModel - setAccuracyForDistance(distance=%f, current=%d, new=%d", distance, 
          currentAccuracy, newAccuracy);
	if (newAccuracy == currentAccuracy && currentAccuracy != LCAccuracyNotSet)
		return;
	currentAccuracy = newAccuracy;
	
	switch (newAccuracy) {
		case LCAccuracyFar:
			locationManager.desiredAccuracy = kCLLocationAccuracyKilometer;
			locationManager.distanceFilter = 100.0f;   // 50 metres
			break;
		case LCAccuracyMedium:
			locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters;
			locationManager.distanceFilter = 50.0f;    // 25 metres
			break;
		case LCAccuracyNear:
			locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters;
			locationManager.distanceFilter = 10.0f;	   // 5 metres	
			break;
        case LCAccuracyNotSet:
            break;
	}
}

- (void)startUpdates {
    DLog(@"start Updates");
	[locationManager startUpdatingLocation];

    LocationPin *destPin = [[AlarmModel sharedInstance] destinationPin];
    if (destPin) {
        [locationManager startMonitoringSignificantLocationChanges];
        [self startMonitoringForRegion:destPin];
    }
}

- (void)stopUpdates {
    DLog(@"stop Updates");
	[locationManager stopUpdatingLocation];
    [locationManager stopMonitoringSignificantLocationChanges];
    [self stopMonitoringForRegions];
}

#pragma mark Region Monitoring

- (void)startMonitoringForRegion:(LocationPin *)pin {
    if ([self isRegionMonitoringAvailable] == NO)
        return;
    
    CLLocationDistance radius = [DistanceModel getMetresForType:[pin distanceType]];
    
    if (radius > [self.locationManager maximumRegionMonitoringDistance])
        radius = [self.locationManager maximumRegionMonitoringDistance];
    
    CLRegion *region = [[CLRegion alloc] initCircularRegionWithCenter:[pin coordinate] radius:radius identifier:@"DestinationPin"];
//    [self.locationManager startMonitoringForRegion:region desiredAccuracy:];
    [self.locationManager startMonitoringForRegion:region];
}

- (void)stopMonitoringForRegions {
    // Could probably remove our region by passing something like
    //    CLRegion region = [[CLRegion alloc] initCircularRegionWithCenter:CLLocationCoordinate2DMake(0, 0) radius:0 identifier:@"DestinationPin"];
    // but to be 'safe'
    
    for (CLRegion *region in [self.locationManager monitoredRegions]) {
        [self.locationManager stopMonitoringForRegion:region];
    }
}

- (void)locationManager:(CLLocationManager *)manager didEnterRegion:(CLRegion *)region {
    DLog(@"Region: %@", region);
}

- (void)locationManager:(CLLocationManager *)manager didExitRegion:(CLRegion *)region {
    DLog(@"Region: %@", region);    
}

- (void)locationManager:(CLLocationManager *)manager monitoringDidFailForRegion:(CLRegion *)region withError:(NSError *)error {
    DLog(@"region: %@ - error: %@", region, error);
    
}

@end