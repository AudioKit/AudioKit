//
//  AKSampler.m
//  AudioKit
//
//  Created by Aurelius Prochazka on 7/8/14.
//  Copyright (c) 2014 Aurelius Prochazka. All rights reserved.
//

#import "AKSampler.h"
#import "AKManager.h"
#import <AVFoundation/AVFoundation.h>

@implementation AKSampler
{
    NSMutableDictionary<NSString *, AVAudioPlayer *> *players;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        players = [[NSMutableDictionary alloc] init];
    }
    return self;
}

- (NSArray *)trackNames {
    return [players allKeys];
}

- (void)startRecordingToTrack:(NSString *)trackName
{
    [[AKManager sharedManager] startRecordingToURL:[self recordingURLForTrack:trackName]];
}
- (void)stopRecordingToTrack:(NSString *)trackName
{
    [[AKManager sharedManager] stopRecording];
    
    AVAudioPlayer *player = [[AVAudioPlayer alloc] initWithContentsOfURL:[self recordingURLForTrack:trackName] error:nil];
    [players setObject:player forKey:trackName];
}

- (void)startPlayingTrack:(NSString *)trackName
{
    if ([[players allKeys] containsObject:trackName]) {
        AVAudioPlayer *player = [players objectForKey:trackName];
        [player play];
    }
}
- (void)stopPlayingTrack:(NSString *)trackName
{
    if ([[players allKeys] containsObject:trackName]) {
        AVAudioPlayer *player = [players objectForKey:trackName];
        [player stop];
        [player setCurrentTime:0];
    }
}

- (NSURL *)recordingURLForTrack:(NSString *)name
{
    NSURL *localDocDirURL = nil;
    if (localDocDirURL == nil) {
        NSString *docDirPath = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0];
        localDocDirURL = [NSURL fileURLWithPath:docDirPath];
    }
    NSString *filename = [NSString stringWithFormat:@"sampler-%@.wav", name];
    
    return [localDocDirURL URLByAppendingPathComponent:filename];
}

@end
