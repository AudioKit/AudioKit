//
//  AKPinkNoiseAudioUnit.mm
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright © 2017 Aurelius Prochazka. All rights reserved.
//

#import "AKPinkNoiseAudioUnit.h"
#import "AKPinkNoiseDSPKernel.hpp"

#import "BufferedAudioBus.hpp"

#import <AudioKit/AudioKit-Swift.h>

@implementation AKPinkNoiseAudioUnit {
    // C++ members need to be ivars; they would be copied on access if they were properties.
    AKPinkNoiseDSPKernel _kernel;
    BufferedOutputBus _outputBusBuffer;
}
@synthesize parameterTree = _parameterTree;

- (void)setAmplitude:(float)amplitude {
    _kernel.setAmplitude(amplitude);
}

standardKernelPassthroughs()

- (void)createParameters {

    standardGeneratorSetup(PinkNoise)

    // Create a parameter object for the amplitude.
    AUParameter *amplitudeAUParameter = [AUParameter parameter:@"amplitude"
                                                          name:@"Amplitude"
                                                       address:amplitudeAddress
                                                           min:0.0
                                                           max:1.0
                                                          unit:kAudioUnitParameterUnit_Generic];

    // Initialize the parameter values.
    amplitudeAUParameter.value = 1;

    _kernel.setParameter(amplitudeAddress, amplitudeAUParameter.value);

    // Create the parameter tree.
    _parameterTree = [AUParameterTree tree:@[
        amplitudeAUParameter
    ]];


	parameterTreeBlock(PinkNoise)
}

AUAudioUnitGeneratorOverrides(PinkNoise)

@end


