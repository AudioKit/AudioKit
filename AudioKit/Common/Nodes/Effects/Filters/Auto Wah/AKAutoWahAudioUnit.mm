//
//  AKAutoWahAudioUnit.mm
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright (c) 2017 Aurelius Prochazka. All rights reserved.
//

#import "AKAutoWahAudioUnit.h"
#import "AKAutoWahDSPKernel.hpp"

#import "BufferedAudioBus.hpp"

#import <AudioKit/AudioKit-Swift.h>

@implementation AKAutoWahAudioUnit {
    // C++ members need to be ivars; they would be copied on access if they were properties.
    AKAutoWahDSPKernel _kernel;
    BufferedInputBus _inputBus;
}
@synthesize parameterTree = _parameterTree;

- (void)setWah:(float)wah {
    _kernel.setWah(wah);
}
- (void)setMix:(float)mix {
    _kernel.setMix(mix);
}
- (void)setAmplitude:(float)amplitude {
    _kernel.setAmplitude(amplitude);
}

standardKernelPassthroughs()

- (void)createParameters {

    standardSetup(AutoWah)

    // Create a parameter object for the wah.
    AUParameter *wahAUParameter = [AUParameter parameter:@"wah"
                                                    name:@"Wah Amount"
                                                 address:wahAddress
                                                     min:0.0
                                                     max:1.0
                                                    unit:kAudioUnitParameterUnit_Generic];
    // Create a parameter object for the mix.
    AUParameter *mixAUParameter = [AUParameter parameter:@"mix"
                                                    name:@"Dry/Wet Mix"
                                                 address:mixAddress
                                                     min:0.0
                                                     max:1.0
                                                    unit:kAudioUnitParameterUnit_Percent];
    // Create a parameter object for the amplitude.
    AUParameter *amplitudeAUParameter = [AUParameter parameter:@"amplitude"
                                                          name:@"Overall level"
                                                       address:amplitudeAddress
                                                           min:0.0
                                                           max:1.0
                                                          unit:kAudioUnitParameterUnit_Generic];

    // Initialize the parameter values.
    wahAUParameter.value = 0.0;
    mixAUParameter.value = 1.0;
    amplitudeAUParameter.value = 0.1;

    _kernel.setParameter(wahAddress,       wahAUParameter.value);
    _kernel.setParameter(mixAddress,       mixAUParameter.value);
    _kernel.setParameter(amplitudeAddress, amplitudeAUParameter.value);

    // Create the parameter tree.
    _parameterTree = [AUParameterTree tree:@[
        wahAUParameter,
        mixAUParameter,
        amplitudeAUParameter
    ]];

    parameterTreeBlock(AutoWah)
}

AUAudioUnitOverrides(AutoWah);

@end


