//
//  AKBoosterAudioUnit.mm
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright (c) 2016 Aurelius Prochazka. All rights reserved.
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

- (void)setGain:(float)gain {
    _kernel.setGain(gain);
}


standardKernelPassthroughs()

- (void)createParameters {

    standardSetup(Booster)

    // Create a parameter object for the gain.
    AUParameter *gainAUParameter = [AUParameter parameter:@"gain"
                                                     name:@"Boosting amount."
                                                  address:gainAddress
                                                      min:0
                                                      max:1
                                                     unit:kAudioUnitParameterUnit_Generic];

    // Initialize the parameter values.
    gainAUParameter.value = 0;

    _kernel.setParameter(gainAddress, gainAUParameter.value);

    // Create the parameter tree.
    _parameterTree = [AUParameterTree tree:@[
        gainAUParameter
    ]];

    parameterTreeBlock(Booster)
}

AUAudioUnitOverrides(Booster)

@end


