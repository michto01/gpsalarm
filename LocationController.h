//
//  LocationController.h
//  GPSAlarm
//
//  Created by Chris Hughes on 28/08/2009.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>
#import <CoreLocation/CoreLocation.h>

@protocol LocationControllerDelegate <NSObject> 

@required
- (void)currentLocationUpdate:(CLLocationCoordinate2D)coordinate;
- (void)errorUpdate:(NSString *)errorString;
@end

typedef enum _LCAccuracy {
	LCAccuracyNear = 0,
	LCAccuracyMedium,
	LCAccuracyFar,
	LCAccuracyNotSet
} LCAccuracy;

@interface LocationController : NSObject <CLLocationManagerDelegate>

@property (nonatomic, strong) CLLocationManager *locationManager;
@property (nonatomic, assign) CLLocationCoordinate2D currentCoordinate;
@property (nonatomic, unsafe_unretained) id<LocationControllerDelegate> delegate;
@property (nonatomic, assign) BOOL hasUserLocation;  // Whether we have a valid user location
@property (nonatomic, strong) NSString *lastError;
@property (nonatomic, strong) NSDate *lastErrorDate;
// @property (nonatomic, retain) NSTimer *errorTimer;
@property (nonatomic, assign) LCAccuracy currentAccuracy;
//@property (nonatomic, retain) UIAlertView *errorAlertView;
@property (nonatomic, getter=isRegionMonitoringAvailable) BOOL regionMonitoringAvailable;

// public
+ (LocationController *)sharedInstance;

- (void)setAccuracyForDistance:(CLLocationDistance)distance;
- (void)startUpdates;
- (void)stopUpdates;

// private
- (void)raiseAlertView;
// - (void)errorTimerFired:(NSTimer*)theTimer;

#ifdef DEBUG_SIMULATE_ERRORS
- (void)simulateErrors;
#endif

@end
