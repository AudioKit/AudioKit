//
//  AKMorphingOscillatorFilterSynthAudioUnit.mm
//  AudioKit
//
//  Created by Colin Hallett, revision history on Github.
//  Copyright © 2019 AudioKit. All rights reserved.
//
#import <AudioKit/AudioKit-Swift.h>

#import "AKMorphingOscillatorFilterSynthAudioUnit.h"
#import "AKMorphingOscillatorFilterSynthDSPKernel.hpp"

#import "BufferedAudioBus.hpp"

@implementation AKMorphingOscillatorFilterSynthAudioUnit {
    // C++ members need to be ivars; they would be copied on access if they were properties.
    AKMorphingOscillatorFilterSynthDSPKernel _kernel;
    BufferedOutputBus _outputBusBuffer;
}
@synthesize parameterTree = _parameterTree;

- (void)setIndex:(float)index {
    _kernel.setIndex(index);
}

- (void)setupWaveform:(UInt32)waveform size:(int)size {
    _kernel.setupWaveform(waveform, (uint32_t)size);
}

- (void)setWaveform:(UInt32)waveform withValue:(float)value atIndex:(UInt32)index {
    _kernel.setWaveformValue(waveform, index, value);
}

- (void) reset {
    _kernel.reset();
}

- (void)createParameters {

    standardGeneratorSetup(MorphingOscillatorFilterSynth)

    // Create a parameter object for the index.
    AUParameter *indexAUParameter = [AUParameter parameterWithIdentifier:@"index"
                                                                    name:@"Index"
                                                                 address:AKMorphingOscillatorFilterSynthDSPKernel::indexAddress
                                                                     min:0.0
                                                                     max:1.0
                                                                    unit:kAudioUnitParameterUnit_Generic];

    // Initialize the parameter values.
    indexAUParameter.value = 0.0;

    _kernel.setParameter(AKMorphingOscillatorFilterSynthDSPKernel::indexAddress, indexAUParameter.value);

    [self setKernelPtr:&_kernel];

    // Create the parameter tree.
    NSArray *children = [[self standardParameters] arrayByAddingObjectsFromArray:@[indexAUParameter]];
    _parameterTree = [AUParameterTree treeWithChildren:children];
    parameterTreeBlock(MorphingOscillatorFilterSynth)
}

AUAudioUnitGeneratorOverrides(MorphingOscillatorFilterSynth)

@end


