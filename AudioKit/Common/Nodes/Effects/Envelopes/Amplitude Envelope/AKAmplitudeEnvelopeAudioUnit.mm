//
//  AKAmplitudeEnvelopeAudioUnit.mm
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright (c) 2016 Aurelius Prochazka. All rights reserved.
//

#import "AKAmplitudeEnvelopeAudioUnit.h"
#import "AKAmplitudeEnvelopeDSPKernel.hpp"

#import "BufferedAudioBus.hpp"

#import <AudioKit/AudioKit-Swift.h>

@implementation AKAmplitudeEnvelopeAudioUnit {
    // C++ members need to be ivars; they would be copied on access if they were properties.
    AKAmplitudeEnvelopeDSPKernel _kernel;

    BufferedInputBus _inputBus;
}
@synthesize parameterTree = _parameterTree;

- (void)setAttackDuration:(float)attackDuration {
    _kernel.setAttackDuration(attackDuration);
}
- (void)setDecayDuration:(float)decayDuration {
    _kernel.setDecayDuration(decayDuration);
}
- (void)setSustainLevel:(float)sustainLevel {
    _kernel.setSustainLevel(sustainLevel);
}
- (void)setReleaseDuration:(float)releaseDuration {
    _kernel.setReleaseDuration(releaseDuration);
}


standardKernelPassthroughs()

- (void)createParameters {

    standardSetup(AmplitudeEnvelope)

    // Create a parameter object for the attackDuration.
    AUParameter *attackDurationAUParameter = [AUParameter parameter:@"attackDuration"
                                                               name:@"Attack time"
                                                            address:attackDurationAddress
                                                                min:0
                                                                max:99
                                                               unit:kAudioUnitParameterUnit_Seconds];
    // Create a parameter object for the decayDuration.
    AUParameter *decayDurationAUParameter = [AUParameter parameter:@"decayDuration"
                                                              name:@"Decay time"
                                                           address:decayDurationAddress
                                                               min:0
                                                               max:99
                                                              unit:kAudioUnitParameterUnit_Seconds];
  // Create a parameter object for the sustainLevel.
    AUParameter *sustainLevelAUParameter = [AUParameter parameter:@"sustainLevel"
                                                             name:@"Sustain Level"
                                                          address:sustainLevelAddress
                                                              min:0
                                                              max:99
                                                             unit:kAudioUnitParameterUnit_Generic];
    // Create a parameter object for the releaseDuration.
    AUParameter *releaseDurationAUParameter = [AUParameter parameter:@"releaseDuration"
                                                                name:@"Release time"
                                                             address:releaseDurationAddress
                                                                 min:0
                                                                 max:99
                                                                unit:kAudioUnitParameterUnit_Seconds];

    // Initialize the parameter values.
    attackDurationAUParameter.value = 0.1;
    decayDurationAUParameter.value = 0.1;
    sustainLevelAUParameter.value = 1.0;
    releaseDurationAUParameter.value = 0.1;

    _kernel.setParameter(attackDurationAddress,  attackDurationAUParameter.value);
    _kernel.setParameter(decayDurationAddress,   decayDurationAUParameter.value);
    _kernel.setParameter(sustainLevelAddress,    sustainLevelAUParameter.value);
    _kernel.setParameter(releaseDurationAddress, releaseDurationAUParameter.value);

    // Create the parameter tree.
    _parameterTree = [AUParameterTree tree:@[
        attackDurationAUParameter,
        decayDurationAUParameter,
        sustainLevelAUParameter,
        releaseDurationAUParameter
    ]];

	parameterTreeBlock(AmplitudeEnvelope)
}

AUAudioUnitOverrides(AmplitudeEnvelope);

@end


