//
//  AKVariableDelayAudioUnit.mm
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright (c) 2016 Aurelius Prochazka. All rights reserved.
//

#import "AKVariableDelayAudioUnit.h"
#import "AKVariableDelayDSPKernel.hpp"

#import "BufferedAudioBus.hpp"

#import <AudioKit/AudioKit-Swift.h>

@implementation AKVariableDelayAudioUnit {
    // C++ members need to be ivars; they would be copied on access if they were properties.
    AKVariableDelayDSPKernel _kernel;
    BufferedInputBus _inputBus;
}
@synthesize parameterTree = _parameterTree;

- (void)setTime:(float)time {
    _kernel.setTime(time);
}
- (void)setFeedback:(float)feedback {
    _kernel.setFeedback(feedback);
}

standardKernelPassthroughs()

- (void)createParameters {

    standardSetup(VariableDelay)

    // Create a parameter object for the time.
    AUParameter *timeAUParameter = [AUParameter parameter:@"time"
                                                     name:@"Delay time (Seconds)"
                                                  address:timeAddress
                                                      min:0
                                                      max:10
                                                     unit:kAudioUnitParameterUnit_Seconds];

    // Create a parameter object for the feedback.
    AUParameter *feedbackAUParameter = [AUParameter parameter:@"feedback"
                                                         name:@"Feedback (%)"
                                                      address:feedbackAddress
                                                          min:0
                                                          max:1
                                                         unit:kAudioUnitParameterUnit_Generic];

    // Initialize the parameter values.
    timeAUParameter.value = 1;
    feedbackAUParameter.value = 0;

    _kernel.setParameter(timeAddress, timeAUParameter.value);
    _kernel.setParameter(feedbackAddress, feedbackAUParameter.value);

    // Create the parameter tree.
    _parameterTree = [AUParameterTree createTreeWithChildren:@[
                                                               timeAUParameter,
                                                               feedbackAUParameter
                                                               ]];

    // A function to provide string representations of parameter values.
    _parameterTree.implementorStringFromValueCallback = ^(AUParameter *param, const AUValue *__nullable valuePtr) {
        AUValue value = valuePtr == nil ? param.value : *valuePtr;

        switch (param.address) {
            case timeAddress:
            case feedbackAddress:
                return [NSString stringWithFormat:@"%.3f", value];

            default:
                return @"?";
        }
    };

	parameterTreeBlock(VariableDelay)
}

AUAudioUnitOverrides(VariableDelay);

@end

