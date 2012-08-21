//
//  RingtoneModel.h
//  GPSAlarm
//
//  Created by Chris Hughes on 09/09/2009.
//  Copyright 2009 Super Sugoi Apps. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVAudioPlayer.h>

@class AVAudioPlayer;

@interface RingtoneModel : NSObject <AVAudioPlayerDelegate> {
	NSDictionary *ringtoneDict;
@private
	AVAudioPlayer *avAudioPlayer;
	AVAudioPlayer *onetimeAudioPlayer;
}

@property (nonatomic) NSDictionary *ringtoneDict;
@property (nonatomic) AVAudioPlayer *avAudioPlayer;
@property (nonatomic) AVAudioPlayer *onetimeAudioPlayer;

+ (RingtoneModel *)sharedInstance;

// public
- (void)loadRingtone:(NSString *)title;
- (void)startRingtone;
- (void)stopRingtone;
- (NSString *)defaultRingtoneTitle;

- (void)playOnceWithRingtone:(NSString *)title;
- (void)stopOncePlayer;

- (NSString *)pathForMP4:(NSString *)title;
    
// private
- (void)loadRingtones;
- (void)initAudioSession;
- (NSURL *)urlForMP4:(NSString *)title;

@end
