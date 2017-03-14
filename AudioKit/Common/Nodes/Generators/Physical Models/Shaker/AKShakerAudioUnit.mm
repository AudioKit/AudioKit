//
//  AKShakerAudioUnit.mm
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright © 2017 Aurelius Prochazka. All rights reserved.
//

#import "AKShakerAudioUnit.h"
#import "AKShakerDSPKernel.hpp"

#import "BufferedAudioBus.hpp"

#import <AudioKit/AudioKit-Swift.h>

@implementation AKShakerAudioUnit {
    // C++ members need to be ivars; they would be copied on access if they were properties.
    AKShakerDSPKernel _kernel;
    BufferedInputBus _inputBus;
}

@synthesize parameterTree = _parameterTree;

- (void)setType:(UInt8)type {
    _kernel.setType(type);
}

- (void)setAmplitude:(float)amplitude {
    _kernel.setAmplitude(amplitude);
}

- (void)triggerType:(UInt8)type Amplitude:(float)amplitude {
    _kernel.setType(type);
    _kernel.setAmplitude(amplitude);
    _kernel.trigger();
}

standardKernelPassthroughs()

- (void)createParameters {

    standardSetup(Shaker)

    // Create a parameter object for the amplitude.
    AUParameter *amplitudeAUParameter = [AUParameter parameter:@"amplitude"
                                                          name:@"Amplitude"
                                                       address:amplitudeAddress
                                                           min:0
                                                           max:1
                                                          unit:kAudioUnitParameterUnit_Generic];

    // Initialize the parameter values.
    amplitudeAUParameter.value = 0.5;

    _kernel.setParameter(amplitudeAddress,       amplitudeAUParameter.value);

    // Create the parameter tree.
    _parameterTree = [AUParameterTree createTreeWithChildren:@[amplitudeAUParameter]];

	parameterTreeBlock(Shaker)
}

AUAudioUnitGeneratorOverrides(Shaker)

@end


