//
//  AKTremoloAudioUnit.mm
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright © 2017 Aurelius Prochazka. All rights reserved.
//

#import "AKTremoloAudioUnit.h"
#import "AKTremoloDSPKernel.hpp"

#import "BufferedAudioBus.hpp"

#import <AudioKit/AudioKit-Swift.h>

@implementation AKTremoloAudioUnit {
    // C++ members need to be ivars; they would be copied on access if they were properties.
    AKTremoloDSPKernel _kernel;

    BufferedInputBus _inputBus;
}
@synthesize parameterTree = _parameterTree;

- (void)setFrequency:(float)frequency {
    _kernel.setFrequency(frequency);
}

- (void)setDepth:(float)depth {
    _kernel.setDepth(depth);
}

- (void)setupWaveform:(int)size {
    _kernel.setupWaveform((uint32_t)size);
}
- (void)setWaveformValue:(float)value atIndex:(UInt32)index; {
    _kernel.setWaveformValue(index, value);
}

standardKernelPassthroughs()

- (void)createParameters {

    standardSetup(Tremolo)

    // Create a parameter object for the frequency.
    AUParameter *frequencyAUParameter = [AUParameter parameter:@"frequency"
                                                          name:@"Frequency (Hz)"
                                                       address:frequencyAddress
                                                           min:0.0
                                                           max:100.0
                                                          unit:kAudioUnitParameterUnit_Hertz];

    // Create a parameter object for the depth.
    AUParameter *depthAUParameter = [AUParameter parameter:@"depth"
                                                      name:@"Depth"
                                                   address:depthAddress
                                                       min:0.0
                                                       max:2.0
                                                      unit:kAudioUnitParameterUnit_Hertz];

    // Initialize the parameter values.
    frequencyAUParameter.value = 10.0;
    // Initialize the parameter values.
    depthAUParameter.value = 1.0;

    _kernel.setParameter(frequencyAddress, frequencyAUParameter.value);
    _kernel.setParameter(depthAddress, depthAUParameter.value);

    // Create the parameter tree.
    _parameterTree = [AUParameterTree tree:@[
        frequencyAUParameter,
        depthAUParameter
    ]];

	parameterTreeBlock(Tremolo)
}

AUAudioUnitOverrides(Tremolo);

@end


