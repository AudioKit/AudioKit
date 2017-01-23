//
//  AKToneFilterAudioUnit.mm
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright (c) 2017 Aurelius Prochazka. All rights reserved.
//

#import "AKToneFilterAudioUnit.h"
#import "AKToneFilterDSPKernel.hpp"

#import "BufferedAudioBus.hpp"

#import <AudioKit/AudioKit-Swift.h>

@implementation AKToneFilterAudioUnit {
    // C++ members need to be ivars; they would be copied on access if they were properties.
    AKToneFilterDSPKernel _kernel;
    BufferedInputBus _inputBus;
}
@synthesize parameterTree = _parameterTree;

- (void)setHalfPowerPoint:(float)halfPowerPoint {
    _kernel.setHalfPowerPoint(halfPowerPoint);
}

standardKernelPassthroughs()

- (void)createParameters {

    standardSetup(ToneFilter)

    // Create a parameter object for the halfPowerPoint.
    AUParameter *halfPowerPointAUParameter = [AUParameter parameter:@"halfPowerPoint"
                                                               name:@"Half-Power Point (Hz)"
                                                            address:halfPowerPointAddress
                                                                min:12.0
                                                                max:20000.0
                                                               unit:kAudioUnitParameterUnit_Hertz];

    // Initialize the parameter values.
    halfPowerPointAUParameter.value = 1000.0;

    _kernel.setParameter(halfPowerPointAddress, halfPowerPointAUParameter.value);

    // Create the parameter tree.
    _parameterTree = [AUParameterTree tree:@[
        halfPowerPointAUParameter
    ]];

	parameterTreeBlock(ToneFilter)
}

AUAudioUnitOverrides(ToneFilter);

@end


