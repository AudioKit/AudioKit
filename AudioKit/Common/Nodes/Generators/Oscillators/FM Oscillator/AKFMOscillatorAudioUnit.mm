//
//  AKFMOscillatorAudioUnit.mm
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright (c) 2016 Aurelius Prochazka. All rights reserved.
//

#import "AKFMOscillatorAudioUnit.h"
#import "AKFMOscillatorDSPKernel.hpp"

#import "BufferedAudioBus.hpp"

#import <AudioKit/AudioKit-Swift.h>

@implementation AKFMOscillatorAudioUnit {
    // C++ members need to be ivars; they would be copied on access if they were properties.
    AKFMOscillatorDSPKernel _kernel;
    BufferedInputBus _inputBus;
}
@synthesize parameterTree = _parameterTree;

- (void)setBaseFrequency:(float)baseFrequency {
    _kernel.setBaseFrequency(baseFrequency);
}
- (void)setCarrierMultiplier:(float)carrierMultiplier {
    _kernel.setCarrierMultiplier(carrierMultiplier);
}
- (void)setModulatingMultiplier:(float)modulatingMultiplier {
    _kernel.setModulatingMultiplier(modulatingMultiplier);
}
- (void)setModulationIndex:(float)modulationIndex {
    _kernel.setModulationIndex(modulationIndex);
}
- (void)setAmplitude:(float)amplitude {
    _kernel.setAmplitude(amplitude);
}

- (void)setupWaveform:(int)size {
    _kernel.setupWaveform((uint32_t)size);
}
- (void)setWaveformValue:(float)value atIndex:(UInt32)index; {
    _kernel.setWaveformValue(index, value);
}

standardKernelPassthroughs()

- (void)createParameters {

    standardSetup(FMOscillator)

    // Create a parameter object for the baseFrequency.
    AUParameter *baseFrequencyAUParameter = [AUParameter parameter:@"baseFrequency"
                                                              name:@"Base Frequency (Hz)"
                                                           address:baseFrequencyAddress
                                                               min:0.0
                                                               max:20000.0
                                                              unit:kAudioUnitParameterUnit_Hertz];
    // Create a parameter object for the carrierMultiplier.
    AUParameter *carrierMultiplierAUParameter = [AUParameter parameter:@"carrierMultiplier"
                                                                  name:@"Carrier Multiplier"
                                                               address:carrierMultiplierAddress
                                                                   min:0.0
                                                                   max:1000.0
                                                                  unit:kAudioUnitParameterUnit_Generic];
    // Create a parameter object for the modulatingMultiplier.
    AUParameter *modulatingMultiplierAUParameter = [AUParameter parameter:@"modulatingMultiplier"
                                                                     name:@"Modulating Multiplier"
                                                                  address:modulatingMultiplierAddress
                                                                      min:0.0
                                                                      max:1000.0
                                                                     unit:kAudioUnitParameterUnit_Generic];
    // Create a parameter object for the modulationIndex.
    AUParameter *modulationIndexAUParameter = [AUParameter parameter:@"modulationIndex"
                                                                name:@"Modulation Index"
                                                             address:modulationIndexAddress
                                                                 min:0.0
                                                                 max:1000.0
                                                                unit:kAudioUnitParameterUnit_Generic];
    // Create a parameter object for the amplitude.
    AUParameter *amplitudeAUParameter = [AUParameter parameter:@"amplitude"
                                                          name:@"Amplitude"
                                                       address:amplitudeAddress
                                                           min:0.0
                                                           max:10.0
                                                          unit:kAudioUnitParameterUnit_Generic];

    // Initialize the parameter values.
    baseFrequencyAUParameter.value = 440;
    carrierMultiplierAUParameter.value = 1.0;
    modulatingMultiplierAUParameter.value = 1;
    modulationIndexAUParameter.value = 1;
    amplitudeAUParameter.value = 1;


    _kernel.setParameter(baseFrequencyAddress,        baseFrequencyAUParameter.value);
    _kernel.setParameter(carrierMultiplierAddress,    carrierMultiplierAUParameter.value);
    _kernel.setParameter(modulatingMultiplierAddress, modulatingMultiplierAUParameter.value);
    _kernel.setParameter(modulationIndexAddress,      modulationIndexAUParameter.value);
    _kernel.setParameter(amplitudeAddress,            amplitudeAUParameter.value);

    // Create the parameter tree.
    _parameterTree = [AUParameterTree createTreeWithChildren:@[
        baseFrequencyAUParameter,
        carrierMultiplierAUParameter,
        modulatingMultiplierAUParameter,
        modulationIndexAUParameter,
        amplitudeAUParameter
    ]];

    // A function to provide string representations of parameter values.
    _parameterTree.implementorStringFromValueCallback = ^(AUParameter *param, const AUValue *__nullable valuePtr) {
        AUValue value = valuePtr == nil ? param.value : *valuePtr;

        switch (param.address) {
            case baseFrequencyAddress:
            case carrierMultiplierAddress:
            case modulatingMultiplierAddress:
            case modulationIndexAddress:
            case amplitudeAddress:
                return [NSString stringWithFormat:@"%.3f", value];
            default:
                return @"?";
        }
    };

	parameterTreeBlock(FMOscillator)
}

AUAudioUnitGeneratorOverrides(FMOscillator)

@end


