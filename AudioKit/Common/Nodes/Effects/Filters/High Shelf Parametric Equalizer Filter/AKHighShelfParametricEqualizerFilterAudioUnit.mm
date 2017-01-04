//
//  AKHighShelfParametricEqualizerFilterAudioUnit.mm
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright (c) 2016 Aurelius Prochazka. All rights reserved.
//

#import "AKHighShelfParametricEqualizerFilterAudioUnit.h"
#import "AKHighShelfParametricEqualizerFilterDSPKernel.hpp"

#import "BufferedAudioBus.hpp"

#import <AudioKit/AudioKit-Swift.h>

@implementation AKHighShelfParametricEqualizerFilterAudioUnit {
    // C++ members need to be ivars; they would be copied on access if they were properties.
    AKHighShelfParametricEqualizerFilterDSPKernel _kernel;
    BufferedInputBus _inputBus;
}
@synthesize parameterTree = _parameterTree;

- (void)setCenterFrequency:(float)centerFrequency {
    _kernel.setCenterFrequency(centerFrequency);
}
- (void)setGain:(float)gain {
    _kernel.setGain(gain);
}
- (void)setQ:(float)q {
    _kernel.setQ(q);
}

standardKernelPassthroughs()

- (void)createParameters {

    standardSetup(HighShelfParametricEqualizerFilter)

    // Create a parameter object for the centerFrequency.
  AUParameter *centerFrequencyAUParameter = [AUParameter parameter:@"centerFrequency"
                                                              name:@"Corner Frequency (Hz)"
                                                           address:centerFrequencyAddress
                                                               min:12.0
                                                               max:20000.0
                                                              unit:kAudioUnitParameterUnit_Hertz];
    // Create a parameter object for the gain.
    AUParameter *gainAUParameter = [AUParameter parameter:@"gain"
                                                     name:@"Gain"
                                                  address:gainAddress
                                                      min:0.0
                                                      max:10.0
                                                     unit:kAudioUnitParameterUnit_Generic];
    // Create a parameter object for the q.
    AUParameter *qAUParameter = [AUParameter parameter:@"q"
                                                  name:@"Q"
                                               address:qAddress
                                                   min:0.0
                                                   max:2.0
                                                  unit:kAudioUnitParameterUnit_Generic];

    // Initialize the parameter values.
    centerFrequencyAUParameter.value = 1000;
    gainAUParameter.value = 1.0;
    qAUParameter.value = 0.707;

    _kernel.setParameter(centerFrequencyAddress, centerFrequencyAUParameter.value);
    _kernel.setParameter(gainAddress,            gainAUParameter.value);
    _kernel.setParameter(qAddress,               qAUParameter.value);

    // Create the parameter tree.
    _parameterTree = [AUParameterTree createTreeWithChildren:@[
        centerFrequencyAUParameter,
        gainAUParameter,
        qAUParameter
    ]];

    // A function to provide string representations of parameter values.
    _parameterTree.implementorStringFromValueCallback = ^(AUParameter *param, const AUValue *__nullable valuePtr) {
        AUValue value = valuePtr == nil ? param.value : *valuePtr;

        switch (param.address) {
            case centerFrequencyAddress:
            case gainAddress:
            case qAddress:
                return [NSString stringWithFormat:@"%.3f", value];
            default:
                return @"?";
        }
    };

	parameterTreeBlock(HighShelfParametricEqualizerFilter)
}

AUAudioUnitOverrides(HighShelfParametricEqualizerFilter);

@end


