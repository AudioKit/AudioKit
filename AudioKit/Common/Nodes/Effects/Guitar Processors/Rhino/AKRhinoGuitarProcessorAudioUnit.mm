//
//  AKRhinoGuitarProcessorAudioUnit.mm
//  AudioKit
//
//  Created by Mike Gazzaruso, revision history on Github.
//  Copyright © 2018 AudioKit. All rights reserved.
//

#import "AKRhinoGuitarProcessorAudioUnit.h"
#import "AKRhinoGuitarProcessorDSPKernel.hpp"

#import "BufferedAudioBus.hpp"

#import <AudioKit/AudioKit-Swift.h>

@implementation AKRhinoGuitarProcessorAudioUnit {
    // C++ members need to be ivars; they would be copied on access if they were properties.
    AKRhinoGuitarProcessorDSPKernel _kernel;
    BufferedInputBus _inputBus;
}
@synthesize parameterTree = _parameterTree;

- (void)setPreGain:(float)preGain {
    _kernel.setPreGain(preGain);
}
- (void)setPostGain:(float)postGain {
    _kernel.setPostGain(postGain);
}
- (void)setLowGain:(float)lowGain {
    _kernel.setLowGain(lowGain);
}
- (void)setMidGain:(float)midGain {
    _kernel.setMidGain(midGain);
}
- (void)setHighGain:(float)highGain {
    _kernel.setHighGain(highGain);
}
- (void)setDistortion:(float)distortion {
    _kernel.setDistortion(distortion);
}

standardKernelPassthroughs()

- (void)createParameters {

    standardSetup(RhinoGuitarProcessor)

    // Create a parameter object for the preGain.
    AUParameter *preGainAUParameter =
    [AUParameter parameterWithIdentifier:@"preGain"
                                    name:@"Pregain"
                                 address:AKRhinoGuitarProcessorDSPKernel::preGainAddress
                                     min:0.0
                                     max:10.0
                                    unit:kAudioUnitParameterUnit_Generic];
    // Create a parameter object for the postGain.
    AUParameter *postGainAUParameter =
    [AUParameter parameterWithIdentifier:@"postGain"
                                    name:@"Postgain"
                                 address:AKRhinoGuitarProcessorDSPKernel::postGainAddress
                                     min:0.0
                                     max:1.0
                                    unit:kAudioUnitParameterUnit_Generic];
    // Create a parameter object for the lowGain.
    AUParameter *lowGainAUParameter =
    [AUParameter parameterWithIdentifier:@"lowGain"
                                    name:@"Low frequencies."
                                 address:AKRhinoGuitarProcessorDSPKernel::lowGainAddress
                                     min:-1.0
                                     max:1.0
                                    unit:kAudioUnitParameterUnit_Generic];
    // Create a parameter object for the midGain.
    AUParameter *midGainAUParameter =
    [AUParameter parameterWithIdentifier:@"midGain"
                                    name:@"Low frequencies."
                                 address:AKRhinoGuitarProcessorDSPKernel::midGainAddress
                                     min:-1.0
                                     max:1.0
                                    unit:kAudioUnitParameterUnit_Generic];
    // Create a parameter object for the highGain.
    AUParameter *highGainAUParameter =
    [AUParameter parameterWithIdentifier:@"highGain"
                                    name:@"Low frequencies."
                                 address:AKRhinoGuitarProcessorDSPKernel::highGainAddress
                                     min:-1.0
                                     max:1.0
                                    unit:kAudioUnitParameterUnit_Generic];
    // Create a parameter object for the distortion.
    AUParameter *distortionAUParameter =
    [AUParameter parameterWithIdentifier:@"distortion"
                                    name:@"Distortion Amount"
                                 address:AKRhinoGuitarProcessorDSPKernel::distortionAddress
                                     min:1.0
                                     max:20.0
                                    unit:kAudioUnitParameterUnit_Generic];


    // Initialize the parameter values.
    preGainAUParameter.value = 5.0;
    postGainAUParameter.value = 0.7;
    lowGainAUParameter.value = 0.0;
    midGainAUParameter.value = 0.0;
    highGainAUParameter.value = 0.0;
    distortionAUParameter.value = 1.0;

    _kernel.setParameter(AKRhinoGuitarProcessorDSPKernel::preGainAddress,  preGainAUParameter.value);
    _kernel.setParameter(AKRhinoGuitarProcessorDSPKernel::postGainAddress, postGainAUParameter.value);
    _kernel.setParameter(AKRhinoGuitarProcessorDSPKernel::lowGainAddress,  lowGainAUParameter.value);
    _kernel.setParameter(AKRhinoGuitarProcessorDSPKernel::midGainAddress,  midGainAUParameter.value);
    _kernel.setParameter(AKRhinoGuitarProcessorDSPKernel::highGainAddress, highGainAUParameter.value);
    _kernel.setParameter(AKRhinoGuitarProcessorDSPKernel::distortionAddress, distortionAUParameter.value);

    // Create the parameter tree.
    _parameterTree = [AUParameterTree treeWithChildren:@[
                                                         preGainAUParameter,
                                                         postGainAUParameter,
                                                         lowGainAUParameter,
                                                         midGainAUParameter,
                                                         highGainAUParameter,
                                                         distortionAUParameter
                                                         ]];

    parameterTreeBlock(RhinoGuitarProcessor)
}

AUAudioUnitOverrides(RhinoGuitarProcessor);

@end


