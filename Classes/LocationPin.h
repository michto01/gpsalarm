//
//  LocationPin.h
//  GPSAlarm
//
//  Created by Chris Hughes on 27/08/2009.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

#import "DistanceModel.h"

@interface LocationPin : NSObject <MKAnnotation, NSCoding> {
	CLLocationCoordinate2D coordinate;
	NSString *title;
    DistanceType distanceType;  // proximity type
	NSString *ringtoneTitle;
	BOOL alarmOn;
}

@property (nonatomic, assign) CLLocationCoordinate2D coordinate;
@property (nonatomic, copy) NSString *title;
@property (nonatomic, assign) BOOL alarmOn;
@property (nonatomic, assign) DistanceType distanceType;
@property (nonatomic, strong) NSString *ringtoneTitle;

- (BOOL)coordinateIsValid;

@end
