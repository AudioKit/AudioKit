//
//  AKBandPassButterworthFilterAudioUnit.mm
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright (c) 2016 Aurelius Prochazka. All rights reserved.
//

#import "AKBandPassButterworthFilterAudioUnit.h"
#import "AKBandPassButterworthFilterDSPKernel.hpp"

#import "BufferedAudioBus.hpp"

#import <AudioKit/AudioKit-Swift.h>

@implementation AKBandPassButterworthFilterAudioUnit {
    // C++ members need to be ivars; they would be copied on access if they were properties.
    AKBandPassButterworthFilterDSPKernel _kernel;
    BufferedInputBus _inputBus;
}
@synthesize parameterTree = _parameterTree;

- (void)setCenterFrequency:(float)centerFrequency {
    _kernel.setCenterFrequency(centerFrequency);
}
- (void)setBandwidth:(float)bandwidth {
    _kernel.setBandwidth(bandwidth);
}

standardKernelPassthroughs()

- (void)createParameters {

    standardSetup(BandPassButterworthFilter)

    // Create a parameter object for the centerFrequency.
    AUParameter *centerFrequencyAUParameter = [AUParameter frequency:@"centerFrequency"
                                                                name:@"Center Frequency (Hz)"
                                                             address:centerFrequencyAddress];
    // Create a parameter object for the bandwidth.
    AUParameter *bandwidthAUParameter = [AUParameter parameter:@"bandwidth"
                                                          name:@"Bandwidth (Hz)"
                                                       address:bandwidthAddress
                                                           min:0.0
                                                           max:20000.0
                                                          unit:kAudioUnitParameterUnit_Hertz];
    // Initialize the parameter values.
    centerFrequencyAUParameter.value = 2000.0;
    bandwidthAUParameter.value = 100.0;


    _kernel.setParameter(centerFrequencyAddress, centerFrequencyAUParameter.value);
    _kernel.setParameter(bandwidthAddress,       bandwidthAUParameter.value);

    // Create the parameter tree.
    _parameterTree = [AUParameterTree createTreeWithChildren:@[
        centerFrequencyAUParameter,
        bandwidthAUParameter
    ]];

    // A function to provide string representations of parameter values.
    _parameterTree.implementorStringFromValueCallback = ^(AUParameter *param, const AUValue *__nullable valuePtr) {
        AUValue value = valuePtr == nil ? param.value : *valuePtr;

        switch (param.address) {
            case centerFrequencyAddress:
            case bandwidthAddress:
                return [NSString stringWithFormat:@"%.3f", value];
            default:
                return @"?";
        }
    };

	parameterTreeBlock(BandPassButterworthFilter)
}

AUAudioUnitOverrides(BandPassButterworthFilter);

@end


