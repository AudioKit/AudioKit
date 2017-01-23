//
//  AKModalResonanceFilterAudioUnit.mm
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright (c) 2017 Aurelius Prochazka. All rights reserved.
//

#import "AKModalResonanceFilterAudioUnit.h"
#import "AKModalResonanceFilterDSPKernel.hpp"

#import "BufferedAudioBus.hpp"

#import <AudioKit/AudioKit-Swift.h>

@implementation AKModalResonanceFilterAudioUnit {
    // C++ members need to be ivars; they would be copied on access if they were properties.
    AKModalResonanceFilterDSPKernel _kernel;
    BufferedInputBus _inputBus;
}
@synthesize parameterTree = _parameterTree;

- (void)setFrequency:(float)frequency {
    _kernel.setFrequency(frequency);
}
- (void)setQualityFactor:(float)qualityFactor {
    _kernel.setQualityFactor(qualityFactor);
}

standardKernelPassthroughs()

- (void)createParameters {

    standardSetup(ModalResonanceFilter)

    // Create a parameter object for the frequency.
    AUParameter *frequencyAUParameter = [AUParameter frequency:@"frequency"
                                                          name:@"Resonant Frequency (Hz)"
                                                       address:frequencyAddress];
    // Create a parameter object for the qualityFactor.
    AUParameter *qualityFactorAUParameter = [AUParameter parameter:@"qualityFactor"
                                                              name:@"Quality Factor"
                                                           address:qualityFactorAddress
                                                               min:0.0
                                                               max:100.0
                                                              unit:kAudioUnitParameterUnit_Generic];

    // Initialize the parameter values.
    frequencyAUParameter.value = 500.0;
    qualityFactorAUParameter.value = 50.0;


    _kernel.setParameter(frequencyAddress,     frequencyAUParameter.value);
    _kernel.setParameter(qualityFactorAddress, qualityFactorAUParameter.value);

    // Create the parameter tree.
    _parameterTree = [AUParameterTree tree:@[
        frequencyAUParameter,
        qualityFactorAUParameter
    ]];


	parameterTreeBlock(ModalResonanceFilter)
}

AUAudioUnitOverrides(ModalResonanceFilter);

@end


