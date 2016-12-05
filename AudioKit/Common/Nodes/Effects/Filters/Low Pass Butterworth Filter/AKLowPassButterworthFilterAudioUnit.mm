//
//  AKLowPassButterworthFilterAudioUnit.mm
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright (c) 2016 Aurelius Prochazka. All rights reserved.
//

#import "AKLowPassButterworthFilterAudioUnit.h"
#import "AKLowPassButterworthFilterDSPKernel.hpp"

#import <AVFoundation/AVFoundation.h>
#import "BufferedAudioBus.hpp"

#import <AudioKit/AudioKit-Swift.h>

@implementation AKLowPassButterworthFilterAudioUnit {
    // C++ members need to be ivars; they would be copied on access if they were properties.
    AKLowPassButterworthFilterDSPKernel _kernel;
    BufferedInputBus _inputBus;
}
@synthesize parameterTree = _parameterTree;

- (void)setCutoffFrequency:(float)cutoffFrequency {
    _kernel.setCutoffFrequency(cutoffFrequency);
}

standardKernelPassthroughs()

- (void)createParameters {

    standardSetup(LowPassButterworthFilter)

    // Create a parameter object for the cutoffFrequency.
    AUParameter *cutoffFrequencyAUParameter =
    [AUParameterTree createParameterWithIdentifier:@"cutoffFrequency"
                                              name:@"Cutoff Frequency (Hz)"
                                           address:cutoffFrequencyAddress
                                               min:12.0
                                               max:20000.0
                                              unit:kAudioUnitParameterUnit_Hertz
                                          unitName:nil
                                             flags:0
                                      valueStrings:nil
                               dependentParameters:nil];


    // Initialize the parameter values.
    cutoffFrequencyAUParameter.value = 1000.0;

    _kernel.setParameter(cutoffFrequencyAddress, cutoffFrequencyAUParameter.value);

    // Create the parameter tree.
    _parameterTree = [AUParameterTree createTreeWithChildren:@[
        cutoffFrequencyAUParameter
    ]];


    // A function to provide string representations of parameter values.
    _parameterTree.implementorStringFromValueCallback = ^(AUParameter *param, const AUValue *__nullable valuePtr) {
        AUValue value = valuePtr == nil ? param.value : *valuePtr;

        switch (param.address) {
            case cutoffFrequencyAddress:
                return [NSString stringWithFormat:@"%.3f", value];

            default:
                return @"?";
        }
    };

	parameterTreeBlock(LowPassButterworthFilter)
}

AUAudioUnitOverrides(LowPassButterworthFilter);

@end


