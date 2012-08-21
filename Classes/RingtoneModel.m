//
//  RingtoneModel.m
//  GPSAlarm
//
//  Created by Chris Hughes on 09/09/2009.
//  Copyright 2009 Super Sugoi Apps. All rights reserved.
//

#import <AVFoundation/AVAudioPlayer.h>
#import <AudioToolbox/AudioToolbox.h>

#import "RingtoneModel.h"

// static RingtoneModel *sharedDelegate = nil;

@implementation RingtoneModel

@synthesize ringtoneDict, avAudioPlayer, onetimeAudioPlayer;

#pragma mark --

- (id) init {
	self = [super init];
	if (self != nil) {
		[self loadRingtones];

		[self initAudioSession];
	}
	return self;
}

#pragma mark SINGLETON

// See "Creating a Singleton Instance" in the Cocoa Fundamentals Guide for more info

+ (id)sharedInstance {
    static dispatch_once_t pred;
    static RingtoneModel *sharedInstance = nil;
    dispatch_once(&pred, ^{
        sharedInstance = [[RingtoneModel alloc] init];
    });
    return sharedInstance;
}

- (void)dealloc {
    abort();
}

#pragma mark  -- private

- (void)initAudioSession {
	// Configure AV so that it plays even if silent mode is active
	AudioSessionInitialize(NULL, NULL, NULL, NULL);
	UInt32 sessionCategory = kAudioSessionCategory_MediaPlayback;
	AudioSessionSetProperty(kAudioSessionProperty_AudioCategory, sizeof(sessionCategory), &sessionCategory);
}

- (NSString *)pathForMP4:(NSString *)title {
	NSString *file = [ringtoneDict objectForKey:title];
    return [NSString stringWithFormat:@"Sounds/%@.mp4", file];
}

- (NSURL *)urlForMP4:(NSString *)title {
	NSString *file = [ringtoneDict objectForKey:title];
	NSString * const sampleFileType = @"mp4";
	NSString * const samplePath = [[NSBundle mainBundle] pathForResource:file ofType:sampleFileType inDirectory:@"Sounds"];
	NSURL *sampleURL = [[NSURL alloc] initFileURLWithPath: samplePath];
	return sampleURL;
}

- (void)loadRingtone:(NSString *)title {
	if (title == nil) return;
	NSURL *sampleURL = [self urlForMP4:title];
	self.avAudioPlayer = nil;  // release any previous avAudioPlayer
	avAudioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:sampleURL error:nil];
	avAudioPlayer.delegate = self;
	avAudioPlayer.numberOfLoops = 5; // loop 5 times
}

- (void)loadRingtones {
	NSString *pathStr = [[NSBundle mainBundle] bundlePath];
	NSString *finalPath = [pathStr stringByAppendingPathComponent:@"Sounds.plist"];
	self.ringtoneDict = [NSDictionary dictionaryWithContentsOfFile:finalPath];
	NSAssert((ringtoneDict != nil), @"Fatal: Couldn't init ringtones");
}

- (void)playOnceWithRingtone:(NSString *)title {
	if (title == nil) return;
	NSURL *sampleURL = [self urlForMP4:title];
	if (onetimeAudioPlayer != nil) {
		if ([onetimeAudioPlayer isPlaying] == YES)
			[onetimeAudioPlayer stop];
		self.onetimeAudioPlayer = nil;
	}
	
	UInt32 sessionCategory = kAudioSessionCategory_AmbientSound;
	AudioSessionSetProperty(kAudioSessionProperty_AudioCategory, sizeof(sessionCategory), &sessionCategory);
	
	onetimeAudioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:sampleURL error:nil];
//	onetimeAudioPlayer.delegate = self;  // Dont care about this player
	onetimeAudioPlayer.numberOfLoops = 0;
    onetimeAudioPlayer.volume = 0.5f;  // Play this quiet4y
	[onetimeAudioPlayer prepareToPlay];
	[onetimeAudioPlayer play];
}

- (void)stopOncePlayer {
	if (onetimeAudioPlayer == nil)
		return;
	if ([onetimeAudioPlayer isPlaying])
		[onetimeAudioPlayer stop];
	self.onetimeAudioPlayer = nil;
}

#pragma mark AVAudioPlayer Delegate Protocol

/*
- (void)audioPlayerBeginInterruption:(AVAudioPlayer *)player {
	
}
 */

/*
- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag {

}
*/

- (void)audioPlayerEndInterruption:(AVAudioPlayer *)player {
	if (player == avAudioPlayer)
		[avAudioPlayer play]; // resume
}

#pragma mark -- public

- (void)startRingtone {
	DLog(@"Start ringtone: %@ (%f)", avAudioPlayer, [avAudioPlayer duration]);
	if (avAudioPlayer == nil) return;    // No ringtone defined
	AudioSessionSetActive(true);
	avAudioPlayer.volume = 0.9f;
	
	UInt32 sessionCategory = kAudioSessionCategory_MediaPlayback;
	AudioSessionSetProperty(kAudioSessionProperty_AudioCategory, sizeof(sessionCategory), &sessionCategory);
	
	[avAudioPlayer prepareToPlay];
	[avAudioPlayer play];
}

- (void)stopRingtone {
	if (avAudioPlayer == nil) return;    // No ringtone defined

	[avAudioPlayer stop];
	AudioSessionSetActive(false);
	self.avAudioPlayer = nil;
}

// Returns the first entry in the dictionary ('first' being a bit of an odd concept here)
- (NSString *)defaultRingtoneTitle {
	NSEnumerator *enumerator = [ringtoneDict keyEnumerator];
	return [enumerator nextObject];
}

@end
