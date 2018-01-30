//
//  AKChorusAudioUnit.mm
//  AudioKit
//
//  Created by Shane Dunne
//  Copyright © 2018 AudioKit. All rights reserved.
//

#import "AKChorusAudioUnit.h"
#import "SDModulatedDelayDSPKernel.hpp"

#import "BufferedAudioBus.hpp"

#import <AudioKit/AudioKit-Swift.h>

@implementation AKChorusAudioUnit {
    // C++ members need to be ivars; they would be copied on access if they were properties.
    AKChorusDSPKernel _kernel;
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

    standardSetup(Chorus)

    // Create parameter objects
    AUParameter *frequencyAUParameter = [AUParameter parameter:@"frequency"
                                                        name:@"Mod Frequency in Hz."
                                                       address:AKChorusDSPKernel::frequencyAddress
                                                         min:MIN_FREQUENCY_HZ
                                                         max:MAX_FREQUENCY_HZ
                                                        unit:kAudioUnitParameterUnit_Generic];
    
    AUParameter *depthAUParameter = [AUParameter parameter:@"depth"
                                                         name:@"Mod depth fraction."
                                                      address:AKChorusDSPKernel::depthAddress
                                                          min:MIN_FRACTION
                                                          max:MAX_FRACTION
                                                         unit:kAudioUnitParameterUnit_Generic];
    
    AUParameter *dryWetMixAUParameter = [AUParameter parameter:@"dryWetMix"
                                                            name:@"Dry Wet Mix."
                                                         address:AKChorusDSPKernel::dryWetMixAddress
                                                             min:MIN_FRACTION
                                                             max:MAX_FRACTION
                                                            unit:kAudioUnitParameterUnit_Generic];
    
    AUParameter *feedbackAUParameter = [AUParameter parameter:@"feedback"
                                                         name:@"Feedback fraction."
                                                      address:AKChorusDSPKernel::feedbackAddress
                                                          min:CHORUS_MIN_FEEDBACK
                                                          max:CHORUS_MAX_FEEDBACK
                                                         unit:kAudioUnitParameterUnit_Generic];

    // Initialize the parameter values.
    frequencyAUParameter.value = DEFAULT_FREQUENCY_HZ;
    depthAUParameter.value = MIN_FRACTION;
    dryWetMixAUParameter.value = CHORUS_DEFAULT_DRYWETMIX;
    feedbackAUParameter.value = MIN_FRACTION;

    _kernel.setParameter(AKChorusDSPKernel::frequencyAddress, frequencyAUParameter.value);
    _kernel.setParameter(AKChorusDSPKernel::depthAddress, depthAUParameter.value);
    _kernel.setParameter(AKChorusDSPKernel::dryWetMixAddress, dryWetMixAUParameter.value);
    _kernel.setParameter(AKChorusDSPKernel::feedbackAddress, feedbackAUParameter.value);

    // Create the parameter tree.
    _parameterTree = [AUParameterTree tree:@[
                                             frequencyAUParameter,
                                             depthAUParameter,
                                             dryWetMixAUParameter,
                                             feedbackAUParameter
                                             ]];

    parameterTreeBlock(Chorus)
}

AUAudioUnitOverrides(Chorus)

@end
