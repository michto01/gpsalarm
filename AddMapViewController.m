//
//  AddMapViewController.m
//  GPSAlarm
//
//  Created by Chris Hughes on 11/09/2009.
//  Copyright 2009 Super Sugoi Apps. All rights reserved.
//

#import "AddMapViewController.h"

#import "LocationPin.h"
#import "LocationProximity.h"
#import "LocationProximityView.h"
#import "DistanceModel.h"
#import "MapViewAdditions.h"
#import "LocationController.h"
#import "AddViewController.h"

@implementation AddMapViewController

@synthesize destinationPinView, destinationProximityView, mapView, proximitySegmentedControl;
@synthesize destinationProximity, addViewController, destinationPin, pinButton;

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];

	// Make this a pin drop button
	UIBarButtonItem *dropButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Drop Pin", @"Drop Pin Button Title") style:UIBarButtonItemStyleBordered target:self action:@selector(dropPinAction:)];
	self.navigationItem.rightBarButtonItem = dropButton;	
}

- (void)viewDidUnload {
	// Release any retained subviews of the main view.
	self.mapView.delegate = nil; // known issue with MKMapView - make sure we don't get any callbacks after we are dealloced
	self.mapView = nil;
	self.proximitySegmentedControl = nil;
	self.pinButton = nil;
	
	self.addViewController = nil;
	
	self.destinationPin = nil;
	self.destinationPinView = nil;
	self.destinationProximity = nil;
	self.destinationProximityView = nil;
}

- (void)dealloc {
	mapView.delegate = nil;
	
	
	
	
}

#pragma mark ---

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	
	mapView.showsUserLocation = YES;
	mapView.mapType = MKMapTypeStandard;

	self.destinationPin = nil;
	self.destinationPinView = nil;
	self.destinationProximity = nil;
	self.destinationProximityView = nil;

	if ([addViewController.updatedLocationPin coordinateIsValid] == YES)
		[self placePinWithCoordinate:[addViewController.updatedLocationPin coordinate]];

	proximitySegmentedControl.selectedSegmentIndex = [addViewController.updatedLocationPin distanceType];
	
	// Setup segmented control
	for (NSInteger index = 0 ; index < [proximitySegmentedControl numberOfSegments] ; index++) {
		[proximitySegmentedControl setTitle:[DistanceModel getDistanceStringForType:index] forSegmentAtIndex:index];
	}
}

- (void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];
	
	if (destinationPin != nil) 
		[mapView centreMapAtCoordinate:[destinationPin coordinate]];
}

#pragma mark - internal

- (void)placePinWithCoordinate:(CLLocationCoordinate2D)coord {
	if (destinationPin == nil) {
		destinationPin = [[LocationPin alloc] init];
		destinationProximity = [[LocationProximity alloc] init];
	} else {
		[mapView removeAnnotation:destinationPin];
		[mapView removeAnnotation:destinationProximity];
	}
	
	[destinationPin setCoordinate:coord];
	[destinationProximity setCoordinate:coord];
	[mapView addAnnotation:destinationPin];
	[mapView addAnnotation:destinationProximity];
	
	// Update addViewController with the new location
	addViewController.updatedLocationPin.coordinate = coord;

	// Now we have placed a pin, enable the pin location button
	pinButton.enabled = YES;
}

- (void)updateProximityView {
	if (destinationProximityView != nil) {
		CGRect bounds = [mapView rectWithRadius:[self getProximityMetres] atCoordinate:[destinationPin coordinate]];
		[destinationProximityView animateProximityWithCoordinate:[destinationPin coordinate] withBounds:bounds withDistance:[self getProximityMetres]];
	}
}

#pragma mark IBActions

- (void)dropPinAction:(id)sender {
	[self placePinWithCoordinate:[mapView centerCoordinate]];
}

- (IBAction)usePinLocationAction:(id)sender {
	if (destinationPin == nil)  // XXX - should really disable button
		return;  
	[mapView centreMapAtCoordinate:[destinationPin coordinate]];
}

- (IBAction)useCurrentLocationAction:(id)sender {
	LocationController *lc = [LocationController sharedInstance];
	if ([lc hasUserLocation] == YES)    // XXX = should disable button if no user location?
		[mapView centreMapAtCoordinate:[lc currentCoordinate]];
}

- (IBAction)useCentreLocationAction:(id)sender {
	LocationController *lc = [LocationController sharedInstance];
	
	if ([lc hasUserLocation] == NO)  {
		if (destinationPin == nil)  // No device, no destination
			return;
		[mapView centreMapAtCoordinate:[destinationPin coordinate]];  // No device, destination
	} else {
		CLLocationCoordinate2D userCoordinate = [lc currentCoordinate];		
		if (destinationPin == nil) {
			[mapView centreMapAtCoordinate:userCoordinate]; // Device, no destination
		} else {
			[mapView fitMapForCoordinate:[destinationPin coordinate] andCoordinate:userCoordinate]; // Device, destination
		}
	}
}

- (DistanceType)getProximityType {
	return [proximitySegmentedControl selectedSegmentIndex];
}

- (NSInteger)getProximityMetres {
	NSInteger type = [self getProximityType];
	return [DistanceModel getMetresForType:type];
}

- (IBAction)proximityAction:(id)sender {
	[self updateProximityView];
	
	// Update addViewController with new proximity setting
	addViewController.updatedLocationPin.distanceType = [self getProximityType];
}

#pragma mark MKMapView Delegate

- (void)mapView:(MKMapView *)mV regionWillChangeAnimated:(BOOL)animated {
	if (destinationProximityView != nil)
		[destinationProximityView hide];
}

- (void)mapView:(MKMapView *)mV regionDidChangeAnimated:(BOOL)animated {
	[self updateProximityView];
}

- (MKAnnotationView *)mapView:(MKMapView *)mV viewForAnnotation:(id <MKAnnotation>)annotation {
	if (annotation == [self destinationPin]) {
		if (!destinationPinView) 
			destinationPinView = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"a"];
		destinationPinView.animatesDrop = YES;
		destinationPinView.pinColor = MKPinAnnotationColorRed; // Red is destination colour
		return destinationPinView;
	}
	
	if (annotation == [self destinationProximity]) {
		if (!destinationProximityView) 
			destinationProximityView = [[LocationProximityView alloc] initWithAnnotation:annotation reuseIdentifier:@"b"];
		[self updateProximityView];
		return destinationProximityView;		
	}
	return nil;
}

@end
