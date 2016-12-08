//
//  AKRolandTB303FilterAudioUnit.mm
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright (c) 2016 Aurelius Prochazka. All rights reserved.
//

#import "AKRolandTB303FilterAudioUnit.h"
#import "AKRolandTB303FilterDSPKernel.hpp"

#import "BufferedAudioBus.hpp"

#import <AudioKit/AudioKit-Swift.h>

@implementation AKRolandTB303FilterAudioUnit {
    // C++ members need to be ivars; they would be copied on access if they were properties.
    AKRolandTB303FilterDSPKernel _kernel;
    BufferedInputBus _inputBus;
}
@synthesize parameterTree = _parameterTree;

- (void)setCutoffFrequency:(float)cutoffFrequency {
    _kernel.setCutoffFrequency(cutoffFrequency);
}
- (void)setResonance:(float)resonance {
    _kernel.setResonance(resonance);
}
- (void)setDistortion:(float)distortion {
    _kernel.setDistortion(distortion);
}
- (void)setResonanceAsymmetry:(float)resonanceAsymmetry {
    _kernel.setResonanceAsymmetry(resonanceAsymmetry);
}

standardKernelPassthroughs()

- (void)createParameters {

    standardSetup(RolandTB303Filter)

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
                                              name:@"Resonance"
                                           address:resonanceAddress
                                               min:0.0
                                               max:2.0
                                              unit:kAudioUnitParameterUnit_Generic
                                          unitName:nil
                                             flags:0
                                      valueStrings:nil
                               dependentParameters:nil];
    // Create a parameter object for the distortion.
    AUParameter *distortionAUParameter =
    [AUParameterTree createParameterWithIdentifier:@"distortion"
                                              name:@"Distortion"
                                           address:distortionAddress
                                               min:0.0
                                               max:4.0
                                              unit:kAudioUnitParameterUnit_Generic
                                          unitName:nil
                                             flags:0
                                      valueStrings:nil
                               dependentParameters:nil];
    // Create a parameter object for the resonanceAsymmetry.
    AUParameter *resonanceAsymmetryAUParameter =
    [AUParameterTree createParameterWithIdentifier:@"resonanceAsymmetry"
                                              name:@"Resonance Asymmetry"
                                           address:resonanceAsymmetryAddress
                                               min:0.0
                                               max:1.0
                                              unit:kAudioUnitParameterUnit_Generic
                                          unitName:nil
                                             flags:0
                                      valueStrings:nil
                               dependentParameters:nil];


    // Initialize the parameter values.
    cutoffFrequencyAUParameter.value = 500;
    resonanceAUParameter.value = 0.5;
    distortionAUParameter.value = 2.0;
    resonanceAsymmetryAUParameter.value = 0.5;

    _kernel.setParameter(cutoffFrequencyAddress,    cutoffFrequencyAUParameter.value);
    _kernel.setParameter(resonanceAddress,          resonanceAUParameter.value);
    _kernel.setParameter(distortionAddress,         distortionAUParameter.value);
    _kernel.setParameter(resonanceAsymmetryAddress, resonanceAsymmetryAUParameter.value);

    // Create the parameter tree.
    _parameterTree = [AUParameterTree createTreeWithChildren:@[
        cutoffFrequencyAUParameter,
        resonanceAUParameter,
        distortionAUParameter,
        resonanceAsymmetryAUParameter
    ]];

    // A function to provide string representations of parameter values.
    _parameterTree.implementorStringFromValueCallback = ^(AUParameter *param, const AUValue *__nullable valuePtr) {
        AUValue value = valuePtr == nil ? param.value : *valuePtr;

        switch (param.address) {
            case cutoffFrequencyAddress:
                return [NSString stringWithFormat:@"%.3f", value];

            case resonanceAddress:
                return [NSString stringWithFormat:@"%.3f", value];

            case distortionAddress:
                return [NSString stringWithFormat:@"%.3f", value];

            case resonanceAsymmetryAddress:
                return [NSString stringWithFormat:@"%.3f", value];

            default:
                return @"?";
        }
    };

	parameterTreeBlock(RolandTB303Filter)
}

AUAudioUnitOverrides(RolandTB303Filter);

@end


