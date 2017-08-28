//
//  AKBankAudioUnit.h
//  AudioKit
//
//  Created by Aurelius Prochazka on 8/15/17.
//  Copyright © 2017 AudioKit. All rights reserved.
//

#pragma once

#import "AKAudioUnit.h"

@interface AKBankAudioUnit : AKAudioUnit

@property (nonatomic) float attackDuration;
@property (nonatomic) float decayDuration;
@property (nonatomic) float sustainLevel;
@property (nonatomic) float releaseDuration;
@property (nonatomic) float detuningOffset;
@property (nonatomic) float detuningMultiplier;

- (void)startNote:(uint8_t)note velocity:(uint8_t)velocity;
- (void)startNote:(uint8_t)note velocity:(uint8_t)velocity frequency:(float)frequency;
- (void)stopNote:(uint8_t)note;

@end

#define numberOfBankEnumElements 7

#define standardBankEnumElements() \
    attackDurationAddress = 0, \
    decayDurationAddress = 1, \
    sustainLevelAddress = 2, \
    releaseDurationAddress = 3, \
    detuningOffsetAddress = 4, \
    detuningMultiplierAddress = 5

#define standardBankAUParameterList() \
    attackDurationAUParameter, \
    decayDurationAUParameter, \
    sustainLevelAUParameter, \
    releaseDurationAUParameter, \
    detuningOffsetAUParameter, \
    detuningMultiplierAUParameter

#define standardBankFunctions() \
- (BOOL)isSetUp { return _kernel.resetted; } \
- (void)setAttackDuration:(float)attackDuration { _kernel.setAttackDuration(attackDuration); } \
- (void)setDecayDuration:(float)decayDuration { _kernel.setDecayDuration(decayDuration); } \
- (void)setSustainLevel:(float)sustainLevel { _kernel.setSustainLevel(sustainLevel); } \
- (void)setReleaseDuration:(float)releaseDuration { _kernel.setReleaseDuration(releaseDuration); } \
- (void)setDetuningOffset:(float)detuningOffset { _kernel.setDetuningOffset(detuningOffset); } \
- (void)setDetuningMultiplier:(float)detuningMultiplier { _kernel.setDetuningMultiplier(detuningMultiplier); } \
- (void)stopNote:(uint8_t)note { _kernel.stopNote(note); } \
- (void)startNote:(uint8_t)note velocity:(uint8_t)velocity { _kernel.startNote(note, velocity); } \
- (void)startNote:(uint8_t)note velocity:(uint8_t)velocity frequency:(float)frequency { \
    _kernel.startNote(note, velocity, frequency); \
}

#define standardBankParameters() \
AudioUnitParameterOptions flags = kAudioUnitParameterFlag_IsWritable | kAudioUnitParameterFlag_IsReadable | kAudioUnitParameterFlag_DisplayLogarithmic;\
AUParameter *attackDurationAUParameter = \
[AUParameterTree createParameterWithIdentifier:@"attackDuration" \
                                          name:@"Attack" \
                                       address:attackDurationAddress \
                                           min:0 \
                                           max:1 \
                                          unit:kAudioUnitParameterUnit_Seconds \
                                      unitName:nil \
                                         flags:flags \
                                  valueStrings:nil \
                           dependentParameters:nil]; \
AUParameter *decayDurationAUParameter = \
[AUParameterTree createParameterWithIdentifier:@"decayDuration" \
                                          name:@"Decay" \
                                       address:decayDurationAddress \
                                           min:0 \
                                           max:1 \
                                          unit:kAudioUnitParameterUnit_Seconds \
                                      unitName:nil \
                                         flags:flags \
                                  valueStrings:nil \
                           dependentParameters:nil]; \
AUParameter *sustainLevelAUParameter = \
[AUParameterTree createParameterWithIdentifier:@"sustainLevel" \
                                          name:@"Sustain Level" \
                                       address:sustainLevelAddress \
                                           min:0 \
                                           max:1 \
                                          unit:kAudioUnitParameterUnit_Generic \
                                      unitName:nil \
                                         flags:flags \
                                  valueStrings:nil \
                           dependentParameters:nil]; \
AUParameter *releaseDurationAUParameter = \
[AUParameterTree createParameterWithIdentifier:@"releaseDuration" \
                                          name:@"Release" \
                                       address:releaseDurationAddress \
                                           min:0 \
                                           max:1 \
                                          unit:kAudioUnitParameterUnit_Seconds \
                                      unitName:nil \
                                         flags:flags \
                                  valueStrings:nil \
                           dependentParameters:nil]; \
AUParameter *detuningOffsetAUParameter = \
[AUParameterTree createParameterWithIdentifier:@"detuningOffset" \
                                          name:@"Detuning Offset" \
                                       address:detuningOffsetAddress \
                                           min:-1000 \
                                           max:1000 \
                                          unit:kAudioUnitParameterUnit_Hertz \
                                      unitName:nil \
                                         flags:0 \
                                  valueStrings:nil \
                           dependentParameters:nil]; \
AUParameter *detuningMultiplierAUParameter = \
[AUParameterTree createParameterWithIdentifier:@"detuningMultiplier" \
                                          name:@"Detuning Multiplier" \
                                       address:detuningMultiplierAddress \
                                           min:0.1 \
                                           max:2.0 \
                                          unit:kAudioUnitParameterUnit_Generic \
                                      unitName:nil \
                                         flags:0 \
                                  valueStrings:nil \
                           dependentParameters:nil]; \
attackDurationAUParameter.value = 0.1; \
decayDurationAUParameter.value = 0.1; \
sustainLevelAUParameter.value = 1.0; \
releaseDurationAUParameter.value = 0.1; \
detuningOffsetAUParameter.value = 0; \
detuningMultiplierAUParameter.value = 1; \
_kernel.setParameter(attackDurationAddress,  attackDurationAUParameter.value); \
_kernel.setParameter(decayDurationAddress,   decayDurationAUParameter.value); \
_kernel.setParameter(sustainLevelAddress,    sustainLevelAUParameter.value); \
_kernel.setParameter(releaseDurationAddress, releaseDurationAUParameter.value); \
_kernel.setParameter(detuningOffsetAddress,     detuningOffsetAUParameter.value); \
_kernel.setParameter(detuningMultiplierAddress, detuningMultiplierAUParameter.value);
