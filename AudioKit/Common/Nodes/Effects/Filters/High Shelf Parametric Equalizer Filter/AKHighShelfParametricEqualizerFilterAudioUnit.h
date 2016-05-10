//
//  AKHighShelfParametricEqualizerFilterAudioUnit.h
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright (c) 2016 Aurelius Prochazka. All rights reserved.
//

#ifndef AKHighShelfParametricEqualizerFilterAudioUnit_h
#define AKHighShelfParametricEqualizerFilterAudioUnit_h

#import <AudioToolbox/AudioToolbox.h>

@interface AKHighShelfParametricEqualizerFilterAudioUnit : AUAudioUnit
@property (nonatomic) float centerFrequency;
@property (nonatomic) float gain;
@property (nonatomic) float q;

- (void)start;
- (void)stop;
- (BOOL)isPlaying;
- (void)setUpParameterRamp;
- (BOOL)isSetUp;

@property double rampTime;

@end

#endif /* AKHighShelfParametricEqualizerFilterAudioUnit_h */
