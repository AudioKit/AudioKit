//
//  AKLowShelfParametricEqualizerFilterAudioUnit.mm
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright (c) 2016 Aurelius Prochazka. All rights reserved.
//

#import "AKLowShelfParametricEqualizerFilterAudioUnit.h"
#import "AKLowShelfParametricEqualizerFilterDSPKernel.hpp"

#import "BufferedAudioBus.hpp"

#import <AudioKit/AudioKit-Swift.h>

@implementation AKLowShelfParametricEqualizerFilterAudioUnit {
    // C++ members need to be ivars; they would be copied on access if they were properties.
    AKLowShelfParametricEqualizerFilterDSPKernel _kernel;
    BufferedInputBus _inputBus;
}
@synthesize parameterTree = _parameterTree;

- (void)setCornerFrequency:(float)cornerFrequency {
    _kernel.setCornerFrequency(cornerFrequency);
}
- (void)setGain:(float)gain {
    _kernel.setGain(gain);
}
- (void)setQ:(float)q {
    _kernel.setQ(q);
}

standardKernelPassthroughs()

- (void)createParameters {

    standardSetup(LowShelfParametricEqualizerFilter)

    // Create a parameter object for the cornerFrequency.
    AUParameter *cornerFrequencyAUParameter = [AUParameter parameter:@"cornerFrequency"
                                                                name:@"Corner Frequency (Hz)"
                                                             address:cornerFrequencyAddress
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
    cornerFrequencyAUParameter.value = 1000;
    gainAUParameter.value = 1.0;
    qAUParameter.value = 0.707;

    _kernel.setParameter(cornerFrequencyAddress, cornerFrequencyAUParameter.value);
    _kernel.setParameter(gainAddress,            gainAUParameter.value);
    _kernel.setParameter(qAddress,               qAUParameter.value);

    // Create the parameter tree.
    _parameterTree = [AUParameterTree tree:@[
        cornerFrequencyAUParameter,
        gainAUParameter,
        qAUParameter
    ]];

	parameterTreeBlock(LowShelfParametricEqualizerFilter)
}

AUAudioUnitOverrides(LowShelfParametricEqualizerFilter);

@end


