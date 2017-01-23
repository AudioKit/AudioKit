//
//  AKPeakingParametricEqualizerFilterAudioUnit.mm
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright (c) 2017 Aurelius Prochazka. All rights reserved.
//

#import "AKPeakingParametricEqualizerFilterAudioUnit.h"
#import "AKPeakingParametricEqualizerFilterDSPKernel.hpp"

#import "BufferedAudioBus.hpp"

#import <AudioKit/AudioKit-Swift.h>

@implementation AKPeakingParametricEqualizerFilterAudioUnit {
    // C++ members need to be ivars; they would be copied on access if they were properties.
    AKPeakingParametricEqualizerFilterDSPKernel _kernel;
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

    standardSetup(PeakingParametricEqualizerFilter)

    // Create a parameter object for the centerFrequency.
    AUParameter *centerFrequencyAUParameter = [AUParameter frequency:@"centerFrequency"
                                                                name:@"Center Frequency (Hz)"
                                                             address:centerFrequencyAddress];
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
    _parameterTree = [AUParameterTree tree:@[
        centerFrequencyAUParameter,
        gainAUParameter,
        qAUParameter
    ]];

	parameterTreeBlock(PeakingParametricEqualizerFilter)
}

AUAudioUnitOverrides(PeakingParametricEqualizerFilter);

@end


