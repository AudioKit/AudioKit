//
//  AKEqualizerFilterAudioUnit.mm
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright © 2017 Aurelius Prochazka. All rights reserved.
//

#import "AKEqualizerFilterAudioUnit.h"
#import "AKEqualizerFilterDSPKernel.hpp"

#import "BufferedAudioBus.hpp"

#import <AudioKit/AudioKit-Swift.h>

@implementation AKEqualizerFilterAudioUnit {
    // C++ members need to be ivars; they would be copied on access if they were properties.
    AKEqualizerFilterDSPKernel _kernel;
    BufferedInputBus _inputBus;
}
@synthesize parameterTree = _parameterTree;

- (void)setCenterFrequency:(float)centerFrequency {
    _kernel.setCenterFrequency(centerFrequency);
}
- (void)setBandwidth:(float)bandwidth {
    _kernel.setBandwidth(bandwidth);
}
- (void)setGain:(float)gain {
    _kernel.setGain(gain);
}

standardKernelPassthroughs()

- (void)createParameters {

    standardSetup(EqualizerFilter)

    // Create a parameter object for the centerFrequency.
    AUParameter *centerFrequencyAUParameter = [AUParameter parameter:@"centerFrequency"
                                                                name:@"Center Frequency (Hz)"
                                                             address:centerFrequencyAddress
                                                                 min:12.0
                                                                 max:20000.0
                                                                unit:kAudioUnitParameterUnit_Hertz];

    // Create a parameter object for the bandwidth.
    AUParameter *bandwidthAUParameter = [AUParameter parameter:@"bandwidth"
                                                          name:@"Bandwidth (Hz)"
                                                       address:bandwidthAddress
                                                           min:0.0
                                                           max:20000.0
                                                          unit:kAudioUnitParameterUnit_Hertz];
    // Create a parameter object for the gain.
    AUParameter *gainAUParameter = [AUParameter parameter:@"gain"
                                                     name:@"Gain (%)"
                                                  address:gainAddress
                                                      min:-100.0
                                                      max:100.0
                                                     unit:kAudioUnitParameterUnit_Percent];

    // Initialize the parameter values.
    centerFrequencyAUParameter.value = 1000.0;
    bandwidthAUParameter.value = 100.0;
    gainAUParameter.value = 10.0;

    _kernel.setParameter(centerFrequencyAddress, centerFrequencyAUParameter.value);
    _kernel.setParameter(bandwidthAddress,       bandwidthAUParameter.value);
    _kernel.setParameter(gainAddress,            gainAUParameter.value);

    // Create the parameter tree.
    _parameterTree = [AUParameterTree tree:@[
        centerFrequencyAUParameter,
        bandwidthAUParameter,
        gainAUParameter
    ]];

	parameterTreeBlock(EqualizerFilter)
}

AUAudioUnitOverrides(EqualizerFilter);

@end


