//
//  AKSquareWaveOscillatorAudioUnit.h
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright (c) 2016 Aurelius Prochazka. All rights reserved.
//

#ifndef AKSquareWaveOscillatorAudioUnit_h
#define AKSquareWaveOscillatorAudioUnit_h

#import <AudioToolbox/AudioToolbox.h>

@interface AKSquareWaveOscillatorAudioUnit : AUAudioUnit
@property (nonatomic) float frequency;
@property (nonatomic) float amplitude;
@property (nonatomic) float pulseWidth;
@property (nonatomic) float detuningOffset;
@property (nonatomic) float detuningMultiplier;

- (void)start;
- (void)stop;
- (BOOL)isPlaying;
- (void)setUpParameterRamp;
- (BOOL)isSetUp;

@property double rampTime;

@end

#endif /* AKSquareWaveOscillatorAudioUnit_h */
