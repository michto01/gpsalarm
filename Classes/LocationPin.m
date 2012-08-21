//
//  LocationPin.m
//  GPSAlarm
//
//  Created by Chris Hughes on 27/08/2009.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "LocationPin.h"

#import "RingtoneModel.h"
#import "DistanceModel.h"

@implementation LocationPin

@synthesize coordinate, title, alarmOn, distanceType, ringtoneTitle;

- (LocationPin *)init {
	if (self = [super init])
	{
		RingtoneModel *rm = [RingtoneModel sharedInstance];
		self.ringtoneTitle = [rm defaultRingtoneTitle];
		self.distanceType = DistanceType1;
		self.alarmOn = NO;
	}
	return self;
}


#pragma mark NSCoding

-(id)initWithCoder: (NSCoder *) coder
{
	if (self = [super init])
	{
		coordinate.longitude = [coder decodeDoubleForKey:@"long"];
		coordinate.latitude = [coder decodeDoubleForKey:@"lat"];
		self.title = [coder decodeObject];
		alarmOn = [coder decodeBoolForKey:@"alarmOn"];
		distanceType = [coder decodeIntegerForKey:@"proximityType"];
		self.ringtoneTitle = [coder decodeObject];
	}
	return self;
}

- (void)encodeWithCoder:(NSCoder *)coder
{
	[coder encodeObject:title];
	[coder encodeDouble:coordinate.longitude forKey:@"long"];
	[coder encodeDouble:coordinate.latitude forKey:@"lat"];
	[coder encodeBool:alarmOn forKey:@"alarmOn"];
	[coder encodeInteger:distanceType forKey:@"proximityType"];
	[coder encodeObject:ringtoneTitle];
}

#pragma mark NSCopying

- (id)copyWithZone:(NSZone *)zone {
	LocationPin *newPin = [[LocationPin alloc] init];
	
	newPin.coordinate = [self coordinate];
	newPin.title = [self title];
	newPin.distanceType = [self distanceType];
	newPin.ringtoneTitle = [self ringtoneTitle];
	newPin.alarmOn = [self alarmOn];
	return newPin;
}

#pragma mark ---

// XXX not a very satisfactory way of testing this
- (BOOL)coordinateIsValid {
	if (coordinate.latitude == 0.0f && coordinate.longitude == 0.0f)
		return NO;
	return YES;
}

@end
