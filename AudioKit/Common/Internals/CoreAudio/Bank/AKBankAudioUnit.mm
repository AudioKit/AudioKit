//
//  AKBankAudioUnit.mm
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on GitHub.
//  Copyright © 2018 AudioKit. All rights reserved.
//

#import "AKBankAudioUnit.h"
#import "AKBankDSPKernel.hpp"

@implementation AKBankAudioUnit 

- (BOOL)isSetUp { return NO; }
- (void)setAttackDuration:(float)attackDuration {};
- (void)setDecayDuration:(float)decayDuration {};
- (void)setSustainLevel:(float)sustainLevel {};
- (void)setReleaseDuration:(float)releaseDuration {};
- (void)setPitchBend:(float)pitchBend {} ;
- (void)setVibratoDepth:(float)vibratoDepth {};
- (void)setVibratoRate:(float)vibratoRate {};

- (void)stopNote:(uint8_t)note {};
- (void)startNote:(uint8_t)note velocity:(uint8_t)velocity {};
- (void)startNote:(uint8_t)note velocity:(uint8_t)velocity frequency:(float)frequency {};

- (NSArray *)getStandardParameters {
    AudioUnitParameterOptions flags = kAudioUnitParameterFlag_IsWritable | kAudioUnitParameterFlag_IsReadable | kAudioUnitParameterFlag_DisplayLogarithmic;
    _attackDurationAUParameter =
    [AUParameterTree createParameterWithIdentifier:@"attackDuration"
                                              name:@"Attack"
                                           address:AKBankDSPKernel::attackDurationAddress
                                               min:0
                                               max:1
                                              unit:kAudioUnitParameterUnit_Seconds
                                          unitName:nil
                                             flags:flags
                                      valueStrings:nil
                               dependentParameters:nil];
    _decayDurationAUParameter =
    [AUParameterTree createParameterWithIdentifier:@"decayDuration"
                                              name:@"Decay"
                                           address:AKBankDSPKernel::decayDurationAddress
                                               min:0
                                               max:1
                                              unit:kAudioUnitParameterUnit_Seconds
                                          unitName:nil
                                             flags:flags
                                      valueStrings:nil
                               dependentParameters:nil];
    _sustainLevelAUParameter =
    [AUParameterTree createParameterWithIdentifier:@"sustainLevel"
                                              name:@"Sustain Level"
                                           address:AKBankDSPKernel::sustainLevelAddress
                                               min:0
                                               max:1
                                              unit:kAudioUnitParameterUnit_Generic
                                          unitName:nil
                                             flags:flags
                                      valueStrings:nil
                               dependentParameters:nil];
    _releaseDurationAUParameter =
    [AUParameterTree createParameterWithIdentifier:@"releaseDuration"
                                              name:@"Release"
                                           address:AKBankDSPKernel::releaseDurationAddress
                                               min:0
                                               max:1
                                              unit:kAudioUnitParameterUnit_Seconds
                                          unitName:nil
                                             flags:flags
                                      valueStrings:nil
                               dependentParameters:nil];
    _pitchBendAUParameter =
    [AUParameterTree createParameterWithIdentifier:@"pitchBend"
                                              name:@"Pitch Bend"
                                           address:AKBankDSPKernel::pitchBendAddress
                                               min:-48
                                               max:48
                                              unit:kAudioUnitParameterUnit_RelativeSemiTones
                                          unitName:nil
                                             flags:0
                                      valueStrings:nil
                               dependentParameters:nil];
    _vibratoDepthAUParameter =
    [AUParameterTree createParameterWithIdentifier:@"vibratoDepth"
                                              name:@"Vibrato Depth"
                                           address:AKBankDSPKernel::vibratoDepthAddress
                                               min:0
                                               max:24
                                              unit:kAudioUnitParameterUnit_RelativeSemiTones
                                          unitName:nil
                                             flags:0
                                      valueStrings:nil
                               dependentParameters:nil];
    _vibratoRateAUParameter =
    [AUParameterTree createParameterWithIdentifier:@"vibratoRate"
                                              name:@"Vibrato Rate"
                                           address:AKBankDSPKernel::vibratoRateAddress
                                               min:0
                                               max:600
                                              unit:kAudioUnitParameterUnit_Hertz
                                          unitName:nil
                                             flags:0
                                      valueStrings:nil
                               dependentParameters:nil];
    _attackDurationAUParameter.value = 0.1;
    _decayDurationAUParameter.value = 0.1;
    _sustainLevelAUParameter.value = 1.0;
    _releaseDurationAUParameter.value = 0.1;
    _pitchBendAUParameter.value = 0;
    _vibratoDepthAUParameter.value = 0;
    _vibratoRateAUParameter.value = 0;

    return @[_attackDurationAUParameter,
             _decayDurationAUParameter,
             _sustainLevelAUParameter,
             _releaseDurationAUParameter,
             _pitchBendAUParameter,
             _vibratoDepthAUParameter,
             _vibratoRateAUParameter];
}

@end
