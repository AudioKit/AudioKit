//
//  AKFlangerAudioUnit.mm
//  AudioKit
//
//  Created by Shane Dunne
//  Copyright © 2018 Shane Dunne. All rights reserved.
//

#import "AKFlangerAudioUnit.h"
#import "SDModulatedDelayDSPKernel.hpp"

#import "BufferedAudioBus.hpp"

#import <AudioKit/AudioKit-Swift.h>

@implementation AKFlangerAudioUnit {
    // C++ members need to be ivars; they would be copied on access if they were properties.
    AKFlangerDSPKernel _kernel;
    BufferedInputBus _inputBus;
}
@synthesize parameterTree = _parameterTree;

- (void)setFrequency:(float)frequency {
    _kernel.setFrequency(frequency);
}
- (void)setDepth:(float)depth {
    _kernel.setDepth(depth);
}
- (void)setDryWetMix:(float)dryWetMix {
    _kernel.setDryWetMix(dryWetMix);
}
- (void)setFeedback:(float)feedback {
    _kernel.setFeedback(feedback);
}


standardKernelPassthroughs()

- (void)createParameters {

    standardSetup(Flanger)

    // Create parameter objects
    AUParameter *frequencyAUParameter = [AUParameter parameter:@"frequency"
                                                         name:@"Mod Frequency in Hz."
                                                      address:frequencyAddress
                                                          min:MIN_FREQUENCY_HZ
                                                          max:MAX_FREQUENCY_HZ
                                                         unit:kAudioUnitParameterUnit_Generic];

    AUParameter *depthAUParameter = [AUParameter parameter:@"depth"
                                                        name:@"Mod depth fraction."
                                                     address:depthAddress
                                                         min:MIN_FRACTION
                                                         max:MAX_FRACTION
                                                        unit:kAudioUnitParameterUnit_Generic];
    
    AUParameter *dryWetMixAUParameter = [AUParameter parameter:@"dryWetMix"
                                                         name:@"Dry Wet Mix."
                                                      address:dryWetMixAddress
                                                          min:MIN_FRACTION
                                                          max:MAX_FRACTION
                                                         unit:kAudioUnitParameterUnit_Generic];

    AUParameter *feedbackAUParameter = [AUParameter parameter:@"feedback"
                                                         name:@"Feedback fraction."
                                                      address:feedbackAddress
                                                          min:FLANGER_MIN_FEEDBACK
                                                          max:FLANGER_MAX_FEEDBACK
                                                         unit:kAudioUnitParameterUnit_Generic];

    // Initialize the parameter values.
    frequencyAUParameter.value = DEFAULT_FREQUENCY_HZ;
    depthAUParameter.value = MIN_FRACTION;
    dryWetMixAUParameter.value = FLANGER_DEFAULT_DRYWETMIX;
    feedbackAUParameter.value = MIN_FRACTION;

    _kernel.setParameter(frequencyAddress, frequencyAUParameter.value);
    _kernel.setParameter(depthAddress, depthAUParameter.value);
    _kernel.setParameter(dryWetMixAddress, dryWetMixAUParameter.value);
    _kernel.setParameter(feedbackAddress, feedbackAUParameter.value);

    // Create the parameter tree.
    _parameterTree = [AUParameterTree tree:@[
                                             frequencyAUParameter,
                                             depthAUParameter,
                                             dryWetMixAUParameter,
                                             feedbackAUParameter
                                             ]];

    parameterTreeBlock(Flanger)
}

AUAudioUnitOverrides(Flanger)

@end
