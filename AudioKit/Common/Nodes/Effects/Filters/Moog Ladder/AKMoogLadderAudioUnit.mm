//
//  AKMoogLadderAudioUnit.mm
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright (c) 2016 Aurelius Prochazka. All rights reserved.
//

#import "AKMoogLadderAudioUnit.h"
#import "AKMoogLadderDSPKernel.hpp"

#import "BufferedAudioBus.hpp"

#import <AudioKit/AudioKit-Swift.h>

@implementation AKMoogLadderAudioUnit {
    // C++ members need to be ivars; they would be copied on access if they were properties.
    AKMoogLadderDSPKernel _kernel;
    BufferedInputBus _inputBus;
}
@synthesize parameterTree = _parameterTree;

- (void)setCutoffFrequency:(float)cutoffFrequency {
    _kernel.setCutoffFrequency(cutoffFrequency);
}
- (void)setResonance:(float)resonance {
    _kernel.setResonance(resonance);
}

standardKernelPassthroughs()

- (void)createParameters {

    standardSetup(MoogLadder)

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
    cutoffFrequencyAUParameter.value = 1000;
    resonanceAUParameter.value = 0.5;

    _kernel.setParameter(cutoffFrequencyAddress, cutoffFrequencyAUParameter.value);
    _kernel.setParameter(resonanceAddress,       resonanceAUParameter.value);

    // Create the parameter tree.
    _parameterTree = [AUParameterTree createTreeWithChildren:@[
        cutoffFrequencyAUParameter,
        resonanceAUParameter
    ]];

    // A function to provide string representations of parameter values.
    _parameterTree.implementorStringFromValueCallback = ^(AUParameter *param, const AUValue *__nullable valuePtr) {
        AUValue value = valuePtr == nil ? param.value : *valuePtr;

        switch (param.address) {
            case cutoffFrequencyAddress:
                return [NSString stringWithFormat:@"%.3f", value];

            case resonanceAddress:
                return [NSString stringWithFormat:@"%.3f", value];

            default:
                return @"?";
        }
    };

	parameterTreeBlock(MoogLadder)
}

AUAudioUnitOverrides(MoogLadder);

@end


