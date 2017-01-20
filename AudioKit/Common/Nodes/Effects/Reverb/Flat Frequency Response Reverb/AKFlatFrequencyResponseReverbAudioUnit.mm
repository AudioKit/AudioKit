//
//  AKFlatFrequencyResponseReverbAudioUnit.mm
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright (c) 2017 Aurelius Prochazka. All rights reserved.
//

#import "AKFlatFrequencyResponseReverbAudioUnit.h"
#import "AKFlatFrequencyResponseReverbDSPKernel.hpp"

#import "BufferedAudioBus.hpp"

#import <AudioKit/AudioKit-Swift.h>

@implementation AKFlatFrequencyResponseReverbAudioUnit {
    // C++ members need to be ivars; they would be copied on access if they were properties.
    AKFlatFrequencyResponseReverbDSPKernel _kernel;
    BufferedInputBus _inputBus;
}
@synthesize parameterTree = _parameterTree;

- (void)setReverbDuration:(float)reverbDuration {
    _kernel.setReverbDuration(reverbDuration);
}

- (void)setLoopDuration:(float)duration {
    _kernel.setLoopDuration(duration);
}

standardKernelPassthroughs()

- (void)createParameters {

    standardSetup(FlatFrequencyResponseReverb)

    // Create a parameter object for the reverbDuration.
    AUParameter *reverbDurationAUParameter = [AUParameter parameter:@"reverbDuration"
                                                               name:@"Reverb Duration (Seconds)"
                                                            address:reverbDurationAddress
                                                                min:0
                                                                max:10
                                                               unit:kAudioUnitParameterUnit_Seconds];

    // Initialize the parameter values.
    reverbDurationAUParameter.value = 0.5;

    _kernel.setParameter(reverbDurationAddress, reverbDurationAUParameter.value);

    // Create the parameter tree.
    _parameterTree = [AUParameterTree tree:@[
        reverbDurationAUParameter
    ]];

	parameterTreeBlock(FlatFrequencyResponseReverb)
}

AUAudioUnitOverrides(FlatFrequencyResponseReverb);

@end


