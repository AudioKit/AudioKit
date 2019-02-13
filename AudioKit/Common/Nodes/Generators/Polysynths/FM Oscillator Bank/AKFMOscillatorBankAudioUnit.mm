//
//  AKFMOscillatorBankAudioUnit.mm
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright © 2018 AudioKit. All rights reserved.
//

#import "AKFMOscillatorBankAudioUnit.h"
#import "AKFMOscillatorBankDSPKernel.hpp"

#import "BufferedAudioBus.hpp"

#import <AudioKit/AudioKit-Swift.h>

@implementation AKFMOscillatorBankAudioUnit {
    // C++ members need to be ivars; they would be copied on access if they were properties.
    AKFMOscillatorBankDSPKernel _kernel;
    BufferedOutputBus _outputBusBuffer;
}
@synthesize parameterTree = _parameterTree;

- (void)setCarrierMultiplier:(float)carrierMultiplier {
    _kernel.setCarrierMultiplier(carrierMultiplier);
}
- (void)setModulatingMultiplier:(float)modulatingMultiplier {
    _kernel.setModulatingMultiplier(modulatingMultiplier);
}
- (void)setModulationIndex:(float)modulationIndex {
    _kernel.setModulationIndex(modulationIndex);
}

- (void)setupWaveform:(int)size {
    _kernel.setupWaveform((uint32_t)size);
}
- (void)setWaveformValue:(float)value atIndex:(UInt32)index; {
    _kernel.setWaveformValue(index, value);
}

- (void)createParameters {

    standardGeneratorSetup(FMOscillatorBank)

    // Create a parameter object for the carrier multiplier.
    AUParameter *carrierMultiplierAUParameter =
    [AUParameterTree createParameterWithIdentifier:@"carrierMultiplier"
                                              name:@"Carrier Multiplier"
                                           address:AKFMOscillatorBankDSPKernel::carrierMultiplierAddress
                                               min:0.0
                                               max:1000.0
                                              unit:kAudioUnitParameterUnit_Generic
                                          unitName:nil
                                             flags:0
                                      valueStrings:nil
                               dependentParameters:nil];

    // Create a parameter object for the modulating multiplier.
    AUParameter *modulatingMultiplierAUParameter =
    [AUParameterTree createParameterWithIdentifier:@"modulatingMultiplier"
                                              name:@"Modulating Multiplier"
                                           address:AKFMOscillatorBankDSPKernel::modulatingMultiplierAddress
                                               min:0.0
                                               max:1000.0
                                              unit:kAudioUnitParameterUnit_Generic
                                          unitName:nil
                                             flags:0
                                      valueStrings:nil
                               dependentParameters:nil];

    // Create a parameter object for the modulation index.
    AUParameter *modulationIndexAUParameter =
    [AUParameterTree createParameterWithIdentifier:@"modulationIndex"
                                              name:@"Modulation Index"
                                           address:AKFMOscillatorBankDSPKernel::modulationIndexAddress
                                               min:0.0
                                               max:1000.0
                                              unit:kAudioUnitParameterUnit_Generic
                                          unitName:nil
                                             flags:0
                                      valueStrings:nil
                               dependentParameters:nil];


    // Initialize the parameter values.
    carrierMultiplierAUParameter.value = 1.0;
    modulatingMultiplierAUParameter.value = 1;
    modulationIndexAUParameter.value = 1;

    _kernel.setParameter(AKFMOscillatorBankDSPKernel::carrierMultiplierAddress,    carrierMultiplierAUParameter.value);
    _kernel.setParameter(AKFMOscillatorBankDSPKernel::modulatingMultiplierAddress, modulatingMultiplierAUParameter.value);
    _kernel.setParameter(AKFMOscillatorBankDSPKernel::modulationIndexAddress,      modulationIndexAUParameter.value);

    [self setKernelPtr:&_kernel];
    // Create the parameter tree.
    NSArray *children = [[self standardParameters] arrayByAddingObjectsFromArray:@[carrierMultiplierAUParameter,
                                                                                      modulatingMultiplierAUParameter,
                                                                                      modulationIndexAUParameter]];
    _parameterTree = [AUParameterTree treeWithChildren:children];

    parameterTreeBlock(FMOscillatorBank)
}

AUAudioUnitGeneratorOverrides(FMOscillatorBank)



@end
