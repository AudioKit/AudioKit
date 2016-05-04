//
//  AKFlatFrequencyResponseReverbAudioUnit.h
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright (c) 2016 Aurelius Prochazka. All rights reserved.
//

#ifndef AKFlatFrequencyResponseReverbAudioUnit_h
#define AKFlatFrequencyResponseReverbAudioUnit_h

#import <AudioToolbox/AudioToolbox.h>

@interface AKFlatFrequencyResponseReverbAudioUnit : AUAudioUnit
@property (nonatomic) float reverbDuration;
- (void)setLoopDuration:(float)duration;

- (void)start;
- (void)stop;
- (BOOL)isPlaying;
- (void)setUpParameterRamp;
- (BOOL)isSetUp;

@property double rampTime;

@end

#endif /* AKFlatFrequencyResponseReverbAudioUnit_h */
