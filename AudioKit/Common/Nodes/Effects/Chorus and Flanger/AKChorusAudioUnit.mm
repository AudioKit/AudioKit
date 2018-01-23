//
//  AKChorusAudioUnit.mm
//  AudioKit
//
//  Created by Shane Dunne
//  Copyright © 2018 Shane Dunne. All rights reserved.
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

- (void)setModFreq:(float)modFreq {
    _kernel.setModFreq(modFreq);
}
- (void)setModDepth:(float)modDepth {
    _kernel.setModDepth(modDepth);
}
- (void)setWetFraction:(float)wetFraction {
    _kernel.setWetFraction(wetFraction);
}
- (void)setFeedback:(float)feedback {
    _kernel.setFeedback(feedback);
}


standardKernelPassthroughs()

- (void)createParameters {

    standardSetup(Chorus)

    // Create parameter objects
    AUParameter *modFreqAUParameter = [AUParameter parameter:@"modFreq"
                                                        name:@"Mod Frequency in Hz."
                                                     address:modFreqAddress
                                                         min:MIN_MODFREQ_HZ
                                                         max:MAX_MODFREQ_HZ
                                                        unit:kAudioUnitParameterUnit_Generic];
    
    AUParameter *modDepthAUParameter = [AUParameter parameter:@"modDepth"
                                                         name:@"Mod depth fraction."
                                                      address:modDepthAddress
                                                          min:MIN_FRACTION
                                                          max:MAX_FRACTION
                                                         unit:kAudioUnitParameterUnit_Generic];
    
    AUParameter *wetFractionAUParameter = [AUParameter parameter:@"wetFraction"
                                                            name:@"Wet fraction."
                                                         address:wetFractionAddress
                                                             min:MIN_FRACTION
                                                             max:MAX_FRACTION
                                                            unit:kAudioUnitParameterUnit_Generic];
    
    AUParameter *feedbackAUParameter = [AUParameter parameter:@"feedback"
                                                         name:@"Feedback fraction."
                                                      address:feedbackAddress
                                                          min:CHORUS_MIN_FEEDBACK
                                                          max:CHORUS_MAX_FEEDBACK
                                                         unit:kAudioUnitParameterUnit_Generic];

    // Initialize the parameter values.
    modFreqAUParameter.value = DEFAULT_MODFREQ_HZ;
    modDepthAUParameter.value = MIN_FRACTION;
    wetFractionAUParameter.value = CHORUS_DEFAULT_WETFRACTION;
    feedbackAUParameter.value = MIN_FRACTION;

    _kernel.setParameter(modFreqAddress, modFreqAUParameter.value);
    _kernel.setParameter(modDepthAddress, modDepthAUParameter.value);
    _kernel.setParameter(wetFractionAddress, wetFractionAUParameter.value);
    _kernel.setParameter(feedbackAddress, feedbackAUParameter.value);

    // Create the parameter tree.
    _parameterTree = [AUParameterTree tree:@[
                                             modFreqAUParameter,
                                             modDepthAUParameter,
                                             wetFractionAUParameter,
                                             feedbackAUParameter
                                             ]];

    parameterTreeBlock(Chorus)
}

AUAudioUnitOverrides(Chorus)

@end
