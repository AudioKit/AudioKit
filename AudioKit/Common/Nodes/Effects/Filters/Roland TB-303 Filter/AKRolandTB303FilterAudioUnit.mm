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
    AUParameter *cutoffFrequencyAUParameter = [AUParameter frequency:@"cutoffFrequency"
                                                                name:@"Cutoff Frequency (Hz)"
                                                             address:cutoffFrequencyAddress];
  // Create a parameter object for the resonance.
    AUParameter *resonanceAUParameter = [AUParameter parameter:@"resonance"
                                                          name:@"Resonance"
                                                       address:resonanceAddress
                                                           min:0.0
                                                           max:2.0
                                                          unit:kAudioUnitParameterUnit_Generic];
    // Create a parameter object for the distortion.
    AUParameter *distortionAUParameter = [AUParameter parameter:@"distortion"
                                                           name:@"Distortion"
                                                        address:distortionAddress
                                                            min:0.0
                                                            max:4.0
                                                           unit:kAudioUnitParameterUnit_Generic];
    // Create a parameter object for the resonanceAsymmetry.
    AUParameter *resonanceAsymmetryAUParameter = [AUParameter parameter:@"resonanceAsymmetry"
                                                                   name:@"Resonance Asymmetry"
                                                                address:resonanceAsymmetryAddress
                                                                    min:0.0
                                                                    max:1.0
                                                                   unit:kAudioUnitParameterUnit_Generic];

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
    _parameterTree = [AUParameterTree tree:@[
        cutoffFrequencyAUParameter,
        resonanceAUParameter,
        distortionAUParameter,
        resonanceAsymmetryAUParameter
    ]];

	parameterTreeBlock(RolandTB303Filter)
}

AUAudioUnitOverrides(RolandTB303Filter);

@end


