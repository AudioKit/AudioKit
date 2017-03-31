//
//  AKPhaserAudioUnit.mm
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright © 2017 Aurelius Prochazka. All rights reserved.
//

#import "AKPhaserAudioUnit.h"
#import "AKPhaserDSPKernel.hpp"

#import "BufferedAudioBus.hpp"

#import <AudioKit/AudioKit-Swift.h>

@implementation AKPhaserAudioUnit {
    // C++ members need to be ivars; they would be copied on access if they were properties.
    AKPhaserDSPKernel _kernel;
    BufferedInputBus _inputBus;
}
@synthesize parameterTree = _parameterTree;

- (void)setNotchMinimumFrequency:(float)notchMinimumFrequency {
    _kernel.setNotchMinimumFrequency(notchMinimumFrequency);
}
- (void)setNotchMaximumFrequency:(float)notchMaximumFrequency {
    _kernel.setNotchMaximumFrequency(notchMaximumFrequency);
}
- (void)setNotchWidth:(float)notchWidth {
    _kernel.setNotchWidth(notchWidth);
}
- (void)setNotchFrequency:(float)notchFrequency {
    _kernel.setNotchFrequency(notchFrequency);
}
- (void)setVibratoMode:(float)vibratoMode {
    _kernel.setVibratoMode(vibratoMode);
}
- (void)setDepth:(float)depth {
    _kernel.setDepth(depth);
}
- (void)setFeedback:(float)feedback {
    _kernel.setFeedback(feedback);
}
- (void)setInverted:(float)inverted {
    _kernel.setInverted(inverted);
}
- (void)setLfoBPM:(float)lfoBPM {
    _kernel.setLfoBPM(lfoBPM);
}

standardKernelPassthroughs()

- (void)createParameters {

    standardSetup(Phaser)

    // Create a parameter object for the notchMinimumFrequency.
    AUParameter *notchMinimumFrequencyAUParameter =
    [AUParameter parameter:@"notchMinimumFrequency"
                      name:@"Notch Minimum Frequency"
                   address:notchMinimumFrequencyAddress
                       min:20
                       max:5000
                      unit:kAudioUnitParameterUnit_Hertz];
    // Create a parameter object for the notchMaximumFrequency.
    AUParameter *notchMaximumFrequencyAUParameter =
    [AUParameter parameter:@"notchMaximumFrequency"
                      name:@"Notch Maximum Frequency"
                   address:notchMaximumFrequencyAddress
                       min:20
                       max:10000
                      unit:kAudioUnitParameterUnit_Hertz];
    // Create a parameter object for the notchWidth.
    AUParameter *notchWidthAUParameter =
    [AUParameter parameter:@"notchWidth"
                      name:@"Between 10 and 5000"
                   address:notchWidthAddress
                       min:10
                       max:5000
                      unit:kAudioUnitParameterUnit_Hertz];
    // Create a parameter object for the notchFrequency.
    AUParameter *notchFrequencyAUParameter =
    [AUParameter parameter:@"notchFrequency"
                      name:@"Between 1.1 and 4"
                   address:notchFrequencyAddress
                       min:1.1
                       max:4.0
                      unit:kAudioUnitParameterUnit_Hertz];
    // Create a parameter object for the vibratoMode.
    AUParameter *vibratoModeAUParameter =
    [AUParameter parameter:@"vibratoMode"
                      name:@"1 or 0"
                   address:vibratoModeAddress
                       min:0
                       max:1
                      unit:kAudioUnitParameterUnit_Generic];
    // Create a parameter object for the depth.
    AUParameter *depthAUParameter =
    [AUParameter parameter:@"depth"
                      name:@"Between 0 and 1"
                   address:depthAddress
                       min:0
                       max:1
                      unit:kAudioUnitParameterUnit_Generic];
    // Create a parameter object for the feedback.
    AUParameter *feedbackAUParameter =
    [AUParameter parameter:@"feedback"
                      name:@"Between 0 and 1"
                   address:feedbackAddress
                       min:0
                       max:1
                      unit:kAudioUnitParameterUnit_Generic];
    // Create a parameter object for the inverted.
    AUParameter *invertedAUParameter =
    [AUParameter parameter:@"inverted"
                      name:@"1 or 0"
                   address:invertedAddress
                       min:0
                       max:1
                      unit:kAudioUnitParameterUnit_Generic];
    // Create a parameter object for the lfoBPM.
    AUParameter *lfoBPMAUParameter =
    [AUParameter parameter:@"lfoBPM"
                      name:@"Between 24 and 360"
                   address:lfoBPMAddress
                       min:24
                       max:360
                      unit:kAudioUnitParameterUnit_Generic];


    // Initialize the parameter values.
    notchMinimumFrequencyAUParameter.value = 100;
    notchMaximumFrequencyAUParameter.value = 800;
    notchWidthAUParameter.value = 1000;
    notchFrequencyAUParameter.value = 1.5;
    vibratoModeAUParameter.value = 1;
    depthAUParameter.value = 1;
    feedbackAUParameter.value = 0;
    invertedAUParameter.value = 0;
    lfoBPMAUParameter.value = 30;

    _kernel.setParameter(notchMinimumFrequencyAddress, notchMinimumFrequencyAUParameter.value);
    _kernel.setParameter(notchMaximumFrequencyAddress, notchMaximumFrequencyAUParameter.value);
    _kernel.setParameter(notchWidthAddress,            notchWidthAUParameter.value);
    _kernel.setParameter(notchFrequencyAddress,        notchFrequencyAUParameter.value);
    _kernel.setParameter(vibratoModeAddress,           vibratoModeAUParameter.value);
    _kernel.setParameter(depthAddress,                 depthAUParameter.value);
    _kernel.setParameter(feedbackAddress,              feedbackAUParameter.value);
    _kernel.setParameter(invertedAddress,              invertedAUParameter.value);
    _kernel.setParameter(lfoBPMAddress,                lfoBPMAUParameter.value);

    // Create the parameter tree.
    _parameterTree = [AUParameterTree tree:@[
        notchMinimumFrequencyAUParameter,
        notchMaximumFrequencyAUParameter,
        notchWidthAUParameter,
        notchFrequencyAUParameter,
        vibratoModeAUParameter,
        depthAUParameter,
        feedbackAUParameter,
        invertedAUParameter,
        lfoBPMAUParameter
    ]];

    parameterTreeBlock(Phaser)
}

AUAudioUnitOverrides(Phaser);

@end


