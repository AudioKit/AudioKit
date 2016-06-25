//
//  AKMorphingPolyphonicOscillatorAudioUnit.h
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright (c) 2016 Aurelius Prochazka. All rights reserved.
//

#ifndef AKMorphingPolyphonicOscillatorAudioUnit_h
#define AKMorphingPolyphonicOscillatorAudioUnit_h

#import <AudioToolbox/AudioToolbox.h>

@interface AKMorphingPolyphonicOscillatorAudioUnit : AUAudioUnit

@property (nonatomic) float index;

@property (nonatomic) float attackDuration;
@property (nonatomic) float releaseDuration;
@property (nonatomic) float detuningOffset;
@property (nonatomic) float detuningMultiplier;

- (void)setupWaveform:(UInt32)waveform size:(int)size;
- (void)setWaveform:(UInt32)waveform withValue:(float)value atIndex:(UInt32)index;
- (void)startNote:(int)note velocity:(int)velocity;
- (void)stopNote:(int)note;
- (void)setUpParameterRamp;
- (BOOL)isSetUp;

@property double rampTime;

@end

#endif /* AKMorphingPolyphonicOscillatorAudioUnit_h */
