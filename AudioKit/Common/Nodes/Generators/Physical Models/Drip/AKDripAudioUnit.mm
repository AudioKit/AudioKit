//
//  AKDripAudioUnit.mm
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright (c) 2016 Aurelius Prochazka. All rights reserved.
//

#import "AKDripAudioUnit.h"
#import "AKDripDSPKernel.hpp"

#import <AVFoundation/AVFoundation.h>
#import "BufferedAudioBus.hpp"

#import <AudioKit/AudioKit-Swift.h>

@implementation AKDripAudioUnit {
    // C++ members need to be ivars; they would be copied on access if they were properties.
    AKDripDSPKernel _kernel;
    BufferedInputBus _inputBus;
}
@synthesize parameterTree = _parameterTree;

- (void)setIntensity:(float)intensity {
    _kernel.setIntensity(intensity);
}
- (void)setDampingFactor:(float)dampingFactor {
    _kernel.setDampingFactor(dampingFactor);
}
- (void)setEnergyReturn:(float)energyReturn {
    _kernel.setEnergyReturn(energyReturn);
}
- (void)setMainResonantFrequency:(float)mainResonantFrequency {
    _kernel.setMainResonantFrequency(mainResonantFrequency);
}
- (void)setFirstResonantFrequency:(float)firstResonantFrequency {
    _kernel.setFirstResonantFrequency(firstResonantFrequency);
}
- (void)setSecondResonantFrequency:(float)secondResonantFrequency {
    _kernel.setSecondResonantFrequency(secondResonantFrequency);
}
- (void)setAmplitude:(float)amplitude {
    _kernel.setAmplitude(amplitude);
}

- (void)trigger {
    _kernel.trigger();
}

standardKernelPassthroughs()

- (void)createParameters {

    standardSetup(Drip)

    // Create a parameter object for the intensity.
    AUParameter *intensityAUParameter =
    [AUParameterTree createParameterWithIdentifier:@"intensity"
                                              name:@"The intensity of the dripping sounds."
                                           address:intensityAddress
                                               min:0
                                               max:100
                                              unit:kAudioUnitParameterUnit_Generic
                                          unitName:nil
                                             flags:0
                                      valueStrings:nil
                               dependentParameters:nil];
    // Create a parameter object for the dampingFactor.
    AUParameter *dampingFactorAUParameter =
    [AUParameterTree createParameterWithIdentifier:@"dampingFactor"
                                              name:@"The damping factor. Maximum value is 2.0."
                                           address:dampingFactorAddress
                                               min:0.0
                                               max:2.0
                                              unit:kAudioUnitParameterUnit_Generic
                                          unitName:nil
                                             flags:0
                                      valueStrings:nil
                               dependentParameters:nil];
    // Create a parameter object for the energyReturn.
    AUParameter *energyReturnAUParameter =
    [AUParameterTree createParameterWithIdentifier:@"energyReturn"
                                              name:@"The amount of energy to add back into the system."
                                           address:energyReturnAddress
                                               min:0
                                               max:100
                                              unit:kAudioUnitParameterUnit_Generic
                                          unitName:nil
                                             flags:0
                                      valueStrings:nil
                               dependentParameters:nil];
    // Create a parameter object for the mainResonantFrequency.
    AUParameter *mainResonantFrequencyAUParameter =
    [AUParameterTree createParameterWithIdentifier:@"mainResonantFrequency"
                                              name:@"Main resonant frequency."
                                           address:mainResonantFrequencyAddress
                                               min:0
                                               max:22000
                                              unit:kAudioUnitParameterUnit_Hertz
                                          unitName:nil
                                             flags:0
                                      valueStrings:nil
                               dependentParameters:nil];
    // Create a parameter object for the firstResonantFrequency.
    AUParameter *firstResonantFrequencyAUParameter =
    [AUParameterTree createParameterWithIdentifier:@"firstResonantFrequency"
                                              name:@"The first resonant frequency."
                                           address:firstResonantFrequencyAddress
                                               min:0
                                               max:22000
                                              unit:kAudioUnitParameterUnit_Hertz
                                          unitName:nil
                                             flags:0
                                      valueStrings:nil
                               dependentParameters:nil];
    // Create a parameter object for the secondResonantFrequency.
    AUParameter *secondResonantFrequencyAUParameter =
    [AUParameterTree createParameterWithIdentifier:@"secondResonantFrequency"
                                              name:@"The second resonant frequency."
                                           address:secondResonantFrequencyAddress
                                               min:0
                                               max:22000
                                              unit:kAudioUnitParameterUnit_Hertz
                                          unitName:nil
                                             flags:0
                                      valueStrings:nil
                               dependentParameters:nil];
    // Create a parameter object for the amplitude.
    AUParameter *amplitudeAUParameter =
    [AUParameterTree createParameterWithIdentifier:@"amplitude"
                                              name:@"Amplitude."
                                           address:amplitudeAddress
                                               min:0
                                               max:1
                                              unit:kAudioUnitParameterUnit_Generic
                                          unitName:nil
                                             flags:0
                                      valueStrings:nil
                               dependentParameters:nil];


    // Initialize the parameter values.
    intensityAUParameter.value = 10;
    dampingFactorAUParameter.value = 0.2;
    energyReturnAUParameter.value = 0;
    mainResonantFrequencyAUParameter.value = 450;
    firstResonantFrequencyAUParameter.value = 600;
    secondResonantFrequencyAUParameter.value = 750;
    amplitudeAUParameter.value = 0.3;


    _kernel.setParameter(intensityAddress,               intensityAUParameter.value);
    _kernel.setParameter(dampingFactorAddress,           dampingFactorAUParameter.value);
    _kernel.setParameter(energyReturnAddress,            energyReturnAUParameter.value);
    _kernel.setParameter(mainResonantFrequencyAddress,   mainResonantFrequencyAUParameter.value);
    _kernel.setParameter(firstResonantFrequencyAddress,  firstResonantFrequencyAUParameter.value);
    _kernel.setParameter(secondResonantFrequencyAddress, secondResonantFrequencyAUParameter.value);
    _kernel.setParameter(amplitudeAddress,               amplitudeAUParameter.value);

    // Create the parameter tree.
    _parameterTree = [AUParameterTree createTreeWithChildren:@[
        intensityAUParameter,
        dampingFactorAUParameter,
        energyReturnAUParameter,
        mainResonantFrequencyAUParameter,
        firstResonantFrequencyAUParameter,
        secondResonantFrequencyAUParameter,
        amplitudeAUParameter
    ]];

    // A function to provide string representations of parameter values.
    _parameterTree.implementorStringFromValueCallback = ^(AUParameter *param, const AUValue *__nullable valuePtr) {
        AUValue value = valuePtr == nil ? param.value : *valuePtr;

        switch (param.address) {
            case intensityAddress:
                return [NSString stringWithFormat:@"%.3f", value];

            case dampingFactorAddress:
                return [NSString stringWithFormat:@"%.3f", value];

            case energyReturnAddress:
                return [NSString stringWithFormat:@"%.3f", value];

            case mainResonantFrequencyAddress:
                return [NSString stringWithFormat:@"%.3f", value];

            case firstResonantFrequencyAddress:
                return [NSString stringWithFormat:@"%.3f", value];

            case secondResonantFrequencyAddress:
                return [NSString stringWithFormat:@"%.3f", value];

            case amplitudeAddress:
                return [NSString stringWithFormat:@"%.3f", value];

            default:
                return @"?";
        }
    };

	parameterTreeBlock(Drip)
}

AUAudioUnitGeneratorOverrides(Drip);

@end


