//
//  AKMorphingOscillatorAudioUnit.mm
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright © 2017 Aurelius Prochazka. All rights reserved.
//

#import "AKMorphingOscillatorAudioUnit.h"
#import "AKMorphingOscillatorDSPKernel.hpp"

#import "BufferedAudioBus.hpp"

#import <AudioKit/AudioKit-Swift.h>

@implementation AKMorphingOscillatorAudioUnit {
    // C++ members need to be ivars; they would be copied on access if they were properties.
    AKMorphingOscillatorDSPKernel _kernel;
    BufferedOutputBus _outputBusBuffer;
}
@synthesize parameterTree = _parameterTree;

- (void)setFrequency:(float)frequency {
    _kernel.setFrequency(frequency);
}
- (void)setAmplitude:(float)amplitude {
    _kernel.setAmplitude(amplitude);
}
- (void)setIndex:(float)index {
    _kernel.setIndex(index);
}
- (void)setDetuningOffset:(float)detuningOffset {
    _kernel.setDetuningOffset(detuningOffset);
}
- (void)setDetuningMultiplier:(float)detuningMultiplier {
    _kernel.setDetuningMultiplier(detuningMultiplier);
}

- (void)setupWaveform:(UInt32)waveform size:(int)size {
    _kernel.setupWaveform(waveform, (uint32_t)size);
}

- (void)setWaveform:(UInt32)waveform withValue:(float)value atIndex:(UInt32)index {
    _kernel.setWaveformValue(waveform, index, value);
}

standardKernelPassthroughs()

- (void)createParameters {

    standardGeneratorSetup(MorphingOscillator)

    // Create a parameter object for the frequency.
    AUParameter *frequencyAUParameter = [AUParameter frequency:@"frequency"
                                                          name:@"Frequency (in Hz)"
                                                       address:frequencyAddress];
    // Create a parameter object for the amplitude.
    AUParameter *amplitudeAUParameter = [AUParameter parameter:@"amplitude"
                                                          name:@"Amplitude (typically a value between 0 and 1)."
                                                       address:amplitudeAddress
                                                           min:0.0
                                                           max:1.0
                                                          unit:kAudioUnitParameterUnit_Hertz];
    // Create a parameter object for the index.
    AUParameter *indexAUParameter = [AUParameter parameter:@"index"
                                                      name:@"Index of the wavetable to use (fractional are okay)."
                                                   address:indexAddress
                                                       min:0.0
                                                       max:1000.0
                                                      unit:kAudioUnitParameterUnit_Hertz];
    // Create a parameter object for the detuningOffset.
    AUParameter *detuningOffsetAUParameter = [AUParameter parameter:@"detuningOffset"
                                                               name:@"Frequency offset (Hz)"
                                                            address:detuningOffsetAddress
                                                                min:-1000.0
                                                                max:1000.0
                                                               unit:kAudioUnitParameterUnit_Hertz];

    // Create a parameter object for the detuningMultiplier.
    AUParameter *detuningMultiplierAUParameter = [AUParameter parameter:@"detuningMultiplier"
                                                                   name:@"Frequency detuning multiplier"
                                                                address:detuningMultiplierAddress
                                                                    min:0.0
                                                                    max:FLT_MAX
                                                                   unit:kAudioUnitParameterUnit_Generic];

    // Initialize the parameter values.
    frequencyAUParameter.value = 440;
    amplitudeAUParameter.value = 0.5;
    indexAUParameter.value = 0.0;
    detuningOffsetAUParameter.value = 0;
    detuningMultiplierAUParameter.value = 1;


    _kernel.setParameter(frequencyAddress,          frequencyAUParameter.value);
    _kernel.setParameter(amplitudeAddress,          amplitudeAUParameter.value);
    _kernel.setParameter(indexAddress,              indexAUParameter.value);
    _kernel.setParameter(detuningOffsetAddress,     detuningOffsetAUParameter.value);
    _kernel.setParameter(detuningMultiplierAddress, detuningMultiplierAUParameter.value);

    // Create the parameter tree.
    _parameterTree = [AUParameterTree tree:@[
        frequencyAUParameter,
        amplitudeAUParameter,
        indexAUParameter,
        detuningOffsetAUParameter,
        detuningMultiplierAUParameter
    ]];

	parameterTreeBlock(MorphingOscillator)
}

AUAudioUnitGeneratorOverrides(MorphingOscillator)

@end


