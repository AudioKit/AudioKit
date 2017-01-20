//
//  AKCostelloReverbAudioUnit.mm
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright (c) 2017 Aurelius Prochazka. All rights reserved.
//

#import "AKCostelloReverbAudioUnit.h"
#import "AKCostelloReverbDSPKernel.hpp"

#import "BufferedAudioBus.hpp"

#import <AudioKit/AudioKit-Swift.h>

@implementation AKCostelloReverbAudioUnit {
    // C++ members need to be ivars; they would be copied on access if they were properties.
    AKCostelloReverbDSPKernel _kernel;
    BufferedInputBus _inputBus;
}
@synthesize parameterTree = _parameterTree;

- (void)setFeedback:(float)feedback {
    _kernel.setFeedback(feedback);
}
- (void)setCutoffFrequency:(float)cutoffFrequency {
    _kernel.setCutoffFrequency(cutoffFrequency);
}

standardKernelPassthroughs()

- (void)createParameters {

    standardSetup(CostelloReverb)

    // Create a parameter object for the feedback.
    AUParameter *feedbackAUParameter = [AUParameter parameter:@"feedback"
                                                         name:@"Feedback (%)"
                                                      address:feedbackAddress
                                                          min:0.0
                                                          max:1.0
                                                         unit:kAudioUnitParameterUnit_Generic];
    // Create a parameter object for the cutoffFrequency.
    AUParameter *cutoffFrequencyAUParameter = [AUParameter parameter:@"cutoffFrequency"
                                                                name:@"Cutoff Frequency (Hz)"
                                                             address:cutoffFrequencyAddress
                                                                 min:12.0
                                                                 max:20000.0
                                                                unit:kAudioUnitParameterUnit_Hertz];

    // Initialize the parameter values.
    feedbackAUParameter.value = 0.6;
    cutoffFrequencyAUParameter.value = 4000;

    _kernel.setParameter(feedbackAddress,        feedbackAUParameter.value);
    _kernel.setParameter(cutoffFrequencyAddress, cutoffFrequencyAUParameter.value);

    // Create the parameter tree.
    _parameterTree = [AUParameterTree tree:@[
        feedbackAUParameter,
        cutoffFrequencyAUParameter
    ]];

	parameterTreeBlock(CostelloReverb)
}

AUAudioUnitOverrides(CostelloReverb);

@end


