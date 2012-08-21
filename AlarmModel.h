//
//  AlarmModel.h
//  GPSAlarm
//
//  Created by Chris Hughes on 03/09/2009.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AudioToolbox/AudioToolbox.h>
#import <AVFoundation/AVAudioPlayer.h>

@class LocationPin;

@interface AlarmModel : NSObject <NSCoding, UIAlertViewDelegate> {

}

@property (nonatomic, strong) NSMutableArray *pinArray;		// Array of LocationPins
@property (nonatomic, strong) NSTimer *alarmTimer;          // After firing, repeat once

// public

+ (AlarmModel *)sharedInstance;

// Manage loading and saving the model
+ (NSString *)getPathToStateDB;
- (BOOL)loadState;
- (void)saveState;

// Handle Alarm state (on or off)
- (BOOL)alarmIsOn;
- (void)alarmOn:(BOOL)isOn withIndex:(NSInteger)index;

- (LocationPin *)destinationPin;

// Manage Alarm testing and firing
- (void)checkAlarm;
- (void)fireAlarm;
- (void)quenchAlarm;
- (void)alarmTimerFired:(NSTimer *)timer;

// Handle device actions
- (void)vibrateDevice;

// Alert view
- (void)raiseAlarmAlertViewWithTitle:(NSString *)message;

@end
