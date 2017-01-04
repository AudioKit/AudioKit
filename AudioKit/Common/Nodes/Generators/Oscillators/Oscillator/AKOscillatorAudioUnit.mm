//
//  AKOscillatorAudioUnit.mm
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright (c) 2016 Aurelius Prochazka. All rights reserved.
//

#import "AKOscillatorAudioUnit.h"
#import "AKOscillatorDSPKernel.hpp"

#import "BufferedAudioBus.hpp"

#import <AudioKit/AudioKit-Swift.h>

@implementation AKOscillatorAudioUnit {
    // C++ members need to be ivars; they would be copied on access if they were properties.
    AKOscillatorDSPKernel _kernel;
    BufferedInputBus _inputBus;
}
@synthesize parameterTree = _parameterTree;

- (void)setFrequency:(float)frequency {
    _kernel.setFrequency(frequency);
}
- (void)setAmplitude:(float)amplitude {
    _kernel.setAmplitude(amplitude);
}
- (void)setDetuningOffset:(float)detuningOffset {
    _kernel.setDetuningOffset(detuningOffset);
}
- (void)setDetuningMultiplier:(float)detuningMultiplier {
    _kernel.setDetuningMultiplier(detuningMultiplier);
}

- (void)setupWaveform:(int)size {
    _kernel.setupWaveform((uint32_t)size);
}
- (void)setWaveformValue:(float)value atIndex:(UInt32)index; {
    _kernel.setWaveformValue(index, value);
}

standardKernelPassthroughs()

- (void)createParameters {

    standardSetup(Oscillator)

    // Create a parameter object for the frequency.
    AUParameter *frequencyAUParameter = [AUParameter parameter:@"frequency"
                                                          name:@"Frequency (Hz)"
                                                       address:frequencyAddress
                                                           min:0
                                                           max:20000
                                                          unit:kAudioUnitParameterUnit_Hertz];
    // Create a parameter object for the amplitude.
    AUParameter *amplitudeAUParameter = [AUParameter parameter:@"amplitude"
                                                          name:@"Amplitude"
                                                       address:amplitudeAddress
                                                           min:0
                                                           max:10
                                                          unit:kAudioUnitParameterUnit_Generic];
    // Create a parameter object for the detuningOffset.
    AUParameter *detuningOffsetAUParameter = [AUParameter parameter:@"detuningOffset"
                                                               name:@"Frequency offset (Hz)"
                                                            address:detuningOffsetAddress
                                                                min:-1000
                                                                max:1000
                                                               unit:kAudioUnitParameterUnit_Hertz];
    // Create a parameter object for the detuningMultiplier.
    AUParameter *detuningMultiplierAUParameter = [AUParameter parameter:@"detuningMultiplier"
                                                                   name:@"Frequency detuning multiplier"
                                                                address:detuningMultiplierAddress
                                                                    min:0.5
                                                                    max:2.0
                                                                   unit:kAudioUnitParameterUnit_Generic];

    // Initialize the parameter values.
    frequencyAUParameter.value = 440;
    amplitudeAUParameter.value = 1;
    detuningOffsetAUParameter.value = 0;
    detuningMultiplierAUParameter.value = 1;

    _kernel.setParameter(frequencyAddress,          frequencyAUParameter.value);
    _kernel.setParameter(amplitudeAddress,          amplitudeAUParameter.value);
    _kernel.setParameter(detuningOffsetAddress,     detuningOffsetAUParameter.value);
    _kernel.setParameter(detuningMultiplierAddress, detuningMultiplierAUParameter.value);

    // Create the parameter tree.
    _parameterTree = [AUParameterTree createTreeWithChildren:@[
        frequencyAUParameter,
        amplitudeAUParameter,
        detuningOffsetAUParameter,
        detuningMultiplierAUParameter
    ]];
	parameterTreeBlock(Oscillator)
}

AUAudioUnitGeneratorOverrides(Oscillator)

@end


