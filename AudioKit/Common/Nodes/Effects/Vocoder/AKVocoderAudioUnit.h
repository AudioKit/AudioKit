//
//  AKVocoderAudioUnit.h
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright (c) 2016 Aurelius Prochazka. All rights reserved.
//

#ifndef AKVocoderAudioUnit_h
#define AKVocoderAudioUnit_h

#import <AudioToolbox/AudioToolbox.h>

@interface AKVocoderAudioUnit : AUAudioUnit
@property (nonatomic) float attackTime;
@property (nonatomic) float releaseTime;
@property (nonatomic) float bandwidthRatio;

- (void)start;
- (void)stop;
- (BOOL)isPlaying;
- (void)setUpParameterRamp;
- (BOOL)isSetUp;

@property double rampTime;

@end

#endif /* AKVocoderAudioUnit_h */
