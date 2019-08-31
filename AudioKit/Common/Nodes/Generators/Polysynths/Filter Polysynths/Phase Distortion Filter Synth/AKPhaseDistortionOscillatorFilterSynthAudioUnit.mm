//
//  AKPhaseDistortionOscillatorFilterSynthAudioUnit.mm
//  AudioKit
//
//  Created by Colin Hallett, revision history on Github.
//  Copyright © 2019 AudioKit. All rights reserved.
//

#import "AKPhaseDistortionOscillatorFilterSynthAudioUnit.h"
#import "AKPhaseDistortionOscillatorFilterSynthDSPKernel.hpp"

#import "BufferedAudioBus.hpp"

#import <AudioKit/AudioKit-Swift.h>

@implementation AKPhaseDistortionOscillatorFilterSynthAudioUnit {
    // C++ members need to be ivars; they would be copied on access if they were properties.
    AKPhaseDistortionOscillatorFilterSynthDSPKernel _kernel;
    BufferedOutputBus _outputBusBuffer;
}
@synthesize parameterTree = _parameterTree;

- (void)setPhaseDistortion:(float)phaseDistortion {
    _kernel.setPhaseDistortion(phaseDistortion);
}

- (void)setupWaveform:(int)size {
    _kernel.setupWaveform((uint32_t)size);
}
- (void)setWaveformValue:(float)value atIndex:(UInt32)index; {
    _kernel.setWaveformValue(index, value);
}

- (void)createParameters {

    standardGeneratorSetup(PhaseDistortionOscillatorFilterSynth)

    // Create a parameter object for the phaseDistortion.
    AUParameter *phaseDistortionAUParameter = [AUParameter parameterWithIdentifier:@"phaseDistortion"
                                                                              name:@"Phase Distortion"
                                                                           address:AKPhaseDistortionOscillatorFilterSynthDSPKernel::phaseDistortionAddress
                                                                               min:0.0
                                                                               max:1.0
                                                                              unit:kAudioUnitParameterUnit_Generic];

    // Initialize the parameter values.
    phaseDistortionAUParameter.value = 0.0;

    _kernel.setParameter(AKPhaseDistortionOscillatorFilterSynthDSPKernel::phaseDistortionAddress, phaseDistortionAUParameter.value);

    [self setKernelPtr:&_kernel];

    // Create the parameter tree.
    NSArray *children = [[self standardParameters] arrayByAddingObjectsFromArray:@[phaseDistortionAUParameter]];
    _parameterTree = [AUParameterTree treeWithChildren:children];
    parameterTreeBlock(PhaseDistortionOscillatorFilterSynth)
}

AUAudioUnitGeneratorOverrides(PhaseDistortionOscillatorFilterSynth)


@end


