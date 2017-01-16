//
//  AKFormantFilterAudioUnit.mm
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright (c) 2017 Aurelius Prochazka. All rights reserved.
//

#import "AKFormantFilterAudioUnit.h"
#import "AKFormantFilterDSPKernel.hpp"

#import "BufferedAudioBus.hpp"

#import <AudioKit/AudioKit-Swift.h>

@implementation AKFormantFilterAudioUnit {
    // C++ members need to be ivars; they would be copied on access if they were properties.
    AKFormantFilterDSPKernel _kernel;
    BufferedInputBus _inputBus;
}
@synthesize parameterTree = _parameterTree;

- (void)setX:(float)x {
    _kernel.setX(x);
}

- (void)setY:(float)y {
    _kernel.setY(y);
}


standardKernelPassthroughs()

- (void)createParameters {
    
    standardSetup(FormantFilter)

    AUParameter *xAUParameter = [AUParameter parameter:@"x"
                                                  name:@"x Position"
                                               address:xAddress
                                                   min:0.0
                                                   max:1.0
                                                  unit:kAudioUnitParameterUnit_Generic];

    AUParameter *yAUParameter = [AUParameter parameter:@"y"
                                                  name:@"y Position"
                                               address:yAddress
                                                   min:0.0
                                                   max:1.0
                                                  unit:kAudioUnitParameterUnit_Generic];

    // Initialize the parameter values.
    xAUParameter.value = 0;
    yAUParameter.value = 0;

    _kernel.setParameter(xAddress, xAUParameter.value);
    _kernel.setParameter(yAddress,  yAUParameter.value);

    // Create the parameter tree.
    _parameterTree = [AUParameterTree tree:@[
        xAUParameter,
        yAUParameter
    ]];

    parameterTreeBlock(FormantFilter)
}

AUAudioUnitOverrides(FormantFilter)

@end


