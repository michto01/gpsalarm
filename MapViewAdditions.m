//
//  MapViewAdditions.m
//  GPSAlarm
//
//  Created by Chris Hughes on 04/09/2009.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "MapViewAdditions.h"

@implementation MKMapView (Additions)

- (void)centreMapAtCoordinate:(CLLocationCoordinate2D)coordinate {
//	DLog(@"ADDITIONS: Centering map on %f,%f", coordinate.latitude, coordinate.longitude);
	CLLocationDistance distanceinMetres = 1000.0f;
	MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(coordinate, distanceinMetres, distanceinMetres);
	[self setRegion:region animated:YES];
}

- (CGRect)rectWithRadius:(NSInteger)radiusInMetres atCoordinate:(CLLocationCoordinate2D)coordinate {
	NSInteger diameterInMetres = radiusInMetres * 2;
	MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(coordinate, diameterInMetres, diameterInMetres);
	CGRect frame = [self convertRegion:region toRectToView:nil];
//	DLog(@"ADDITIONS - rectWithRadius %f,%f %f,%f", frame.origin.x, frame.origin.y, frame.size.width, frame.size.height);
	frame.origin.x = 0.0f;
	frame.origin.y = 0.0f;
	return frame;
}


+ (CLLocationDistance)distanceFromCoordinate:(CLLocationCoordinate2D)c1 toCoordinate:(CLLocationCoordinate2D)c2 {
	CLLocation *l1 = [[CLLocation alloc] initWithLatitude:c1.latitude longitude:c1.longitude];
	CLLocation *l2 = [[CLLocation alloc] initWithLatitude:c2.latitude longitude:c2.longitude];
//	CLLocationDistance distanceM = [l2 getDistanceFrom:l1];
    CLLocationDistance distanceM = [l2 distanceFromLocation:l1];
	return distanceM;
	
	/*
	 c1.latitude *= M_PI / 180;
	 c2.latitude*= M_PI / 180;
	 c1.longitude*= M_PI / 180;
	 c2.longitude*= M_PI / 180;
	 
	 CGFloat distanceKm = acos(sin(c1.latitude) * sin(c2.latitude) + cos(c1.latitude) * cos(c2.latitude) * cos(c2.longitude - c1.longitude)) * 6371;
	 
	 return distanceKm;
	 */
}

- (void)fitMapForCoordinate:(CLLocationCoordinate2D)c1 andCoordinate:(CLLocationCoordinate2D)c2 {
//	DLog(@"ADDITIONS - fitting map between points");
	CLLocationCoordinate2D midpointCoordinate = [MKMapView midpointBetweenCoordinate:c1 andCoordinate:c2];
	CLLocationDistance distanceM = [MKMapView distanceFromCoordinate:c1 toCoordinate:c2];
	MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(midpointCoordinate, distanceM, distanceM);
	MKCoordinateRegion regionFits = [self regionThatFits:region];
	[self setRegion:regionFits animated:YES];
}

#define TORAD(x) ((x) * M_PI/180)
#define TODEG(x) ((x) * 180/M_PI)

+ (CLLocationCoordinate2D)midpointBetweenCoordinate:(CLLocationCoordinate2D)c1 andCoordinate:(CLLocationCoordinate2D)c2 {
	c1.latitude = TORAD(c1.latitude);
	c2.latitude = TORAD(c2.latitude);
	CLLocationDegrees dLon = TORAD(c2.longitude - c1.longitude);
	CLLocationDegrees bx = cos(c2.latitude) * cos(dLon);
	CLLocationDegrees by = cos(c2.latitude) * sin(dLon);	
	CLLocationDegrees latitude = atan2(sin(c1.latitude) + sin(c2.latitude), sqrt((cos(c1.latitude) + bx) * (cos(c1.latitude) + bx) + by*by));
	CLLocationDegrees longitude = TORAD(c1.longitude) + atan2(by, cos(c1.latitude) + bx);
	
	CLLocationCoordinate2D midpointCoordinate;
	midpointCoordinate.longitude = TODEG(longitude);
	midpointCoordinate.latitude = TODEG(latitude);
	
//	DLog(@"midpoint of %f,%f and %f,%f is %f,%f",c1.latitude, c1.longitude, c2.latitude, c2.longitude, midpointCoordinate.latitude, midpointCoordinate.longitude);
	return midpointCoordinate;
	
	/*
	 var Bx = Math.cos(lat2) * Math.cos(dLon);
	 var By = Math.cos(lat2) * Math.sin(dLon);
	 var lat3 = Math.atan2(Math.sin(lat1)+Math.sin(lat2),
	 Math.sqrt((Math.cos(lat1)+Bx)*(Math.cos(lat1)+Bx) + 
	 By*By ) ); 
	 var lon3 = lon1.toRad() + Math.atan2(By, Math.cos(lat1) + Bx);  	 */
}

@end
