//
//  AKBandRejectButterworthFilterAudioUnit.mm
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright © 2017 Aurelius Prochazka. All rights reserved.
//

#import "AKBandRejectButterworthFilterAudioUnit.h"
#import "AKBandRejectButterworthFilterDSPKernel.hpp"

#import "BufferedAudioBus.hpp"

#import <AudioKit/AudioKit-Swift.h>

@implementation AKBandRejectButterworthFilterAudioUnit {
    // C++ members need to be ivars; they would be copied on access if they were properties.
    AKBandRejectButterworthFilterDSPKernel _kernel;
    BufferedInputBus _inputBus;
}
@synthesize parameterTree = _parameterTree;

- (void)setCenterFrequency:(float)centerFrequency {
    _kernel.setCenterFrequency(centerFrequency);
}
- (void)setBandwidth:(float)bandwidth {
    _kernel.setBandwidth(bandwidth);
}

standardKernelPassthroughs()

- (void)createParameters {

    standardSetup(BandRejectButterworthFilter);

    // Create a parameter object for the centerFrequency.
    AUParameter *centerFrequencyAUParameter = [AUParameter frequency:@"centerFrequency"
                                                                name:@"Center Frequency (Hz)"
                                                             address:centerFrequencyAddress];
    // Create a parameter object for the bandwidth.
    AUParameter *bandwidthAUParameter = [AUParameter parameter:@"bandwidth"
                                                          name:@"Bandwidth (Hz)"
                                                       address:bandwidthAddress
                                                           min:0.0
                                                           max:20000.0
                                                          unit:kAudioUnitParameterUnit_Hertz];

    // Initialize the parameter values.
    centerFrequencyAUParameter.value = 3000.0;
    bandwidthAUParameter.value = 2000.0;

    _kernel.setParameter(centerFrequencyAddress, centerFrequencyAUParameter.value);
    _kernel.setParameter(bandwidthAddress,       bandwidthAUParameter.value);

    // Create the parameter tree.
    _parameterTree = [AUParameterTree tree:@[
        centerFrequencyAUParameter,
        bandwidthAUParameter
    ]];

	parameterTreeBlock(BandRejectButterworthFilter)
}

AUAudioUnitOverrides(BandRejectButterworthFilter);

@end


