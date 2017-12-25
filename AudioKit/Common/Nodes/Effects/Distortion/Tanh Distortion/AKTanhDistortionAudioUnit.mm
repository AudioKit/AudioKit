//
//  AKTanhDistortionAudioUnit.mm
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright © 2017 Aurelius Prochazka. All rights reserved.
//

#import "AKTanhDistortionAudioUnit.h"
#import "AKTanhDistortionDSPKernel.hpp"

#import "BufferedAudioBus.hpp"

#import <AudioKit/AudioKit-Swift.h>

@implementation AKTanhDistortionAudioUnit {
    // C++ members need to be ivars; they would be copied on access if they were properties.
    AKTanhDistortionDSPKernel _kernel;

    BufferedInputBus _inputBus;
}
@synthesize parameterTree = _parameterTree;

- (void)setPregain:(float)pregain {
    _kernel.setPregain(pregain);
}
- (void)setPostgain:(float)postgain {
    _kernel.setPostgain(postgain);
}
- (void)setPositiveShapeParameter:(float)positiveShapeParameter {
    _kernel.setPositiveShapeParameter(positiveShapeParameter);
}
- (void)setNegativeShapeParameter:(float)negativeShapeParameter {
    _kernel.setNegativeShapeParameter(negativeShapeParameter);
}


standardKernelPassthroughs()

- (void)createParameters {

    standardSetup(TanhDistortion)

    // Create a parameter object for the pregain.
    AUParameter *pregainAUParameter = [AUParameter parameter:@"pregain"
                                                        name:@"Pregain"
                                                     address:pregainAddress
                                                         min:0.0
                                                         max:10.0
                                                        unit:kAudioUnitParameterUnit_Generic];
    // Create a parameter object for the postgain.
    AUParameter *postgainAUParameter = [AUParameter parameter:@"postgain"
                                                         name:@"Postgain"
                                                      address:postgainAddress
                                                          min:0.0
                                                          max:10.0
                                                         unit:kAudioUnitParameterUnit_Generic];
    // Create a parameter object for the positiveShapeParameter.
    AUParameter *positiveShapeParameterAUParameter = [AUParameter parameter:@"positiveShapeParameter"
                                                                      name:@"Positive Shape Parameter"
                                                                   address:positiveShapeParameterAddress
                                                                       min:-10.0
                                                                       max:10.0
                                                                      unit:kAudioUnitParameterUnit_Generic];
    // Create a parameter object for the negativeShapeParameter.
    AUParameter *negativeShapeParameterAUParameter = [AUParameter parameter:@"negativeShapeParameter"
                                                                       name:@"Negative Shape Parameter"
                                                                    address:negativeShapeParameterAddress
                                                                        min:-10.0
                                                                        max:10.0
                                                                       unit:kAudioUnitParameterUnit_Generic];

    // Initialize the parameter values.
    pregainAUParameter.value = 2.0;
    postgainAUParameter.value = 0.5;
    positiveShapeParameterAUParameter.value = 0.0;
    negativeShapeParameterAUParameter.value = 0.0;

    _kernel.setParameter(pregainAddress,                pregainAUParameter.value);
    _kernel.setParameter(postgainAddress,               postgainAUParameter.value);
    _kernel.setParameter(positiveShapeParameterAddress,  positiveShapeParameterAUParameter.value);
    _kernel.setParameter(negativeShapeParameterAddress, negativeShapeParameterAUParameter.value);

    // Create the parameter tree.
    _parameterTree = [AUParameterTree tree:@[
                                             pregainAUParameter,
                                             postgainAUParameter,
                                             positiveShapeParameterAUParameter,
                                             negativeShapeParameterAUParameter
                                             ]];

    parameterTreeBlock(TanhDistortion)
}

AUAudioUnitOverrides(TanhDistortion);

@end


