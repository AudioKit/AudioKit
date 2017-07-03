//
//  AKPWMOscillatorBankAudioUnit.mm
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright © 2017 Aurelius Prochazka. All rights reserved.
//

#import "AKPWMOscillatorBankAudioUnit.h"
#import "AKPWMOscillatorBankDSPKernel.hpp"

#import "BufferedAudioBus.hpp"

#import <AudioKit/AudioKit-Swift.h>

@implementation AKPWMOscillatorBankAudioUnit {
    // C++ members need to be ivars; they would be copied on access if they were properties.
    AKPWMOscillatorBankDSPKernel _kernel;
    BufferedOutputBus _outputBusBuffer;
}
@synthesize parameterTree = _parameterTree;
- (void)setPulseWidth:(float)pulseWidth {
    _kernel.setPulseWidth(pulseWidth);
}

standardBankFunctions()

- (void)createParameters {

    standardGeneratorSetup(PWMOscillatorBank)
    standardBankParameters()
    
    // Create a parameter object for the pulseWidth.
    AUParameter *pulseWidthAUParameter = [AUParameter parameter:@"pulseWidth"
                                                           name:@"Pulse Width"
                                                        address:pulseWidthAddress
                                                            min:0.0
                                                            max:1.0
                                                           unit:kAudioUnitParameterUnit_Generic];

    // Initialize the parameter values.
    pulseWidthAUParameter.value = 0.5;

    _kernel.setParameter(pulseWidthAddress, pulseWidthAUParameter.value);

    // Create the parameter tree.
    _parameterTree = [AUParameterTree createTreeWithChildren:@[
        pulseWidthAUParameter,
        attackDurationAUParameter,
        decayDurationAUParameter,
        sustainLevelAUParameter,
        releaseDurationAUParameter,
        detuningOffsetAUParameter,
        detuningMultiplierAUParameter
    ]];

	parameterTreeBlock(PWMOscillatorBank)
}

AUAudioUnitGeneratorOverrides(PWMOscillatorBank)

@end


