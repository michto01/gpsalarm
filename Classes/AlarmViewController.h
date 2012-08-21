//
//  AlarmViewController.h
//  GPSAlarm
//
//  Created by Chris Hughes on 25/08/2009.
//  Copyright __MyCompanyName__ 2009. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import "LocationController.h"

#ifdef DEBUG
#import <iAd/iAd.h>
#endif

@class LocationProximity, AlarmModel;

@interface AlarmViewController : UIViewController <LocationControllerDelegate, MKMapViewDelegate, UIAlertViewDelegate, ADBannerViewDelegate> {


@private
//	LocationPin *destinationAnnotationPin;
//	LocationProximity *destinationProximity;
//	BOOL userMovedMap;   // Has the user moved the map onscreen?
}

@property (nonatomic, weak) IBOutlet UIView *labelsView;
@property (nonatomic, weak) IBOutlet UILabel *distanceToDestinationLabel;
@property (nonatomic, weak) IBOutlet UILabel *destinationLabel;
@property (nonatomic, weak) IBOutlet UIImageView *errorImageView;
@property (nonatomic, weak) IBOutlet MKMapView *mapView;
@property (nonatomic, weak) IBOutlet UISegmentedControl *mapTypeSegmentedControl;

#ifdef FREE
@property (nonatomic, weak) IBOutlet ADBannerView *adBannerView;
#endif

@property (nonatomic, strong) LocationPin *destinationAnnotationPin;
@property (nonatomic, strong) LocationProximity *destinationProximity;
@property (nonatomic, assign) BOOL userMovedMap;

- (void)updateMap:(BOOL)force;
- (void)updateAnnotations;
- (void)updateLabels;

// private
- (IBAction)mapTypeAction:(id)sender;
// - (IBAction)infoAction:(id)sender;
- (IBAction)centreAction:(id)sender;

- (void)animateErrorImageOn:(BOOL)turnOn;
	
- (AlarmModel *)alarmModel;

@end
