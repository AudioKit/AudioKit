// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

#import "AKOscillatorFilterSynthAudioUnit.h"
#import "AKOscillatorFilterSynthDSPKernel.hpp"

#import "BufferedAudioBus.hpp"

@implementation AKOscillatorFilterSynthAudioUnit {
    // C++ members need to be ivars; they would be copied on access if they were properties.
    AKOscillatorFilterSynthDSPKernel _kernel;
    BufferedOutputBus _outputBusBuffer;
}
@synthesize parameterTree = _parameterTree;

- (void)setupWaveform:(int)size {
    _kernel.setupWaveform((uint32_t)size);
}
- (void)setWaveformValue:(float)value atIndex:(UInt32)index; {
    _kernel.setWaveformValue(index, value);
}

- (void)reset {
    _kernel.reset();
}

- (void)createParameters {

    standardGeneratorSetup(OscillatorFilterSynth)

    [self setKernelPtr:&_kernel];

    // Create the parameter tree.
    _parameterTree = [AUParameterTree treeWithChildren:[self standardParameters]];

    parameterTreeBlock(OscillatorFilterSynth)
}

AUAudioUnitGeneratorOverrides(OscillatorFilterSynth)


@end
