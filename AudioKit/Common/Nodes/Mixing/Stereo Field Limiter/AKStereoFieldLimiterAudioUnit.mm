//
//  AKStereoFieldLimiterAudioUnit.mm
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright (c) 2017 Aurelius Prochazka. All rights reserved.
//

#import "AKStereoFieldLimiterAudioUnit.h"
#import "AKStereoFieldLimiterDSPKernel.hpp"

#import "BufferedAudioBus.hpp"

#import <AudioKit/AudioKit-Swift.h>

@implementation AKStereoFieldLimiterAudioUnit {
    // C++ members need to be ivars; they would be copied on access if they were properties.
    AKStereoFieldLimiterDSPKernel _kernel;
    BufferedInputBus _inputBus;
}
@synthesize parameterTree = _parameterTree;

- (void)setamount:(float)amount {
    _kernel.setamount(amount);
}


standardKernelPassthroughs()

- (void)createParameters {

    standardSetup(StereoFieldLimiter)

    // Create a parameter object for the amount.
    AUParameter *amountAUParameter = [AUParameter parameter:@"amount"
                                                       name:@"Amount of limit"
                                                    address:amountAddress
                                                        min:0
                                                        max:1
                                                       unit:kAudioUnitParameterUnit_Generic];


    // Initialize the parameter values.
    amountAUParameter.value = 0;

    _kernel.setParameter(amountAddress, amountAUParameter.value);

    // Create the parameter tree.
    _parameterTree = [AUParameterTree tree:@[
        amountAUParameter
    ]];

    parameterTreeBlock(StereoFieldLimiter)
}

AUAudioUnitOverrides(StereoFieldLimiter)

@end


