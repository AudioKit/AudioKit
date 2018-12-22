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

@property AUParameter *attackDurationAUParameter;
@property AUParameter *decayDurationAUParameter;
@property AUParameter *sustainLevelAUParameter;
@property AUParameter *releaseDurationAUParameter;
@property AUParameter *pitchBendAUParameter;
@property AUParameter *vibratoDepthAUParameter;
@property AUParameter *vibratoRateAUParameter;

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

- (NSArray *)getStandardParameters;

@end

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

#define standardBankKernelSetParameters() \
_kernel.setParameter(AKBankDSPKernel::attackDurationAddress,  [self attackDurationAUParameter].value); \
_kernel.setParameter(AKBankDSPKernel::decayDurationAddress,   [self decayDurationAUParameter].value); \
_kernel.setParameter(AKBankDSPKernel::sustainLevelAddress,    [self sustainLevelAUParameter].value); \
_kernel.setParameter(AKBankDSPKernel::releaseDurationAddress, [self releaseDurationAUParameter].value); \
_kernel.setParameter(AKBankDSPKernel::pitchBendAddress,       [self pitchBendAUParameter].value); \
_kernel.setParameter(AKBankDSPKernel::vibratoDepthAddress,    [self vibratoDepthAUParameter].value);\
_kernel.setParameter(AKBankDSPKernel::vibratoRateAddress,     [self vibratoRateAUParameter].value);
