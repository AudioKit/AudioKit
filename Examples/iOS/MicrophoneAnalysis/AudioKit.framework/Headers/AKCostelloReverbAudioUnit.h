//
//  AKCostelloReverbAudioUnit.h
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright (c) 2016 Aurelius Prochazka. All rights reserved.
//

#ifndef AKCostelloReverbAudioUnit_h
#define AKCostelloReverbAudioUnit_h

#import <AudioToolbox/AudioToolbox.h>

@interface AKCostelloReverbAudioUnit : AUAudioUnit
@property (nonatomic) float feedback;
@property (nonatomic) float cutoffFrequency;

- (void)start;
- (void)stop;
- (BOOL)isPlaying;
- (void)setUpParameterRamp;
- (BOOL)isSetUp;

@property double rampTime;

@end

#endif /* AKCostelloReverbAudioUnit_h */
