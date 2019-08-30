//
//  AKFilterSynthAudioUnit.mm
//  AudioKit
//
//  Created by Colin Hallett, revision history on GitHub.
//  Copyright © 2019 AudioKit. All rights reserved.
//

#import "AKFilterSynthAudioUnit.h"
#import "AKFilterSynthDSPKernel.hpp"

@implementation AKFilterSynthAudioUnit {
    AKFilterSynthDSPKernel *kernelPtr;
}

- (void)setKernelPtr:(void *)ptr {
    kernelPtr = (AKFilterSynthDSPKernel *)ptr;
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
- (void)setFilterLFODepth:(float)filterLFODepth {
    kernelPtr->setFilterLFODepth(filterLFODepth);}
- (void)setFilterLFORate:(float)filterLFORate {
    kernelPtr->setFilterLFORate(filterLFORate);}


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
                                           address:AKFilterSynthDSPKernel::attackDurationAddress
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
                                           address:AKFilterSynthDSPKernel::decayDurationAddress
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
                                           address:AKFilterSynthDSPKernel::sustainLevelAddress
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
                                           address:AKFilterSynthDSPKernel::releaseDurationAddress
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
                                           address:AKFilterSynthDSPKernel::pitchBendAddress
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
                                           address:AKFilterSynthDSPKernel::vibratoDepthAddress
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
                                           address:AKFilterSynthDSPKernel::vibratoRateAddress
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
                                           address:AKFilterSynthDSPKernel::filterCutoffFrequencyAddress
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
                                           address:AKFilterSynthDSPKernel::filterResonanceAddress
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
                                           address:AKFilterSynthDSPKernel::filterAttackDurationAddress
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
                                           address:AKFilterSynthDSPKernel::filterDecayDurationAddress
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
                                           address:AKFilterSynthDSPKernel::filterSustainLevelAddress
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
                                           address:AKFilterSynthDSPKernel::filterReleaseDurationAddress
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
                                           address:AKFilterSynthDSPKernel::filterEnvelopeStrengthAddress
                                               min:0
                                               max:1
                                              unit:kAudioUnitParameterUnit_Generic
                                          unitName:nil
                                             flags:0
                                      valueStrings:nil
                               dependentParameters:nil];
    _filterLFODepthAUParameter =
    [AUParameterTree createParameterWithIdentifier:@"filterLFODepth"
                                              name:@"Filter LFO Depth"
                                           address:AKFilterSynthDSPKernel::filterLFODepthAddress
                                               min:0
                                               max:1
                                              unit:kAudioUnitParameterUnit_Generic
                                          unitName:nil
                                             flags:0
                                      valueStrings:nil
                               dependentParameters:nil];
    _filterLFORateAUParameter =
    [AUParameterTree createParameterWithIdentifier:@"filterLFORate"
                                              name:@"Filter LFO Rate"
                                           address:AKFilterSynthDSPKernel::filterLFORateAddress
                                               min:0
                                               max:600
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
    _filterLFODepthAUParameter.value = 0.0;
    _filterLFORateAUParameter.value = 0.0;
    
    kernelPtr->setParameter(AKFilterSynthDSPKernel::attackDurationAddress,  _attackDurationAUParameter.value);
    kernelPtr->setParameter(AKFilterSynthDSPKernel::decayDurationAddress,   _decayDurationAUParameter.value);
    kernelPtr->setParameter(AKFilterSynthDSPKernel::sustainLevelAddress,    _sustainLevelAUParameter.value);
    kernelPtr->setParameter(AKFilterSynthDSPKernel::releaseDurationAddress, _releaseDurationAUParameter.value);
    kernelPtr->setParameter(AKFilterSynthDSPKernel::pitchBendAddress,       _pitchBendAUParameter.value);
    kernelPtr->setParameter(AKFilterSynthDSPKernel::vibratoDepthAddress,    _vibratoDepthAUParameter.value);
    kernelPtr->setParameter(AKFilterSynthDSPKernel::vibratoRateAddress,     _vibratoRateAUParameter.value);
    kernelPtr->setParameter(AKFilterSynthDSPKernel::filterCutoffFrequencyAddress,       _filterCutoffFrequencyAUParameter.value);
    kernelPtr->setParameter(AKFilterSynthDSPKernel::filterResonanceAddress,     _filterResonanceAUParameter.value);
    kernelPtr->setParameter(AKFilterSynthDSPKernel::filterAttackDurationAddress,     _filterAttackDurationAUParameter.value);
    kernelPtr->setParameter(AKFilterSynthDSPKernel::filterDecayDurationAddress,     _filterDecayDurationAUParameter.value);
    kernelPtr->setParameter(AKFilterSynthDSPKernel::filterSustainLevelAddress,     _filterSustainLevelAUParameter.value);
    kernelPtr->setParameter(AKFilterSynthDSPKernel::filterReleaseDurationAddress,     _filterReleaseDurationAUParameter.value);
    kernelPtr->setParameter(AKFilterSynthDSPKernel::filterEnvelopeStrengthAddress,     _filterEnvelopeStrengthAUParameter.value);
    kernelPtr->setParameter(AKFilterSynthDSPKernel::filterLFODepthAddress,    _filterLFODepthAUParameter.value);
    kernelPtr->setParameter(AKFilterSynthDSPKernel::filterLFORateAddress,     _filterLFORateAUParameter.value);
    
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
             _filterEnvelopeStrengthAUParameter,
             _filterLFODepthAUParameter,
             _filterLFORateAUParameter]
    ;
}

@end
