//
//  AKEqualizerFilterAudioUnit.h
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright (c) 2016 Aurelius Prochazka. All rights reserved.
//

#ifndef AKEqualizerFilterAudioUnit_h
#define AKEqualizerFilterAudioUnit_h

#import <AudioToolbox/AudioToolbox.h>

@interface AKEqualizerFilterAudioUnit : AUAudioUnit
@property (nonatomic) float centerFrequency;
@property (nonatomic) float bandwidth;
@property (nonatomic) float gain;

- (void)start;
- (void)stop;
- (BOOL)isPlaying;
- (void)setUpParameterRamp;
- (BOOL)isSetUp;

@property double rampTime;

@end

#endif /* AKEqualizerFilterAudioUnit_h */
