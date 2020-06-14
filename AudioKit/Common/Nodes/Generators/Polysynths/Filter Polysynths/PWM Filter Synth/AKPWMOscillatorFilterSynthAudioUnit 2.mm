//
//  AKPWMOscillatorFilterSynthAudioUnit.mm
//  AudioKit
//
//  Created by Colin Hallett, revision history on Github.
//  Copyright © 2019 AudioKit. All rights reserved.
//

#import <AudioKit/AudioKit-Swift.h>

#import "AKPWMOscillatorFilterSynthAudioUnit.h"
#import "AKPWMOscillatorFilterSynthDSPKernel.hpp"

#import "BufferedAudioBus.hpp"

@implementation AKPWMOscillatorFilterSynthAudioUnit {
    // C++ members need to be ivars; they would be copied on access if they were properties.
    AKPWMOscillatorFilterSynthDSPKernel _kernel;
    BufferedOutputBus _outputBusBuffer;
}
@synthesize parameterTree = _parameterTree;

- (void)setPulseWidth:(float)pulseWidth {
    _kernel.setPulseWidth(pulseWidth);
}

- (void)createParameters {

    standardGeneratorSetup(PWMOscillatorFilterSynth)

    // Create a parameter object for the pulseWidth.
    AUParameter *pulseWidthAUParameter = [AUParameter parameterWithIdentifier:@"pulseWidth"
                                                                         name:@"Pulse Width"
                                                                      address:AKPWMOscillatorFilterSynthDSPKernel::pulseWidthAddress
                                                                          min:0.0
                                                                          max:1.0
                                                                         unit:kAudioUnitParameterUnit_Generic];

    // Initialize the parameter values.
    pulseWidthAUParameter.value = 0.5;

    _kernel.setParameter(AKPWMOscillatorFilterSynthDSPKernel::pulseWidthAddress, pulseWidthAUParameter.value);

    [self setKernelPtr:&_kernel];

    // Create the parameter tree.
    NSArray *children = [[self standardParameters] arrayByAddingObjectsFromArray:@[pulseWidthAUParameter]];
    _parameterTree = [AUParameterTree treeWithChildren:children];

    parameterTreeBlock(PWMOscillatorFilterSynth)
}

AUAudioUnitGeneratorOverrides(PWMOscillatorFilterSynth)

@end


