//
//  AKMoogLadderAudioUnit.mm
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright © 2017 Aurelius Prochazka. All rights reserved.
//

#import "AKMoogLadderAudioUnit.h"
#import "AKMoogLadderDSPKernel.hpp"

#import "BufferedAudioBus.hpp"

#import <AudioKit/AudioKit-Swift.h>

@implementation AKMoogLadderAudioUnit {
    // C++ members need to be ivars; they would be copied on access if they were properties.
    AKMoogLadderDSPKernel _kernel;
    BufferedInputBus _inputBus;
}
@synthesize parameterTree = _parameterTree;

- (void)setCutoffFrequency:(float)cutoffFrequency {
    _kernel.setCutoffFrequency(cutoffFrequency);
}
- (void)setResonance:(float)resonance {
    _kernel.setResonance(resonance);
}

standardKernelPassthroughs()

- (void)createParameters {

    standardSetup(MoogLadder)

    // Create a parameter object for the cutoffFrequency.
    AUParameter *cutoffFrequencyAUParameter = [AUParameter frequency:@"cutoffFrequency"
                                                                name:@"Cutoff Frequency (Hz)"
                                                             address:cutoffFrequencyAddress];
    // Create a parameter object for the resonance.
    AUParameter *resonanceAUParameter = [AUParameter parameter:@"resonance"
                                                          name:@"Resonance (%)"
                                                       address:resonanceAddress
                                                           min:0.0
                                                           max:2.0
                                                          unit:kAudioUnitParameterUnit_Percent];
    // Initialize the parameter values.
    cutoffFrequencyAUParameter.value = 1000;
    resonanceAUParameter.value = 0.5;

    _kernel.setParameter(cutoffFrequencyAddress, cutoffFrequencyAUParameter.value);
    _kernel.setParameter(resonanceAddress,       resonanceAUParameter.value);

    // Create the parameter tree.
    _parameterTree = [AUParameterTree tree:@[
        cutoffFrequencyAUParameter,
        resonanceAUParameter
    ]];

	parameterTreeBlock(MoogLadder)
}

AUAudioUnitOverrides(MoogLadder);

@end


