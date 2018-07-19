//
//  AKBankAudioUnit.h
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on GitHub.
//  Copyright © 2018 AudioKit. All rights reserved.
//

#pragma once

#import "AKAudioUnit.h"

@interface AKBankAudioUnit : AKAudioUnit

@property (nonatomic) float attackDuration;
@property (nonatomic) float decayDuration;
@property (nonatomic) float sustainLevel;
@property (nonatomic) float releaseDuration;
@property (nonatomic) float pitchBend;
@property (nonatomic) float vibratoDepth;
@property (nonatomic) float vibratoRate;

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
    pitchBendAddress = 4, \
    vibratoDepthAddress = 5, \
    vibratoRateAddress = 6

#define standardBankAUParameterList() \
    attackDurationAUParameter, \
    decayDurationAUParameter, \
    sustainLevelAUParameter, \
    releaseDurationAUParameter, \
    pitchBendAUParameter, \
    vibratoDepthAUParameter, \
    vibratoRateAUParameter

#define standardBankFunctions() \
- (BOOL)isSetUp { return _kernel.resetted; } \
- (void)setAttackDuration:(float)attackDuration { _kernel.setAttackDuration(attackDuration); } \
- (void)setDecayDuration:(float)decayDuration { _kernel.setDecayDuration(decayDuration); } \
- (void)setSustainLevel:(float)sustainLevel { _kernel.setSustainLevel(sustainLevel); } \
- (void)setReleaseDuration:(float)releaseDuration { _kernel.setReleaseDuration(releaseDuration); } \
- (void)setPitchBend:(float)pitchBend { _kernel.setPitchBend(pitchBend); } \
- (void)setVibratoDepth:(float)vibratoDepth { _kernel.setVibratoDepth(vibratoDepth); } \
- (void)setVibratoRate:(float)vibratoRate { _kernel.setVibratoRate(vibratoRate); } \
- (void)stopNote:(uint8_t)note { _kernel.stopNote(note); } \
- (void)startNote:(uint8_t)note velocity:(uint8_t)velocity { _kernel.startNote(note, velocity); } \
- (void)startNote:(uint8_t)note velocity:(uint8_t)velocity frequency:(float)frequency { \
    _kernel.startNote(note, velocity, frequency); \
}

#define standardBankParameters(__type) \
AudioUnitParameterOptions flags = kAudioUnitParameterFlag_IsWritable | kAudioUnitParameterFlag_IsReadable | kAudioUnitParameterFlag_DisplayLogarithmic;\
AUParameter *attackDurationAUParameter = \
[AUParameterTree createParameterWithIdentifier:@"attackDuration" \
                                          name:@"Attack" \
                                       address: __type::attackDurationAddress \
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
                                       address: __type::decayDurationAddress \
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
                                       address: __type::sustainLevelAddress \
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
                                       address: __type::releaseDurationAddress \
                                           min:0 \
                                           max:1 \
                                          unit:kAudioUnitParameterUnit_Seconds \
                                      unitName:nil \
                                         flags:flags \
                                  valueStrings:nil \
                           dependentParameters:nil]; \
AUParameter *pitchBendAUParameter = \
[AUParameterTree createParameterWithIdentifier:@"pitchBend" \
                                          name:@"Pitch Bend" \
                                       address: __type::pitchBendAddress \
                                           min:-48 \
                                           max:48 \
                                          unit:kAudioUnitParameterUnit_RelativeSemiTones \
                                      unitName:nil \
                                         flags:0 \
                                  valueStrings:nil \
                           dependentParameters:nil]; \
AUParameter *vibratoDepthAUParameter = \
[AUParameterTree createParameterWithIdentifier:@"vibratoDepth" \
                                          name:@"Vibrato Depth" \
                                       address: __type::vibratoDepthAddress \
                                           min:0 \
                                           max:24 \
                                          unit:kAudioUnitParameterUnit_RelativeSemiTones \
                                      unitName:nil \
                                         flags:0 \
                                  valueStrings:nil \
                           dependentParameters:nil]; \
AUParameter *vibratoRateAUParameter = \
[AUParameterTree createParameterWithIdentifier:@"vibratoRate" \
                                          name:@"Vibrato Rate" \
                                       address: __type::vibratoRateAddress \
                                           min:0 \
                                           max:600 \
                                          unit:kAudioUnitParameterUnit_Hertz \
                                      unitName:nil \
                                         flags:0 \
                                  valueStrings:nil \
                           dependentParameters:nil]; \
attackDurationAUParameter.value = 0.1; \
decayDurationAUParameter.value = 0.1; \
sustainLevelAUParameter.value = 1.0; \
releaseDurationAUParameter.value = 0.1; \
pitchBendAUParameter.value = 0; \
vibratoDepthAUParameter.value = 0; \
vibratoRateAUParameter.value = 0; \
_kernel.setParameter(__type::attackDurationAddress,  attackDurationAUParameter.value); \
_kernel.setParameter(__type::decayDurationAddress,   decayDurationAUParameter.value); \
_kernel.setParameter(__type::sustainLevelAddress,    sustainLevelAUParameter.value); \
_kernel.setParameter(__type::releaseDurationAddress, releaseDurationAUParameter.value); \
_kernel.setParameter(__type::pitchBendAddress,       pitchBendAUParameter.value); \
_kernel.setParameter(__type::vibratoDepthAddress,    vibratoDepthAUParameter.value);\
_kernel.setParameter(__type::vibratoRateAddress,     vibratoRateAUParameter.value);
