//
//  AKFluteAudioUnit.mm
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright (c) 2016 Aurelius Prochazka. All rights reserved.
//

#import "AKFluteAudioUnit.h"
#import "AKFluteDSPKernel.hpp"

#import "BufferedAudioBus.hpp"

#import <AudioKit/AudioKit-Swift.h>

@implementation AKFluteAudioUnit {
    // C++ members need to be ivars; they would be copied on access if they were properties.
    AKFluteDSPKernel _kernel;
    BufferedInputBus _inputBus;
}
@synthesize parameterTree = _parameterTree;

- (void)setFrequency:(float)frequency {
    _kernel.setFrequency(frequency);
}
- (void)setAmplitude:(float)amplitude {
    _kernel.setAmplitude(amplitude);
}

- (void)triggerFrequency:(float)frequency amplitude:(float)amplitude {
    _kernel.setFrequency(frequency);
    _kernel.setAmplitude(amplitude);
    _kernel.trigger();
}

standardKernelPassthroughs()

- (void)createParameters {

    standardSetup(Flute)

    // Create a parameter object for the frequency.
    AUParameter *frequencyAUParameter = [AUParameter parameter:@"frequency"
                                                          name:@"Variable frequency. Values less than the initial frequency  will be doubled until it is greater than that."
                                                       address:frequencyAddress
                                                           min:0
                                                           max:22000
                                                          unit:kAudioUnitParameterUnit_Hertz];
    // Create a parameter object for the amplitude.
    AUParameter *amplitudeAUParameter = [AUParameter parameter:@"amplitude"
                                                          name:@"Amplitude"
                                                       address:amplitudeAddress
                                                           min:0
                                                           max:1
                                                          unit:kAudioUnitParameterUnit_Generic];

    // Initialize the parameter values.
    frequencyAUParameter.value = 110;
    amplitudeAUParameter.value = 0.5;


    _kernel.setParameter(frequencyAddress,       frequencyAUParameter.value);
    _kernel.setParameter(amplitudeAddress,       amplitudeAUParameter.value);

    // Create the parameter tree.
    _parameterTree = [AUParameterTree createTreeWithChildren:@[
        frequencyAUParameter,
        amplitudeAUParameter
    ]];
	parameterTreeBlock(Flute)
}

AUAudioUnitGeneratorOverrides(Flute)

@end


