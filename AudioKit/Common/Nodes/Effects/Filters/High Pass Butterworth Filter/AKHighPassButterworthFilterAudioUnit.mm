//
//  AKHighPassButterworthFilterAudioUnit.mm
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright (c) 2017 Aurelius Prochazka. All rights reserved.
//

#import "AKHighPassButterworthFilterAudioUnit.h"
#import "AKHighPassButterworthFilterDSPKernel.hpp"

#import "BufferedAudioBus.hpp"

#import <AudioKit/AudioKit-Swift.h>

@implementation AKHighPassButterworthFilterAudioUnit {
    // C++ members need to be ivars; they would be copied on access if they were properties.
    AKHighPassButterworthFilterDSPKernel _kernel;
    BufferedInputBus _inputBus;
}
@synthesize parameterTree = _parameterTree;

- (void)setCutoffFrequency:(float)cutoffFrequency {
    _kernel.setCutoffFrequency(cutoffFrequency);
}

standardKernelPassthroughs()

- (void)createParameters {

    standardSetup(HighPassButterworthFilter)

    // Create a parameter object for the cutoffFrequency.
    AUParameter *cutoffFrequencyAUParameter = [AUParameter parameter:@"cutoffFrequency"
                                                                name:@"Cutoff Frequency (Hz)"
                                                             address:cutoffFrequencyAddress
                                                                 min:12.0
                                                                 max:20000.0
                                                                unit:kAudioUnitParameterUnit_Hertz];

    // Initialize the parameter values.
    cutoffFrequencyAUParameter.value = 500.0;

    _kernel.setParameter(cutoffFrequencyAddress, cutoffFrequencyAUParameter.value);

    // Create the parameter tree.
    _parameterTree = [AUParameterTree tree:@[
        cutoffFrequencyAUParameter
    ]];

	parameterTreeBlock(HighPassButterworthFilter)
}

AUAudioUnitOverrides(HighPassButterworthFilter);

@end


