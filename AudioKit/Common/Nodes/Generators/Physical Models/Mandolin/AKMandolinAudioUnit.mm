//
//  AKMandolinAudioUnit.mm
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright © 2018 AudioKit. All rights reserved.
//

#import "AKMandolinAudioUnit.h"
#import "AKMandolinDSPKernel.hpp"

#import "BufferedAudioBus.hpp"

#import <AudioKit/AudioKit-Swift.h>

@implementation AKMandolinAudioUnit {
    // C++ members need to be ivars; they would be copied on access if they were properties.
    AKMandolinDSPKernel _kernel;
    BufferedOutputBus _outputBusBuffer;
}

@synthesize parameterTree = _parameterTree;

- (void)setDetune:(float)detune {
    _kernel.setDetune(detune);
}
- (void)setBodySize:(float)bodySize {
    _kernel.setBodySize(bodySize);
}

- (void)setFrequency:(float)frequency course:(int)course {
    _kernel.setFrequency(frequency, course);
}
- (void)pluckCourse:(int)course position:(float)position velocity:(int)velocity {
    _kernel.pluck(course, position, velocity);
}
- (void)muteCourse:(int)course {
    _kernel.mute(course);
}

- (BOOL)isSetUp {
    return _kernel.resetted;
}

- (void)createParameters {

    standardGeneratorSetup(Mandolin)

    // Create a parameter object for the detune.
    AUParameter *detuneAUParameter = [AUParameter parameter:@"detune"
                                                       name:@"Detune"
                                                    address:AKMandolinDSPKernel::detuneAddress
                                                        min:0.0001
                                                        max:100.0
                                                       unit:kAudioUnitParameterUnit_Generic];
    // Create a parameter object for the body size.
    AUParameter *bodySizeAUParameter = [AUParameter parameter:@"bodySize"
                                                         name:@"Body size"
                                                      address:AKMandolinDSPKernel::bodySizeAddress
                                                          min:0
                                                          max:10
                                                         unit:kAudioUnitParameterUnit_Generic];

    // Initialize the parameter values.
    detuneAUParameter.value = 1.0;
    bodySizeAUParameter.value = 1.0;


    _kernel.setParameter(AKMandolinDSPKernel::detuneAddress,        detuneAUParameter.value);
    _kernel.setParameter(AKMandolinDSPKernel::bodySizeAddress,      bodySizeAUParameter.value);

    // Create the parameter tree.
    _parameterTree = [AUParameterTree createTreeWithChildren:@[
                                                               detuneAUParameter,
                                                               bodySizeAUParameter
                                                               ]];

    parameterTreeBlock(Mandolin)
}

AUAudioUnitGeneratorOverrides(Mandolin)


@end


