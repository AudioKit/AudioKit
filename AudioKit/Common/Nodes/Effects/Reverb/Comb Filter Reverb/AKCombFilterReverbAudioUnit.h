//
//  AKCombFilterReverbAudioUnit.h
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright (c) 2016 Aurelius Prochazka. All rights reserved.
//

#ifndef AKCombFilterReverbAudioUnit_h
#define AKCombFilterReverbAudioUnit_h

#import <AudioToolbox/AudioToolbox.h>

@interface AKCombFilterReverbAudioUnit : AUAudioUnit
@property (nonatomic) float reverbDuration;
- (void)setLoopDuration:(float)duration;
- (void)start;
- (void)stop;
- (BOOL)isPlaying;
- (void)setUpParameterRamp;
- (BOOL)isSetUp;

@property double rampTime;

@end

#endif /* AKCombFilterReverbAudioUnit_h */
