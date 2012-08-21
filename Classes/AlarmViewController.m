//
//  AlarmViewController.m
//  GPSAlarm
//
//  Created by Chris Hughes on 25/08/2009.
//  Copyright __MyCompanyName__ 2009. All rights reserved.
//

#import "AlarmViewController.h"
#import "GPSAlarmAppDelegate.h"
#import "LocationController.h"
#import "AlarmModel.h"
#import "LocationProximityView.h"
#import "LocationProximity.h"
#import "MapViewAdditions.h"

@implementation AlarmViewController

@synthesize destinationLabel, distanceToDestinationLabel, mapView, destinationAnnotationPin;
@synthesize mapTypeSegmentedControl, destinationProximity, labelsView, userMovedMap;
@synthesize errorImageView;
#ifdef FREE
@synthesize adBannerView;
#endif

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
	if ([[change objectForKey:NSKeyValueChangeKindKey] integerValue] == NSKeyValueChangeSetting) {
		[self updateMap:YES];
		[self updateLabels];
	}
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
	
	mapView.showsUserLocation = YES;
	mapView.mapType = MKMapTypeStandard;
	mapView.scrollEnabled = YES;
	mapView.zoomEnabled = YES;
	
	LocationController *lc = [LocationController sharedInstance];
	lc.delegate = self;
	
	self.destinationAnnotationPin = nil;
	self.destinationProximity = nil;
	
	// Register observer so we will get notified when the alarm fires
	AlarmModel *am = [AlarmModel sharedInstance];
	[am addObserver:self forKeyPath:@"alarmHasFired" options:NSKeyValueObservingOptionNew context:NULL];
}

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
	self.labelsView = nil;
	self.destinationLabel = nil;
	self.distanceToDestinationLabel = nil;
	self.errorImageView = nil;
	
	self.mapView = nil;
	self.mapTypeSegmentedControl = nil;
}

- (void)dealloc {
	mapView.delegate = nil;
}

- (AlarmModel *)alarmModel {
	return [AlarmModel sharedInstance];
}

#pragma mark ---

- (void)updateLabels {
	LocationPin *destinationPin = [[AlarmModel sharedInstance] destinationPin];
	if (destinationPin != nil) {
		labelsView.hidden = NO;
		destinationLabel.text = [destinationPin title];
	} else {
		labelsView.hidden = YES;
		destinationLabel.text = nil;
	}
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	
	[self updateAnnotations];
	[self updateLabels];

#ifdef FREE
    if ([adBannerView isBannerLoaded]) 
        adBannerView.hidden = NO;
#endif
}

- (void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];

	[self updateMap:YES];
}

#ifdef FREE
- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    
    adBannerView.hidden = YES;
}
#endif


#pragma mark LocationController Delegate

- (void)currentLocationUpdate:(CLLocationCoordinate2D)coordinate {
    DLog(@"AlarmViewController - currentLocationUpdate");
	[self animateErrorImageOn:NO];
	[self updateMap:NO];
	
	[[AlarmModel sharedInstance] checkAlarm];
}

- (void)errorUpdate:(NSString *)errorString {
    DLog(@"Error: %@", errorString);
	[self animateErrorImageOn:YES];
}

#pragma mark MKMapView Delegate

- (void)updateProximityView {
	if (destinationProximity != nil) {
		LocationProximityView *view = (LocationProximityView *)[mapView viewForAnnotation:destinationProximity];	
		LocationPin *destinationPin = [[self alarmModel] destinationPin];
		NSInteger distanceM = [DistanceModel getMetresForType:[destinationPin distanceType]];
		CGRect newBounds = [mapView rectWithRadius:distanceM atCoordinate:[destinationPin coordinate]];
		[view animateProximityWithCoordinate:[destinationPin coordinate] withBounds:newBounds withDistance:distanceM];		
	}
}

- (void)mapView:(MKMapView *)mV regionWillChangeAnimated:(BOOL)animated {
	if (destinationProximity != nil) {
		LocationProximityView *view = (LocationProximityView *)[mapView viewForAnnotation:destinationProximity];
		[view hide];
	}
	self.userMovedMap = YES;
}

- (void)mapView:(MKMapView *)mV regionDidChangeAnimated:(BOOL)animated {
	[self updateProximityView];
}

- (MKAnnotationView *)mapView:(MKMapView *)mV viewForAnnotation:(id <MKAnnotation>)annotation {
	static NSString *identifier = @"DestinationPinView";
	
	if (annotation == destinationAnnotationPin) {
		MKPinAnnotationView *view = (MKPinAnnotationView *)[[self mapView] dequeueReusableAnnotationViewWithIdentifier:identifier];
		if (!view)
			view = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:identifier];
		view.animatesDrop = NO;
		view.pinColor = MKPinAnnotationColorRed; // Red is destination colour
		return view;
	}
	if (annotation == destinationProximity) {
		static NSString *identifier = @"DestinationProximityView";
		LocationProximityView *view = (LocationProximityView *)[[self mapView] dequeueReusableAnnotationViewWithIdentifier:identifier];
		if (!view) 
			view = [[LocationProximityView alloc] initWithAnnotation:annotation reuseIdentifier:identifier];
		[self updateProximityView];
		return view;		
	}
	return nil;
}

#pragma mark ---

- (void)updateAnnotations {
    DLog(@"");
	LocationPin *destinationPin = [self.alarmModel destinationPin];

	if (destinationPin == nil) { // Alarm is off - remove any annotation
		if (destinationAnnotationPin != nil) {
//			DLog(@"alarmOff - removing annotations");
			[mapView removeAnnotation:destinationAnnotationPin];
			[mapView removeAnnotation:destinationProximity];
		}
		return;
	}
//	DLog(@"alarmOn - updating annotations");
	// Alarm is on.  Make sure the annotation is on the map
	if (destinationAnnotationPin == nil) {
		destinationAnnotationPin = [[LocationPin alloc] init];
		destinationProximity = [[LocationProximity alloc] init];
	}
		
	destinationAnnotationPin.coordinate = [destinationPin coordinate];
	destinationProximity.coordinate = [destinationPin coordinate];
	destinationAnnotationPin.title = [destinationPin title];
	
	NSArray *annotationArray = [mapView annotations];
	if ([annotationArray containsObject:destinationAnnotationPin] == NO) {
		[mapView addAnnotation:destinationAnnotationPin];
		[mapView addAnnotation:destinationProximity];
	}
	
	// Make sure the proximity view is correctly sized
	LocationProximityView *view = (LocationProximityView *)[mapView viewForAnnotation:destinationProximity];
	NSInteger distanceM = [DistanceModel getMetresForType:[destinationPin distanceType]];	
	view.bounds = [mapView rectWithRadius:distanceM atCoordinate:[destinationPin coordinate]];	
}

- (void)updateMap:(BOOL)force {
    DLog(@"");
	LocationController *lc = [LocationController sharedInstance];
	LocationPin *destinationPin = [self.alarmModel destinationPin];

	// If the user has altered the map then we don't redraw (unless 'force'd to)
	if (force == NO && [self userMovedMap] == YES)
		return;
	
	if ([lc hasUserLocation] == NO)  { // No location yet, so nothing to centre on	
		distanceToDestinationLabel.text = nil;		
		if (destinationPin == nil)  // No destination either
			return;
		
//		DLog(@"---  No user location, centering on destination");
		[mapView centreMapAtCoordinate:[destinationPin coordinate]];		
	} else {
		CLLocationCoordinate2D userCoordinate = [lc currentCoordinate];		
		if (destinationPin == nil) {  // Centre on our current location
//			DLog(@"---  User location, no destination");
			distanceToDestinationLabel.text = nil;

			[mapView centreMapAtCoordinate:userCoordinate];
		} else {
//			DLog(@"---  User location, destination");
			CLLocationDistance distanceM = [MKMapView distanceFromCoordinate:userCoordinate toCoordinate:[destinationPin coordinate]];
			distanceToDestinationLabel.text = [DistanceModel stringForDistance:distanceM];
			

            @try {
                [mapView fitMapForCoordinate:[destinationPin coordinate] andCoordinate:userCoordinate];
            }
            @catch (NSException *exception) {
                DLog(@"Caught exception: %@", exception);
            }
//            @finally {
//            }

		}
	}
	self.userMovedMap = NO;
}

#pragma mark IBActions

- (IBAction)mapTypeAction:(id)sender {
	switch ([mapTypeSegmentedControl selectedSegmentIndex]) {
		case 1:
			mapView.mapType = MKMapTypeSatellite;
			break;
		case 2:
			mapView.mapType = MKMapTypeHybrid;
			break;
		default:
			mapView.mapType = MKMapTypeStandard;
			break;
	}
}

- (IBAction)centreAction:(id)sender {
	[self updateMap:YES];
}

#pragma mark -- Animate error image

- (void)animateErrorImageOn:(BOOL)turnOn {
//	DLog(@"animateErrorImageOn: %d %f", turnOn, [errorImageView alpha]);
	CGFloat startAlpha, endAlpha;
	if (turnOn == YES) {
		if ([errorImageView alpha] == 1.0f)
			return;
		startAlpha = 0.0f;
		endAlpha = 1.0f;
	} else {
		if ([errorImageView alpha] == 0.0f)
			return;
		startAlpha = 1.0f;
		endAlpha = 0.0f;
	}
	errorImageView.alpha = startAlpha;
	[UIView beginAnimations:nil context:nil];
	[UIView setAnimationBeginsFromCurrentState:YES];
	[UIView setAnimationDuration:5.0f];
	errorImageView.alpha = endAlpha;
	[UIView commitAnimations];
}

/*
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
	NSSet *allTouches = [event allTouches];
	UITouch *touch = [[allTouches allObjects] objectAtIndex:0];
	if ([allTouches count] == 1 && ([touch view] == lockImageView || [touch view] == mapTypeSegmentedControl))
		[self animateLockImage];
}
 */

#pragma mark ADBannerViewDelegate

#ifdef FREE

- (void)bannerViewDidLoadAd:(ADBannerView *)banner {
    DLog(@"AD: bannerViewDidLoadAd - mainthread %d", [NSThread isMainThread]);
    adBannerView.hidden = NO;
}

- (BOOL)bannerViewActionShouldBegin:(ADBannerView *)banner willLeaveApplication:(BOOL)willLeave {
    DLog(@"AD: bannerViewActionShouldBegin - MainThread %d", [NSThread isMainThread]);
    return YES;
}

- (void)bannerView:(ADBannerView *)banner didFailToReceiveAdWithError:(NSError *)error {
    DLog(@"error: %@", error);
    adBannerView.hidden = YES;
}

#endif

@end
