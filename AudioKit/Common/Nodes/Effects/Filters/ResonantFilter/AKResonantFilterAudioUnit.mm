//
//  AKResonantFilterAudioUnit.mm
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright (c) 2017 Aurelius Prochazka. All rights reserved.
//

#import "AKResonantFilterAudioUnit.h"
#import "AKResonantFilterDSPKernel.hpp"

#import "BufferedAudioBus.hpp"

#import <AudioKit/AudioKit-Swift.h>

@implementation AKResonantFilterAudioUnit {
    // C++ members need to be ivars; they would be copied on access if they were properties.
    AKResonantFilterDSPKernel _kernel;
    BufferedInputBus _inputBus;
}
@synthesize parameterTree = _parameterTree;

- (void)setFrequency:(float)frequency {
    _kernel.setFrequency(frequency);
}
- (void)setBandwidth:(float)bandwidth {
    _kernel.setBandwidth(bandwidth);
}

standardKernelPassthroughs()

- (void)createParameters {

    standardSetup(ResonantFilter)

    // Create a parameter object for the frequency.
    AUParameter *frequencyAUParameter = [AUParameter frequency:@"frequency"
                                                          name:@"Center frequency of the filter, or frequency position of the peak response."
                                                       address:frequencyAddress];
    // Create a parameter object for the bandwidth.
    AUParameter *bandwidthAUParameter = [AUParameter parameter:@"bandwidth"
                                                          name:@"Bandwidth of the filter."
                                                       address:bandwidthAddress
                                                           min:0.0
                                                           max:10000.0
                                                          unit:kAudioUnitParameterUnit_Hertz];

    // Initialize the parameter values.
    frequencyAUParameter.value = 4000.0;
    bandwidthAUParameter.value = 1000.0;

    _kernel.setParameter(frequencyAddress, frequencyAUParameter.value);
    _kernel.setParameter(bandwidthAddress, bandwidthAUParameter.value);

    // Create the parameter tree.
    _parameterTree = [AUParameterTree tree:@[
        frequencyAUParameter,
        bandwidthAUParameter
    ]];

	parameterTreeBlock(ResonantFilter)
}

AUAudioUnitOverrides(ResonantFilter);

@end


