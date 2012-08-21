//
//  MapViewAdditions.h
//  GPSAlarm
//
//  Created by Chris Hughes on 04/09/2009.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>

@interface MKMapView (Additions)

// Resets the mapview with the centre at the coordinate with 500m span
- (void)centreMapAtCoordinate:(CLLocationCoordinate2D)coordinate;

// 
- (CGRect)rectWithRadius:(NSInteger)radiusInMetres atCoordinate:(CLLocationCoordinate2D)coordinate;
	
// Fits the mapview to show two coordinates
- (void)fitMapForCoordinate:(CLLocationCoordinate2D)c1 andCoordinate:(CLLocationCoordinate2D)c2;

// Returns coordinate of midpoint between two coordinates
+ (CLLocationCoordinate2D)midpointBetweenCoordinate:(CLLocationCoordinate2D)c1 andCoordinate:(CLLocationCoordinate2D)c2;

// Returns distance between two coordinates
+ (CLLocationDistance)distanceFromCoordinate:(CLLocationCoordinate2D)c1 toCoordinate:(CLLocationCoordinate2D)c2;

@end
