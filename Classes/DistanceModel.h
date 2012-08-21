//
//  DistanceModel.h
//  GPSAlarm
//
//  Created by Chris Hughes on 04/09/2009.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DistanceModel : NSObject {

}

typedef enum _DistanceUnits {
	DistanceUnitsMetric = 0,
	DistanceUnitsImperial
} DistanceUnits;
	
typedef enum _DistanceType {
	DistanceType0 = 0,
	DistanceType1,
	DistanceType2,
	DistanceType3
} DistanceType;

+ (NSString *)getDistanceStringForType:(DistanceType)type;
+ (DistanceUnits)getDistanceUnits;
+ (void)setDistanceUnits:(DistanceUnits)units;
+ (NSInteger)getMetresForType:(DistanceType)type;

+ (NSString *)stringForDistance:(NSInteger)distanceInMetres;

@end
