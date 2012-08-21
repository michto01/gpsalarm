//
//  LocationProximityView.h
//  GPSAlarm
//
//  Created by Chris Hughes on 04/09/2009.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>

@interface LocationProximityView : MKAnnotationView {

}

- (void)drawRect:(CGRect)rect;

- (void)hide;
- (void)animateProximityWithCoordinate:(CLLocationCoordinate2D)coordinate withBounds:(CGRect)newBounds withDistance:(NSInteger)distanceM;

// private
- (void)animationDidStop:(NSString *)animationID finished:(NSNumber *)finished context:(void *)context;

@end
