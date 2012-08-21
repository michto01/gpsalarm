//
//  AddMapViewController.h
//  GPSAlarm
//
//  Created by Chris Hughes on 11/09/2009.
//  Copyright 2009 Super Sugoi Apps. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import "DistanceModel.h"

@class LocationProximity, LocationProximityView, AddViewController;

@interface AddMapViewController : UIViewController <MKMapViewDelegate> {
//	IBOutlet MKMapView *mapView;
//	IBOutlet UISegmentedControl *proximitySegmentedControl;
//	IBOutlet UIBarButtonItem *pinButton;
	
	AddViewController *addViewController;
@private
	LocationPin *destinationPin;						// The red pin annotation
	MKPinAnnotationView *destinationPinView;			// The view behind the red pin

	LocationProximity *destinationProximity;			// The proximity circle annotation
	LocationProximityView *destinationProximityView;	// The view behind the circle
}

@property (nonatomic, weak) IBOutlet MKMapView *mapView;
@property (nonatomic, weak) IBOutlet UISegmentedControl *proximitySegmentedControl;
@property (nonatomic, strong) LocationPin *destinationPin;
@property (nonatomic, strong) MKPinAnnotationView *destinationPinView;
@property (nonatomic, strong) LocationProximity *destinationProximity;
@property (nonatomic, strong) LocationProximityView *destinationProximityView;
@property (nonatomic, strong) AddViewController *addViewController;
@property (nonatomic, weak) IBOutlet UIBarButtonItem *pinButton;

- (void)dropPinAction:(id)sender;
- (IBAction)proximityAction:(id)sender;
- (IBAction)useCentreLocationAction:(id)sender;
- (IBAction)useCurrentLocationAction:(id)sender;
- (IBAction)usePinLocationAction:(id)sender;

// private
- (void)placePinWithCoordinate:(CLLocationCoordinate2D)coord;
- (DistanceType)getProximityType;
- (NSInteger)getProximityMetres;
- (void)updateProximityView;

@end
