//
//  AKMorphingOscillatorBankAudioUnit.mm
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright © 2017 Aurelius Prochazka. All rights reserved.
//

#import "AKMorphingOscillatorBankAudioUnit.h"
#import "AKMorphingOscillatorBankDSPKernel.hpp"

#import "BufferedAudioBus.hpp"

#import <AudioKit/AudioKit-Swift.h>


@implementation AKMorphingOscillatorBankAudioUnit {
    // C++ members need to be ivars; they would be copied on access if they were properties.
    AKMorphingOscillatorBankDSPKernel _kernel;
    BufferedOutputBus _outputBusBuffer;
}
@synthesize parameterTree = _parameterTree;

- (void)setIndex:(float)index {
    _kernel.setIndex(index);
}

standardBankFunctions()

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
    standardBankParameters()

    // Create the parameter tree.
    _parameterTree = [AUParameterTree createTreeWithChildren:@[
        attackDurationAUParameter,
        decayDurationAUParameter,
        sustainLevelAUParameter,
        releaseDurationAUParameter,
        detuningOffsetAUParameter,
        detuningMultiplierAUParameter
    ]];
	parameterTreeBlock(MorphingOscillatorBank)
}

AUAudioUnitGeneratorOverrides(MorphingOscillatorBank)

@end


