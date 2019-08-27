//
//  AKBankAudioUnit.mm
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on GitHub.
//  Copyright © 2018 AudioKit. All rights reserved.
//

#import "AKBankAudioUnit.h"
#import "AKBankDSPKernel.hpp"

@implementation AKBankAudioUnit {
    AKBankDSPKernel *kernelPtr;
}

- (void)setKernelPtr:(void *)ptr {
    kernelPtr = (AKBankDSPKernel *)ptr;
}

- (BOOL)isSetUp { return kernelPtr->resetted; }
- (void)setAttackDuration:(float)attackDuration { kernelPtr->setAttackDuration(attackDuration); }
- (void)setDecayDuration:(float)decayDuration { kernelPtr->setDecayDuration(decayDuration); }
- (void)setSustainLevel:(float)sustainLevel { kernelPtr->setSustainLevel(sustainLevel); }
- (void)setReleaseDuration:(float)releaseDuration { kernelPtr->setReleaseDuration(releaseDuration); }
- (void)setPitchBend:(float)pitchBend { kernelPtr->setPitchBend(pitchBend); }
- (void)setVibratoDepth:(float)vibratoDepth { kernelPtr->setVibratoDepth(vibratoDepth); }
- (void)setVibratoRate:(float)vibratoRate { kernelPtr->setVibratoRate(vibratoRate); }

- (void)setFilterCutoffFrequency:(float)filterCutoffFrequency{
    kernelPtr->setFilterCutoffFrequency(filterCutoffFrequency);}
- (void)setFilterResonance:(float)filterResonance {
    kernelPtr->setFilterResonance(filterResonance);}
- (void)setFilterAttackDuration:(float)filterAttackDuration {
    kernelPtr->setFilterAttackDuration(filterAttackDuration);}
- (void)setFilterDecayDuration:(float)filterDecayDuration {
    kernelPtr->setFilterDecayDuration(filterDecayDuration);}
- (void)setFilterSustainLevel:(float)filterSustainLevel {
    kernelPtr->setFilterSustainLevel(filterSustainLevel);}
- (void)setFilterReleaseDuration:(float)filterReleaseDuration {
    kernelPtr->setFilterReleaseDuration(filterReleaseDuration);}
- (void)setFilterEnvelopeStrength:(float)filterEnvelopeStrength {
    kernelPtr->setFilterEnvelopeStength(filterEnvelopeStrength);}

- (void)stopNote:(uint8_t)note { kernelPtr->stopNote(note); };

- (void)startNote:(uint8_t)note velocity:(uint8_t)velocity { kernelPtr->startNote(note, velocity); };

- (void)startNote:(uint8_t)note velocity:(uint8_t)velocity frequency:(float)frequency {
    kernelPtr->startNote(note, velocity, frequency);
};

- (NSArray *)standardParameters {
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
    
    _filterCutoffFrequencyAUParameter =
    [AUParameterTree createParameterWithIdentifier:@"filterCutoffFrequency"
                                              name:@"Filter Cutoff Frequency"
                                           address:AKBankDSPKernel::filterCutoffFrequencyAddress
                                               min:0.0
                                               max:22050.0
          unit:kAudioUnitParameterUnit_Generic
                                          unitName:nil
                                            flags:0
                                      valueStrings:nil
                               dependentParameters:nil];
    _filterResonanceAUParameter =
    [AUParameterTree createParameterWithIdentifier:@"filterResonance"
                                              name:@"Filter Resonance"
                                           address:AKBankDSPKernel::filterResonanceAddress
                                               min:0.0
                                               max:0.99
                                              unit:kAudioUnitParameterUnit_Generic
                                          unitName:nil
                                             flags:0
                                      valueStrings:nil
                               dependentParameters:nil];
    _filterAttackDurationAUParameter =
    [AUParameterTree createParameterWithIdentifier:@"filterAttackDuration"
                                              name:@"Filter Attack Duration"
                                           address:AKBankDSPKernel::filterAttackDurationAddress
                                               min:0
                                               max:1
                                              unit:kAudioUnitParameterUnit_Generic
                                          unitName:nil
                                             flags:0
                                      valueStrings:nil
                               dependentParameters:nil];
    _filterDecayDurationAUParameter =
    [AUParameterTree createParameterWithIdentifier:@"filterDecayDuration"
                                              name:@"Filter Decay Duration"
                                           address:AKBankDSPKernel::filterDecayDurationAddress
                                               min:0
                                               max:1
                                              unit:kAudioUnitParameterUnit_Generic
                                          unitName:nil
                                             flags:0
                                      valueStrings:nil
                               dependentParameters:nil];
    _filterSustainLevelAUParameter =
    [AUParameterTree createParameterWithIdentifier:@"filterSustainLevel"
                                              name:@"Filter Sustain Level"
                                           address:AKBankDSPKernel::filterSustainLevelAddress
                                               min:0
                                               max:1
                                              unit:kAudioUnitParameterUnit_Generic
                                          unitName:nil
                                             flags:0
                                      valueStrings:nil
                               dependentParameters:nil];
    _filterReleaseDurationAUParameter =
    [AUParameterTree createParameterWithIdentifier:@"filterReleaseDuration"
                                              name:@"Filter Release Duration"
                                           address:AKBankDSPKernel::filterReleaseDurationAddress
                                               min:0
                                               max:1
                                              unit:kAudioUnitParameterUnit_Generic
                                          unitName:nil
                                             flags:0
                                      valueStrings:nil
                               dependentParameters:nil];
    _filterEnvelopeStrengthAUParameter =
    [AUParameterTree createParameterWithIdentifier:@"filterEnvelopeStrength"
                                              name:@"Filter Envelope Strength"
                                           address:AKBankDSPKernel::filterEnvelopeStrengthAddress
                                               min:0
                                               max:1
                                              unit:kAudioUnitParameterUnit_Generic
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
    _filterCutoffFrequencyAUParameter.value = 0.1;
    _filterResonanceAUParameter.value = 0.0;
    _filterAttackDurationAUParameter.value = 0.1;
    _filterDecayDurationAUParameter.value = 0.1;
    _filterSustainLevelAUParameter.value = 1.0;
    _filterReleaseDurationAUParameter.value = 0.1;
    _filterEnvelopeStrengthAUParameter.value = 0.0;

    kernelPtr->setParameter(AKBankDSPKernel::attackDurationAddress,  _attackDurationAUParameter.value);
    kernelPtr->setParameter(AKBankDSPKernel::decayDurationAddress,   _decayDurationAUParameter.value);
    kernelPtr->setParameter(AKBankDSPKernel::sustainLevelAddress,    _sustainLevelAUParameter.value);
    kernelPtr->setParameter(AKBankDSPKernel::releaseDurationAddress, _releaseDurationAUParameter.value);
    kernelPtr->setParameter(AKBankDSPKernel::pitchBendAddress,       _pitchBendAUParameter.value);
    kernelPtr->setParameter(AKBankDSPKernel::vibratoDepthAddress,    _vibratoDepthAUParameter.value);
    kernelPtr->setParameter(AKBankDSPKernel::vibratoRateAddress,     _vibratoRateAUParameter.value);
    kernelPtr->setParameter(AKBankDSPKernel::filterCutoffFrequencyAddress,       _filterCutoffFrequencyAUParameter.value);
    kernelPtr->setParameter(AKBankDSPKernel::filterResonanceAddress,     _filterResonanceAUParameter.value);
    kernelPtr->setParameter(AKBankDSPKernel::filterAttackDurationAddress,     _filterAttackDurationAUParameter.value);
    kernelPtr->setParameter(AKBankDSPKernel::filterDecayDurationAddress,     _filterDecayDurationAUParameter.value);
    kernelPtr->setParameter(AKBankDSPKernel::filterSustainLevelAddress,     _filterSustainLevelAUParameter.value);
    kernelPtr->setParameter(AKBankDSPKernel::filterReleaseDurationAddress,     _filterReleaseDurationAUParameter.value);
    kernelPtr->setParameter(AKBankDSPKernel::filterEnvelopeStrengthAddress,     _filterEnvelopeStrengthAUParameter.value);

    return @[_attackDurationAUParameter,
             _decayDurationAUParameter,
             _sustainLevelAUParameter,
             _releaseDurationAUParameter,
             _pitchBendAUParameter,
             _vibratoDepthAUParameter,
             _vibratoRateAUParameter,
             _filterCutoffFrequencyAUParameter,
             _filterResonanceAUParameter,
             _filterAttackDurationAUParameter,
             _filterDecayDurationAUParameter,
             _filterSustainLevelAUParameter,
             _filterReleaseDurationAUParameter,
             _filterEnvelopeStrengthAUParameter]
    ;
}

@end
