//
//  AKRhodesPianoAudioUnit.mm
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright © 2018 AudioKit. All rights reserved.
//

#import <AudioKit/AudioKit-Swift.h>

#import "AKRhodesPianoAudioUnit.h"
#import "AKRhodesPianoDSPKernel.hpp"

#import "BufferedAudioBus.hpp"

@implementation AKRhodesPianoAudioUnit {
    // C++ members need to be ivars; they would be copied on access if they were properties.
    AKRhodesPianoDSPKernel _kernel;
    BufferedOutputBus _outputBusBuffer;
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

    standardGeneratorSetup(RhodesPiano)

    // Create a parameter object for the frequency.
    AUParameter *frequencyAUParameter = [AUParameter frequency:@"frequency"
                                                          name:@"Variable frequency. Values less than the initial frequency  will be doubled until it is greater than that."
                                                       address:AKRhodesPianoDSPKernel::frequencyAddress];
    // Create a parameter object for the amplitude.
    AUParameter *amplitudeAUParameter = [AUParameter parameter:@"amplitude"
                                                          name:@"Amplitude"
                                                       address:AKRhodesPianoDSPKernel::amplitudeAddress
                                                           min:0
                                                           max:1
                                                          unit:kAudioUnitParameterUnit_Generic];

    // Initialize the parameter values.
    frequencyAUParameter.value = 110;
    amplitudeAUParameter.value = 0.5;

    _kernel.setParameter(AKRhodesPianoDSPKernel::frequencyAddress,       frequencyAUParameter.value);
    _kernel.setParameter(AKRhodesPianoDSPKernel::amplitudeAddress,       amplitudeAUParameter.value);

    // Create the parameter tree.
    _parameterTree = [AUParameterTree createTreeWithChildren:@[
                                                               frequencyAUParameter,
                                                               amplitudeAUParameter
                                                               ]];

    parameterTreeBlock(RhodesPiano)
}

AUAudioUnitGeneratorOverrides(RhodesPiano)

@end


