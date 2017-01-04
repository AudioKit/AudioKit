//
//  AKEqualizerFilterAudioUnit.mm
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright (c) 2016 Aurelius Prochazka. All rights reserved.
//

#import "AKEqualizerFilterAudioUnit.h"
#import "AKEqualizerFilterDSPKernel.hpp"

#import "BufferedAudioBus.hpp"

#import <AudioKit/AudioKit-Swift.h>

@implementation AKEqualizerFilterAudioUnit {
    // C++ members need to be ivars; they would be copied on access if they were properties.
    AKEqualizerFilterDSPKernel _kernel;
    BufferedInputBus _inputBus;
}
@synthesize parameterTree = _parameterTree;

- (void)setCenterFrequency:(float)centerFrequency {
    _kernel.setCenterFrequency(centerFrequency);
}
- (void)setBandwidth:(float)bandwidth {
    _kernel.setBandwidth(bandwidth);
}
- (void)setGain:(float)gain {
    _kernel.setGain(gain);
}

standardKernelPassthroughs()

- (void)createParameters {

    standardSetup(EqualizerFilter)

    // Create a parameter object for the centerFrequency.
    AUParameter *centerFrequencyAUParameter =
    [AUParameterTree createParameterWithIdentifier:@"centerFrequency"
                                              name:@"Center Frequency (Hz)"
                                           address:centerFrequencyAddress
                                               min:12.0
                                               max:20000.0
                                              unit:kAudioUnitParameterUnit_Hertz
                                          unitName:nil
                                             flags:0
                                      valueStrings:nil
                               dependentParameters:nil];
    // Create a parameter object for the bandwidth.
    AUParameter *bandwidthAUParameter =
    [AUParameterTree createParameterWithIdentifier:@"bandwidth"
                                              name:@"Bandwidth (Hz)"
                                           address:bandwidthAddress
                                               min:0.0
                                               max:20000.0
                                              unit:kAudioUnitParameterUnit_Hertz
                                          unitName:nil
                                             flags:0
                                      valueStrings:nil
                               dependentParameters:nil];
    // Create a parameter object for the gain.
    AUParameter *gainAUParameter =
    [AUParameterTree createParameterWithIdentifier:@"gain"
                                              name:@"Gain (%)"
                                           address:gainAddress
                                               min:-100.0
                                               max:100.0
                                              unit:kAudioUnitParameterUnit_Percent
                                          unitName:nil
                                             flags:0
                                      valueStrings:nil
                               dependentParameters:nil];


    // Initialize the parameter values.
    centerFrequencyAUParameter.value = 1000.0;
    bandwidthAUParameter.value = 100.0;
    gainAUParameter.value = 10.0;

    _kernel.setParameter(centerFrequencyAddress, centerFrequencyAUParameter.value);
    _kernel.setParameter(bandwidthAddress,       bandwidthAUParameter.value);
    _kernel.setParameter(gainAddress,            gainAUParameter.value);

    // Create the parameter tree.
    _parameterTree = [AUParameterTree createTreeWithChildren:@[
        centerFrequencyAUParameter,
        bandwidthAUParameter,
        gainAUParameter
    ]];

    // A function to provide string representations of parameter values.
    _parameterTree.implementorStringFromValueCallback = ^(AUParameter *param, const AUValue *__nullable valuePtr) {
        AUValue value = valuePtr == nil ? param.value : *valuePtr;

        switch (param.address) {
            case centerFrequencyAddress:
            case bandwidthAddress:
            case gainAddress:
                return [NSString stringWithFormat:@"%.3f", value];
            default:
                return @"?";
        }
    };

	parameterTreeBlock(EqualizerFilter)
}

AUAudioUnitOverrides(EqualizerFilter);

@end


