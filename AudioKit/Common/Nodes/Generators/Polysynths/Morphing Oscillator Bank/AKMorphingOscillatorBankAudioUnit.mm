//
//  AKMorphingOscillatorBankAudioUnit.mm
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright © 2018 AudioKit. All rights reserved.
//
#import <AudioKit/AudioKit-Swift.h>

#import "AKMorphingOscillatorBankAudioUnit.h"
#import "AKMorphingOscillatorBankDSPKernel.hpp"

#import "BufferedAudioBus.hpp"

@implementation AKMorphingOscillatorBankAudioUnit {
    // C++ members need to be ivars; they would be copied on access if they were properties.
    AKMorphingOscillatorBankDSPKernel _kernel;
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
    
    standardGeneratorSetup(MorphingOscillatorBank)
    
    // Create a parameter object for the index.
    AUParameter *indexAUParameter = [AUParameter parameterWithIdentifier:@"index"
                                                                    name:@"Index"
                                                                 address:AKMorphingOscillatorBankDSPKernel::indexAddress
                                                                     min:0.0
                                                                     max:1.0
                                                                    unit:kAudioUnitParameterUnit_Generic];
    
    // Initialize the parameter values.
    indexAUParameter.value = 0.0;
    
    _kernel.setParameter(AKMorphingOscillatorBankDSPKernel::indexAddress, indexAUParameter.value);
    
    [self setKernelPtr:&_kernel];
    
    // Create the parameter tree.
    NSArray *children = [[self standardParameters] arrayByAddingObjectsFromArray:@[indexAUParameter]];
    _parameterTree = [AUParameterTree treeWithChildren:children];
    parameterTreeBlock(MorphingOscillatorBank)
}

AUAudioUnitGeneratorOverrides(MorphingOscillatorBank)

@end


