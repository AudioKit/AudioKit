//
//  AKPeakingParametricEqualizerFilterAudioUnit.h
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright (c) 2016 Aurelius Prochazka. All rights reserved.
//

#ifndef AKPeakingParametricEqualizerFilterAudioUnit_h
#define AKPeakingParametricEqualizerFilterAudioUnit_h

#import <AudioToolbox/AudioToolbox.h>

@interface AKPeakingParametricEqualizerFilterAudioUnit : AUAudioUnit
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

#endif /* AKPeakingParametricEqualizerFilterAudioUnit_h */
