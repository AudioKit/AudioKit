//
//  AKModalResonanceFilterAudioUnit.mm
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright (c) 2016 Aurelius Prochazka. All rights reserved.
//

#import "AKModalResonanceFilterAudioUnit.h"
#import "AKModalResonanceFilterDSPKernel.hpp"

#import <AVFoundation/AVFoundation.h>
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
    AUParameter *frequencyAUParameter =
    [AUParameterTree createParameterWithIdentifier:@"frequency"
                                              name:@"Resonant Frequency (Hz)"
                                           address:frequencyAddress
                                               min:12.0
                                               max:20000.0
                                              unit:kAudioUnitParameterUnit_Hertz
                                          unitName:nil
                                             flags:0
                                      valueStrings:nil
                               dependentParameters:nil];
    // Create a parameter object for the qualityFactor.
    AUParameter *qualityFactorAUParameter =
    [AUParameterTree createParameterWithIdentifier:@"qualityFactor"
                                              name:@"Quality Factor"
                                           address:qualityFactorAddress
                                               min:0.0
                                               max:100.0
                                              unit:kAudioUnitParameterUnit_Generic
                                          unitName:nil
                                             flags:0
                                      valueStrings:nil
                               dependentParameters:nil];


    // Initialize the parameter values.
    frequencyAUParameter.value = 500.0;
    qualityFactorAUParameter.value = 50.0;


    _kernel.setParameter(frequencyAddress,     frequencyAUParameter.value);
    _kernel.setParameter(qualityFactorAddress, qualityFactorAUParameter.value);

    // Create the parameter tree.
    _parameterTree = [AUParameterTree createTreeWithChildren:@[
        frequencyAUParameter,
        qualityFactorAUParameter
    ]];

    // A function to provide string representations of parameter values.
    _parameterTree.implementorStringFromValueCallback = ^(AUParameter *param, const AUValue *__nullable valuePtr) {
        AUValue value = valuePtr == nil ? param.value : *valuePtr;

        switch (param.address) {
            case frequencyAddress:
                return [NSString stringWithFormat:@"%.3f", value];

            case qualityFactorAddress:
                return [NSString stringWithFormat:@"%.3f", value];

            default:
                return @"?";
        }
    };

	parameterTreeBlock(ModalResonanceFilter)
}

AUAudioUnitOverrides(ModalResonanceFilter);

@end


