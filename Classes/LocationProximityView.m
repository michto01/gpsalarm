//
//  LocationProximityView.m
//  GPSAlarm
//
//  Created by Chris Hughes on 04/09/2009.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "LocationProximityView.h"

@implementation LocationProximityView

- (id)initWithAnnotation:(id <MKAnnotation>)annotation reuseIdentifier:(NSString *)reuseIdentifier {
	if (self = [super initWithAnnotation:annotation reuseIdentifier:reuseIdentifier]) {
		self.backgroundColor = [UIColor clearColor];
		self.contentMode = UIViewContentModeRedraw;
	}
	return self;
}

- (void)drawRect:(CGRect)rect {
	CGContextRef context = UIGraphicsGetCurrentContext();		
	
	CGRect bounds = [self bounds];
//	DLog(@"Rect %f,%f %f,%f", rect.origin.x, rect.origin.y, rect.size.width, rect.size.height);	
//	DLog(@"Bounds %f,%f %f,%f", bounds.origin.x, bounds.origin.y, bounds.size.width, bounds.size.height);
	if (bounds.size.width < 8.0f)  // Don't bother drawing if the circle will be so small
		return;

	CGContextSetRGBStrokeColor(context, 0.6f, 0.6f, 0.0f, 0.75f);
	CGContextSetLineWidth(context, 3.0f);
	CGRect strokeBounds = CGRectMake(2, 2, bounds.size.width - 6, bounds.size.width - 6);
	CGContextStrokeEllipseInRect(context, strokeBounds);
}

- (void)hide {
	self.hidden = YES;
}

- (void)animationDidStop:(NSString *)animationID finished:(NSNumber *)finished context:(void *)context {
	if ([animationID compare:@"proxanim"] != NSOrderedSame) {
//		NSAssert1(0, @"animate stop with wrong animatationID (%@)", animationID);  // XXX - remove assert before distribution
		return;
	}
		
	NSNumber *contextNo = (__bridge NSNumber *)context;
	if ([contextNo boolValue] == YES)
		self.hidden = YES;
}

- (void)animateProximityWithCoordinate:(CLLocationCoordinate2D)coordinate withBounds:(CGRect)newBounds withDistance:(NSInteger)distanceM {
	BOOL limit = NO;
	if (newBounds.size.width > 500.0f) { // Don't attempt to draw large annotations
		limit = YES;
		newBounds.size.width = 500.0f;
		newBounds.size.height = 500.0f;
	}
	self.hidden = NO;
	self.alpha = 0.0f;
	self.bounds = CGRectZero;
	[UIView beginAnimations:@"proxanim" context:(__bridge void *)([NSNumber numberWithBool:limit])];
	[UIView setAnimationDelegate:self];
	[UIView setAnimationDidStopSelector:@selector(animationDidStop:finished:context:)];
	[UIView setAnimationDuration:0.75f];
	self.bounds = newBounds;
	self.alpha = 1.0f;
	[UIView commitAnimations];
}


@end
