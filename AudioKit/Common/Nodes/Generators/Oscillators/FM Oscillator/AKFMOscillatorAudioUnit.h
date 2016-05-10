//
//  AKFMOscillatorAudioUnit.h
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright (c) 2016 Aurelius Prochazka. All rights reserved.
//

#ifndef AKFMOscillatorAudioUnit_h
#define AKFMOscillatorAudioUnit_h

#import <AudioToolbox/AudioToolbox.h>

@interface AKFMOscillatorAudioUnit : AUAudioUnit
@property (nonatomic) float baseFrequency;
@property (nonatomic) float carrierMultiplier;
@property (nonatomic) float modulatingMultiplier;
@property (nonatomic) float modulationIndex;
@property (nonatomic) float amplitude;

- (void)setupWaveform:(int)size;
- (void)setWaveformValue:(float)value atIndex:(UInt32)index;
- (void)start;
- (void)stop;
- (BOOL)isPlaying;
- (void)setUpParameterRamp;
- (BOOL)isSetUp;

@property double rampTime;

@end

#endif /* AKFMOscillatorAudioUnit_h */
