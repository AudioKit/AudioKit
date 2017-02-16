//
//  AKCombFilterReverbAudioUnit.mm
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright © 2017 Aurelius Prochazka. All rights reserved.
//

#import "AKCombFilterReverbAudioUnit.h"
#import "AKCombFilterReverbDSPKernel.hpp"

#import "BufferedAudioBus.hpp"

#import <AudioKit/AudioKit-Swift.h>

@implementation AKCombFilterReverbAudioUnit {
    // C++ members need to be ivars; they would be copied on access if they were properties.
    AKCombFilterReverbDSPKernel _kernel;
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

    standardSetup(CombFilterReverb)

    // Create a parameter object for the reverbDuration.
    AUParameter *reverbDurationAUParameter = [AUParameter parameter:@"reverbDuration"
                                                               name:@"Reverb Duration (Seconds)"
                                                            address:reverbDurationAddress
                                                                min:0.0
                                                                max:10.0
                                                               unit:kAudioUnitParameterUnit_Seconds];

    // Initialize the parameter values.
    reverbDurationAUParameter.value = 1.0;


    _kernel.setParameter(reverbDurationAddress, reverbDurationAUParameter.value);

    // Create the parameter tree.
    _parameterTree = [AUParameterTree tree:@[
        reverbDurationAUParameter
    ]];


	parameterTreeBlock(CombFilterReverb)
}

AUAudioUnitOverrides(CombFilterReverb);

@end


