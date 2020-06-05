// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

#pragma once
#import "AKAudioUnit.h"

typedef void (^AKCCallback)(void);

@interface AKWaveTableAudioUnit : AKAudioUnit
@property (nonatomic) float startPoint;
@property (nonatomic) float endPoint;
@property (nonatomic) float tempStartPoint;
@property (nonatomic) float tempEndPoint;
@property (nonatomic) float rate;
@property (nonatomic) float volume;
@property (nonatomic) BOOL loop;
@property (nonatomic) float loopStartPoint;
@property (nonatomic) float loopEndPoint;
@property (nonatomic) AKCCallback loadCompletionHandler;
@property (nonatomic) AKCCallback completionHandler;
@property (nonatomic) AKCCallback loopCallback;

- (void)setupAudioFileTable:(UInt32)size;
- (void)loadAudioData:(float *)data size:(UInt32)size sampleRate:(float)sampleRate numChannels:(UInt32)numChannels;
- (int)size;
- (float)position;
- (void)destroy;

@end


