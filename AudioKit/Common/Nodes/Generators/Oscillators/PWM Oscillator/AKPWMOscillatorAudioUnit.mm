//
//  AKPWMOscillatorAudioUnit.mm
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright (c) 2017 Aurelius Prochazka. All rights reserved.
//

#import "AKPWMOscillatorAudioUnit.h"
#import "AKPWMOscillatorDSPKernel.hpp"

#import "BufferedAudioBus.hpp"

#import <AudioKit/AudioKit-Swift.h>

@implementation AKPWMOscillatorAudioUnit {
    // C++ members need to be ivars; they would be copied on access if they were properties.
    AKPWMOscillatorDSPKernel _kernel;
    BufferedInputBus _inputBus;
}
@synthesize parameterTree = _parameterTree;

- (void)setFrequency:(float)frequency {
    _kernel.setFrequency(frequency);
}
- (void)setAmplitude:(float)amplitude {
    _kernel.setAmplitude(amplitude);
}
- (void)setPulseWidth:(float)pulseWidth {
    _kernel.setPulseWidth(pulseWidth);
}
- (void)setDetuningOffset:(float)detuningOffset {
    _kernel.setDetuningOffset(detuningOffset);
}
- (void)setDetuningMultiplier:(float)detuningMultiplier {
    _kernel.setDetuningMultiplier(detuningMultiplier);
}

standardKernelPassthroughs()

- (void)createParameters {

    standardSetup(PWMOscillator)

    // Create a parameter object for the frequency.
    AUParameter *frequencyAUParameter = [AUParameter frequency:@"frequency"
                                                          name:@"Frequency (Hz)"
                                                       address:frequencyAddress];
    // Create a parameter object for the amplitude.
    AUParameter *amplitudeAUParameter = [AUParameter parameter:@"amplitude"
                                                          name:@"Amplitude"
                                                       address:amplitudeAddress
                                                           min:0.0
                                                           max:10.0
                                                          unit:kAudioUnitParameterUnit_Hertz];
    // Create a parameter object for the pulseWidth.
    AUParameter *pulseWidthAUParameter = [AUParameter parameter:@"pulseWidth"
                                                           name:@"Pulse Width"
                                                        address:pulseWidthAddress
                                                            min:0.0
                                                            max:1.0
                                                           unit:kAudioUnitParameterUnit_Generic];
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
                                                                    min:0.5
                                                                    max:2.0
                                                                   unit:kAudioUnitParameterUnit_Generic];

    // Initialize the parameter values.
    frequencyAUParameter.value = 440;
    amplitudeAUParameter.value = 1.0;
    pulseWidthAUParameter.value = 0.5;
    detuningOffsetAUParameter.value = 0;
    detuningMultiplierAUParameter.value = 1;

    _kernel.setParameter(frequencyAddress,          frequencyAUParameter.value);
    _kernel.setParameter(amplitudeAddress,          amplitudeAUParameter.value);
    _kernel.setParameter(pulseWidthAddress,         pulseWidthAUParameter.value);
    _kernel.setParameter(detuningOffsetAddress,     detuningOffsetAUParameter.value);
    _kernel.setParameter(detuningMultiplierAddress, detuningMultiplierAUParameter.value);

    // Create the parameter tree.
    _parameterTree = [AUParameterTree tree:@[
        frequencyAUParameter,
        amplitudeAUParameter,
        pulseWidthAUParameter,
        detuningOffsetAUParameter,
        detuningMultiplierAUParameter
    ]];

	parameterTreeBlock(PWMOscillator)
}

AUAudioUnitGeneratorOverrides(PWMOscillator)

@end


