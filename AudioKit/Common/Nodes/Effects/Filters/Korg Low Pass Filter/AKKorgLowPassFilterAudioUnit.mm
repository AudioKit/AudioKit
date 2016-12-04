//
//  AKKorgLowPassFilterAudioUnit.mm
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright (c) 2016 Aurelius Prochazka. All rights reserved.
//

#import "AKKorgLowPassFilterAudioUnit.h"
#import "AKKorgLowPassFilterDSPKernel.hpp"

#import <AVFoundation/AVFoundation.h>
#import "BufferedAudioBus.hpp"

#import <AudioKit/AudioKit-Swift.h>

@implementation AKKorgLowPassFilterAudioUnit {
    // C++ members need to be ivars; they would be copied on access if they were properties.
    AKKorgLowPassFilterDSPKernel _kernel;
    BufferedInputBus _inputBus;
}
@synthesize parameterTree = _parameterTree;

- (void)setCutoffFrequency:(float)cutoffFrequency {
    _kernel.setCutoffFrequency(cutoffFrequency);
}
- (void)setResonance:(float)resonance {
    _kernel.setResonance(resonance);
}
- (void)setSaturation:(float)saturation {
    _kernel.setSaturation(saturation);
}

standardKernelPassthroughs()

- (void)createParameters {

    standardSetup(KorgLowPassFilter)

    // Create a parameter object for the cutoffFrequency.
    AUParameter *cutoffFrequencyAUParameter =
    [AUParameterTree createParameterWithIdentifier:@"cutoffFrequency"
                                              name:@"Filter cutoff"
                                           address:cutoffFrequencyAddress
                                               min:0.0
                                               max:22050.0
                                              unit:kAudioUnitParameterUnit_Hertz
                                          unitName:nil
                                             flags:0
                                      valueStrings:nil
                               dependentParameters:nil];
    // Create a parameter object for the resonance.
    AUParameter *resonanceAUParameter =
    [AUParameterTree createParameterWithIdentifier:@"resonance"
                                              name:@"Filter resonance (should be between 0-2)"
                                           address:resonanceAddress
                                               min:0.0
                                               max:2.0
                                              unit:kAudioUnitParameterUnit_Generic
                                          unitName:nil
                                             flags:0
                                      valueStrings:nil
                               dependentParameters:nil];
    // Create a parameter object for the saturation.
    AUParameter *saturationAUParameter =
    [AUParameterTree createParameterWithIdentifier:@"saturation"
                                              name:@"Filter saturation."
                                           address:saturationAddress
                                               min:0.0
                                               max:10.0
                                              unit:kAudioUnitParameterUnit_Generic
                                          unitName:nil
                                             flags:0
                                      valueStrings:nil
                               dependentParameters:nil];


    // Initialize the parameter values.
    cutoffFrequencyAUParameter.value = 1000.0;
    resonanceAUParameter.value = 1.0;
    saturationAUParameter.value = 0.0;


    _kernel.setParameter(cutoffFrequencyAddress, cutoffFrequencyAUParameter.value);
    _kernel.setParameter(resonanceAddress,       resonanceAUParameter.value);
    _kernel.setParameter(saturationAddress,      saturationAUParameter.value);

    // Create the parameter tree.
    _parameterTree = [AUParameterTree createTreeWithChildren:@[
        cutoffFrequencyAUParameter,
        resonanceAUParameter,
        saturationAUParameter
    ]];

    // A function to provide string representations of parameter values.
    _parameterTree.implementorStringFromValueCallback = ^(AUParameter *param, const AUValue *__nullable valuePtr) {
        AUValue value = valuePtr == nil ? param.value : *valuePtr;

        switch (param.address) {
            case cutoffFrequencyAddress:
                return [NSString stringWithFormat:@"%.3f", value];

            case resonanceAddress:
                return [NSString stringWithFormat:@"%.3f", value];

            case saturationAddress:
                return [NSString stringWithFormat:@"%.3f", value];

            default:
                return @"?";
        }
    };

	parameterTreeBlock(KorgLowPassFilter)
}

AUAudioUnitOverrides(KorgLowPassFilter);

@end


