//
//  AKDripAudioUnit.mm
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright © 2017 Aurelius Prochazka. All rights reserved.
//

#import "AKDripAudioUnit.h"
#import "AKDripDSPKernel.hpp"

#import "BufferedAudioBus.hpp"

#import <AudioKit/AudioKit-Swift.h>

@implementation AKDripAudioUnit {
    // C++ members need to be ivars; they would be copied on access if they were properties.
    AKDripDSPKernel _kernel;
    BufferedOutputBus _outputBusBuffer;
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

    standardGeneratorSetup(Drip)

    // Create a parameter object for the intensity.
    AUParameter *intensityAUParameter = [AUParameter parameter:@"intensity"
                                                          name:@"The intensity of the dripping sounds."
                                                       address:intensityAddress
                                                           min:0
                                                           max:100
                                                          unit:kAudioUnitParameterUnit_Generic];
    // Create a parameter object for the dampingFactor.
    AUParameter *dampingFactorAUParameter = [AUParameter parameter:@"dampingFactor"
                                                              name:@"The damping factor. Maximum value is 2.0."
                                                           address:dampingFactorAddress
                                                               min:0.0
                                                               max:2.0
                                                              unit:kAudioUnitParameterUnit_Generic];

    // Create a parameter object for the energyReturn.
    AUParameter *energyReturnAUParameter = [AUParameter parameter:@"energyReturn"
                                                             name:@"The amount of energy to add back into the system."
                                                          address:energyReturnAddress
                                                              min:0
                                                              max:100
                                                             unit:kAudioUnitParameterUnit_Generic];

    // Create a parameter object for the mainResonantFrequency.
    AUParameter *mainResonantFrequencyAUParameter = [AUParameter parameter:@"mainResonantFrequency"
                                                                      name:@"Main resonant frequency."
                                                                   address:mainResonantFrequencyAddress
                                                                       min:0
                                                                       max:22000
                                                                      unit:kAudioUnitParameterUnit_Hertz];

    // Create a parameter object for the firstResonantFrequency.
    AUParameter *firstResonantFrequencyAUParameter = [AUParameter parameter:@"firstResonantFrequency"
                                                                       name:@"The first resonant frequency."
                                                                    address:firstResonantFrequencyAddress
                                                                        min:0
                                                                        max:22000
                                                                       unit:kAudioUnitParameterUnit_Hertz];

    // Create a parameter object for the secondResonantFrequency.
    AUParameter *secondResonantFrequencyAUParameter = [AUParameter parameter:@"secondResonantFrequency"
                                                                        name:@"The second resonant frequency."
                                                                     address:secondResonantFrequencyAddress
                                                                         min:0
                                                                         max:22000
                                                                        unit:kAudioUnitParameterUnit_Hertz];
    // Create a parameter object for the amplitude.
    AUParameter *amplitudeAUParameter = [AUParameter parameter:@"amplitude"
                                                          name:@"Amplitude."
                                                       address:amplitudeAddress
                                                           min:0
                                                           max:1
                                                          unit:kAudioUnitParameterUnit_Generic];

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
    _parameterTree = [AUParameterTree tree:@[
        intensityAUParameter,
        dampingFactorAUParameter,
        energyReturnAUParameter,
        mainResonantFrequencyAUParameter,
        firstResonantFrequencyAUParameter,
        secondResonantFrequencyAUParameter,
        amplitudeAUParameter
    ]];


	parameterTreeBlock(Drip)
}

AUAudioUnitGeneratorOverrides(Drip);

@end


