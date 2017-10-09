//
//  AKOscillatorBankAudioUnit.mm
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright © 2017 Aurelius Prochazka. All rights reserved.
//

#import "AKOscillatorBankAudioUnit.h"
#import "AKOscillatorBankDSPKernel.hpp"

#import "BufferedAudioBus.hpp"

#import <AudioKit/AudioKit-Swift.h>

@implementation AKOscillatorBankAudioUnit {
    // C++ members need to be ivars; they would be copied on access if they were properties.
    AKOscillatorBankDSPKernel _kernel;
    BufferedOutputBus _outputBusBuffer;
}
@synthesize parameterTree = _parameterTree;

standardBankFunctions()

- (void)setupWaveform:(int)size {
    _kernel.setupWaveform((uint32_t)size);
}
- (void)setWaveformValue:(float)value atIndex:(UInt32)index; {
    _kernel.setWaveformValue(index, value);
}

//- (void)startNote:(uint8_t)note velocity:(uint8_t)velocity {
//    _kernel.startNote(note, velocity);
//}
//- (void)startNote:(uint8_t)note velocity:(uint8_t)velocity frequency:(float)frequency {
//    _kernel.startNote(note, velocity, frequency);
//}
//
//- (void)stopNote:(uint8_t)note {
//    _kernel.stopNote(note);
//}
//
//- (BOOL)isSetUp {
//    return _kernel.resetted;
//}

- (void)reset {
    _kernel.reset();
}

- (void)createParameters {
    
    standardGeneratorSetup(OscillatorBank)
    standardBankParameters()
    
    // Create the parameter tree.
    _parameterTree = [AUParameterTree createTreeWithChildren:@[
                                                               standardBankAUParameterList()
                                                               ]];
    
    parameterTreeBlock(OscillatorBank)
}

AUAudioUnitGeneratorOverrides(OscillatorBank)


@end
