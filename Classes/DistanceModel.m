//
//  DistanceModel.m
//  GPSAlarm
//
//  Created by Chris Hughes on 04/09/2009.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "DistanceModel.h"

@implementation DistanceModel

static DistanceUnits _units = DistanceUnitsMetric;

static NSString *_distancesMetric[] = {	@"100m", @"500m", @"1km", @"5km" };
static NSString *_distancesImperial[] = { @"300ft", @"1500ft", @"1/2 mile", @"3 miles" };
static NSInteger _distancesMetricMetres[] = { 100, 500, 1000, 5000 };
// static NSInteger _distancesImperialMetres[] = { 100, 500, 1000, 5000 };

+ (NSString *)getDistanceStringForType:(DistanceType)type {
	if (_units == DistanceUnitsImperial)
		return _distancesImperial[type];
	return _distancesMetric[type];
}

+ (DistanceUnits)getDistanceUnits {
	return _units;
}

+ (void)setDistanceUnits:(DistanceUnits)units {
	_units = units;
}
	
+ (NSInteger)getMetresForType:(DistanceType)type {
	return _distancesMetricMetres[type];
}

+ (NSString *)stringForDistance:(NSInteger)distanceInMetres {
	if (_units == DistanceUnitsImperial) {
		NSInteger feet = (NSInteger)((CGFloat)distanceInMetres * 3.2808399);
		CGFloat miles = (CGFloat)distanceInMetres * 0.000621371192;
		if (feet > 5280)
			return [NSString stringWithFormat:@"%.1f miles", miles];			
		return [NSString stringWithFormat:@"%dft", feet];
	} else {
		if (distanceInMetres < 1000) 
			return [NSString stringWithFormat:@"%dm", distanceInMetres];
		return [NSString stringWithFormat:@"%.1fkm", (CGFloat)distanceInMetres / 1000];
	}
	return nil;
}

@end
