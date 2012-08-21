//
//  LocationProximity.h
//  GPSAlarm
//
//  Created by Chris Hughes on 04/09/2009.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>
#import "DistanceModel.h"

@interface LocationProximity : NSObject <MKAnnotation> {
	CLLocationCoordinate2D coordinate;
}

@property (nonatomic, assign) CLLocationCoordinate2D coordinate;

// public
- (NSString *)title;

@end
