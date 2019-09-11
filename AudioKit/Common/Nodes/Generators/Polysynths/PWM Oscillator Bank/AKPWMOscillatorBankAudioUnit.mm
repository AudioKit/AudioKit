//
//  AKPWMOscillatorBankAudioUnit.mm
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright © 2018 AudioKit. All rights reserved.
//

#import <AudioKit/AudioKit-Swift.h>

#import "AKPWMOscillatorBankAudioUnit.h"
#import "AKPWMOscillatorBankDSPKernel.hpp"

#import "BufferedAudioBus.hpp"

@implementation AKPWMOscillatorBankAudioUnit {
    // C++ members need to be ivars; they would be copied on access if they were properties.
    AKPWMOscillatorBankDSPKernel _kernel;
    BufferedOutputBus _outputBusBuffer;
}
@synthesize parameterTree = _parameterTree;

- (void)setPulseWidth:(float)pulseWidth {
    _kernel.setPulseWidth(pulseWidth);
}

- (void)createParameters {
    
    standardGeneratorSetup(PWMOscillatorBank)
    
    // Create a parameter object for the pulseWidth.
    AUParameter *pulseWidthAUParameter = [AUParameter parameterWithIdentifier:@"pulseWidth"
                                                                         name:@"Pulse Width"
                                                                      address:AKPWMOscillatorBankDSPKernel::pulseWidthAddress
                                                                          min:0.0
                                                                          max:1.0
                                                                         unit:kAudioUnitParameterUnit_Generic];
    
    // Initialize the parameter values.
    pulseWidthAUParameter.value = 0.5;
    
    _kernel.setParameter(AKPWMOscillatorBankDSPKernel::pulseWidthAddress, pulseWidthAUParameter.value);
    
    [self setKernelPtr:&_kernel];
    
    // Create the parameter tree.
    NSArray *children = [[self standardParameters] arrayByAddingObjectsFromArray:@[pulseWidthAUParameter]];
    _parameterTree = [AUParameterTree treeWithChildren:children];
    
    parameterTreeBlock(PWMOscillatorBank)
}

AUAudioUnitGeneratorOverrides(PWMOscillatorBank)

@end


