//
//  AKThreePoleLowpassFilterAudioUnit.mm
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright (c) 2016 Aurelius Prochazka. All rights reserved.
//

#import "AKThreePoleLowpassFilterAudioUnit.h"
#import "AKThreePoleLowpassFilterDSPKernel.hpp"

#import <AVFoundation/AVFoundation.h>
#import "BufferedAudioBus.hpp"

#import <AudioKit/AudioKit-Swift.h>

@implementation AKThreePoleLowpassFilterAudioUnit {
    // C++ members need to be ivars; they would be copied on access if they were properties.
    AKThreePoleLowpassFilterDSPKernel _kernel;
    BufferedInputBus _inputBus;
}
@synthesize parameterTree = _parameterTree;

- (void)setDistortion:(float)distortion {
    _kernel.setDistortion(distortion);
}
- (void)setCutoffFrequency:(float)cutoffFrequency {
    _kernel.setCutoffFrequency(cutoffFrequency);
}
- (void)setResonance:(float)resonance {
    _kernel.setResonance(resonance);
}

- (void)start {
    _kernel.start();
}

- (void)stop {
    _kernel.stop();
}

- (BOOL)isPlaying {
    return _kernel.started;
}

- (BOOL)isSetUp {
    return _kernel.resetted;
}

- (void)createParameters {

    standardSetup(ThreePoleLowpassFilter)

    // Create a parameter object for the distortion.
    AUParameter *distortionAUParameter =
    [AUParameterTree createParameterWithIdentifier:@"distortion"
                                              name:@"Distortion (%)"
                                           address:distortionAddress
                                               min:0.0
                                               max:2.0
                                              unit:kAudioUnitParameterUnit_Percent
                                          unitName:nil
                                             flags:0
                                      valueStrings:nil
                               dependentParameters:nil];
    // Create a parameter object for the cutoffFrequency.
    AUParameter *cutoffFrequencyAUParameter =
    [AUParameterTree createParameterWithIdentifier:@"cutoffFrequency"
                                              name:@"Cutoff Frequency (Hz)"
                                           address:cutoffFrequencyAddress
                                               min:12.0
                                               max:20000.0
                                              unit:kAudioUnitParameterUnit_Hertz
                                          unitName:nil
                                             flags:0
                                      valueStrings:nil
                               dependentParameters:nil];
    // Create a parameter object for the resonance.
    AUParameter *resonanceAUParameter =
    [AUParameterTree createParameterWithIdentifier:@"resonance"
                                              name:@"Resonance (%)"
                                           address:resonanceAddress
                                               min:0.0
                                               max:2.0
                                              unit:kAudioUnitParameterUnit_Percent
                                          unitName:nil
                                             flags:0
                                      valueStrings:nil
                               dependentParameters:nil];


    // Initialize the parameter values.
    distortionAUParameter.value = 0.5;
    cutoffFrequencyAUParameter.value = 1500;
    resonanceAUParameter.value = 0.5;

    _kernel.setParameter(distortionAddress,      distortionAUParameter.value);
    _kernel.setParameter(cutoffFrequencyAddress, cutoffFrequencyAUParameter.value);
    _kernel.setParameter(resonanceAddress,       resonanceAUParameter.value);

    // Create the parameter tree.
    _parameterTree = [AUParameterTree createTreeWithChildren:@[
        distortionAUParameter,
        cutoffFrequencyAUParameter,
        resonanceAUParameter
    ]];

    // A function to provide string representations of parameter values.
    _parameterTree.implementorStringFromValueCallback = ^(AUParameter *param, const AUValue *__nullable valuePtr) {
        AUValue value = valuePtr == nil ? param.value : *valuePtr;

        switch (param.address) {
            case distortionAddress:
                return [NSString stringWithFormat:@"%.3f", value];

            case cutoffFrequencyAddress:
                return [NSString stringWithFormat:@"%.3f", value];

            case resonanceAddress:
                return [NSString stringWithFormat:@"%.3f", value];

            default:
                return @"?";
        }
    };

	parameterTreeBlock(ThreePoleLowpassFilter)
}

AUAudioUnitOverrides(ThreePoleLowpassFilter);

@end


