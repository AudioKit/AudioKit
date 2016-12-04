//
//  AKFMOscillatorAudioUnit.mm
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright (c) 2016 Aurelius Prochazka. All rights reserved.
//

#import "AKFMOscillatorAudioUnit.h"
#import "AKFMOscillatorDSPKernel.hpp"

#import <AVFoundation/AVFoundation.h>
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

- (void)start {
    _kernel.start();
}

- (void)stop {
    _kernel.stop();
}

- (BOOL)isPlaying {
    return _kernel.started;
}

- (BOOL)isSetUp {
    return _kernel.resetted;
}

- (void)createParameters {

    standardSetup(FMOscillator)

    // Create a parameter object for the baseFrequency.
    AUParameter *baseFrequencyAUParameter =
    [AUParameterTree createParameterWithIdentifier:@"baseFrequency"
                                              name:@"Base Frequency (Hz)"
                                           address:baseFrequencyAddress
                                               min:0.0
                                               max:20000.0
                                              unit:kAudioUnitParameterUnit_Hertz
                                          unitName:nil
                                             flags:0
                                      valueStrings:nil
                               dependentParameters:nil];
    // Create a parameter object for the carrierMultiplier.
    AUParameter *carrierMultiplierAUParameter =
    [AUParameterTree createParameterWithIdentifier:@"carrierMultiplier"
                                              name:@"Carrier Multiplier"
                                           address:carrierMultiplierAddress
                                               min:0.0
                                               max:1000.0
                                              unit:kAudioUnitParameterUnit_Generic
                                          unitName:nil
                                             flags:0
                                      valueStrings:nil
                               dependentParameters:nil];
    // Create a parameter object for the modulatingMultiplier.
    AUParameter *modulatingMultiplierAUParameter =
    [AUParameterTree createParameterWithIdentifier:@"modulatingMultiplier"
                                              name:@"Modulating Multiplier"
                                           address:modulatingMultiplierAddress
                                               min:0.0
                                               max:1000.0
                                              unit:kAudioUnitParameterUnit_Generic
                                          unitName:nil
                                             flags:0
                                      valueStrings:nil
                               dependentParameters:nil];
    // Create a parameter object for the modulationIndex.
    AUParameter *modulationIndexAUParameter =
    [AUParameterTree createParameterWithIdentifier:@"modulationIndex"
                                              name:@"Modulation Index"
                                           address:modulationIndexAddress
                                               min:0.0
                                               max:1000.0
                                              unit:kAudioUnitParameterUnit_Generic
                                          unitName:nil
                                             flags:0
                                      valueStrings:nil
                               dependentParameters:nil];
    // Create a parameter object for the amplitude.
    AUParameter *amplitudeAUParameter =
    [AUParameterTree createParameterWithIdentifier:@"amplitude"
                                              name:@"Amplitude"
                                           address:amplitudeAddress
                                               min:0.0
                                               max:10.0
                                              unit:kAudioUnitParameterUnit_Generic
                                          unitName:nil
                                             flags:0
                                      valueStrings:nil
                               dependentParameters:nil];


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
                return [NSString stringWithFormat:@"%.3f", value];

            case carrierMultiplierAddress:
                return [NSString stringWithFormat:@"%.3f", value];

            case modulatingMultiplierAddress:
                return [NSString stringWithFormat:@"%.3f", value];

            case modulationIndexAddress:
                return [NSString stringWithFormat:@"%.3f", value];

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


