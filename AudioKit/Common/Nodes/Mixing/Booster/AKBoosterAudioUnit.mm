//
//  AKBoosterAudioUnit.mm
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright © 2017 Aurelius Prochazka. All rights reserved.
//

#import "AKBoosterAudioUnit.h"
#import "AKBoosterDSPKernel.hpp"

#import "BufferedAudioBus.hpp"

#import <AudioKit/AudioKit-Swift.h>

@implementation AKBoosterAudioUnit {
    // C++ members need to be ivars; they would be copied on access if they were properties.
    AKBoosterDSPKernel _kernel;
    BufferedInputBus _inputBus;
}
@synthesize parameterTree = _parameterTree;

- (void)setLeftGain:(float)leftGain {
    _kernel.setLeftGain(leftGain);
}
- (void)setRightGain:(float)rightGain {
    _kernel.setRightGain(rightGain);
}


standardKernelPassthroughs()

- (void)createParameters {

    standardSetup(Booster)

    // Create a parameter object for the left gain.
    AUParameter *leftGainAUParameter = [AUParameter parameter:@"leftGain"
                                                         name:@"Left Boosting amount."
                                                      address:leftGainAddress
                                                          min:0
                                                          max:1
                                                         unit:kAudioUnitParameterUnit_Generic];
    
    AUParameter *rightGainAUParameter = [AUParameter parameter:@"rightGain"
                                                          name:@"Right Boosting amount."
                                                       address:rightGainAddress
                                                           min:0
                                                           max:1
                                                          unit:kAudioUnitParameterUnit_Generic];
    
    // Initialize the parameter values.
    leftGainAUParameter.value = 1;
    rightGainAUParameter.value = 1;

    _kernel.setParameter(leftGainAddress, leftGainAUParameter.value);
    _kernel.setParameter(rightGainAddress, rightGainAUParameter.value);

    // Create the parameter tree.
    _parameterTree = [AUParameterTree tree:@[
        leftGainAUParameter,
        rightGainAUParameter
    ]];

    parameterTreeBlock(Booster)
}

AUAudioUnitOverrides(Booster)

@end


