//
//  AKWhiteNoiseAudioUnit.mm
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright (c) 2016 Aurelius Prochazka. All rights reserved.
//

#import "AKWhiteNoiseAudioUnit.h"
#import "AKWhiteNoiseDSPKernel.hpp"

#import "BufferedAudioBus.hpp"

#import <AudioKit/AudioKit-Swift.h>

@implementation AKWhiteNoiseAudioUnit {
    // C++ members need to be ivars; they would be copied on access if they were properties.
    AKWhiteNoiseDSPKernel _kernel;
    BufferedInputBus _inputBus;
}
@synthesize parameterTree = _parameterTree;

- (void)setAmplitude:(float)amplitude {
    _kernel.setAmplitude(amplitude);
}

standardKernelPassthroughs()

- (void)createParameters {

    standardSetup(WhiteNoise)

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

    // A function to provide string representations of parameter values.
    _parameterTree.implementorStringFromValueCallback = ^(AUParameter *param, const AUValue *__nullable valuePtr) {
        AUValue value = valuePtr == nil ? param.value : *valuePtr;

        switch (param.address) {
            case amplitudeAddress:
                return [NSString stringWithFormat:@"%.3f", value];
            default:
                return @"?";
        }
    };

	parameterTreeBlock(WhiteNoise)
}

AUAudioUnitGeneratorOverrides(WhiteNoise)

@end


