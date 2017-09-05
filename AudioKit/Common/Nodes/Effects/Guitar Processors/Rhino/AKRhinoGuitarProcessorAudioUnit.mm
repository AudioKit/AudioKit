//
//  AKRhinoGuitarProcessorAudioUnit.mm
//  AudioKit
//
//  Created by Mike Gazzaruso, revision history on Github.
//  Copyright © 2017 Mike Gazzaruso, Devoloop Srls. All rights reserved.
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
- (void)setDistType:(float)distType {
    _kernel.setDistType(distType);
}
- (void)setDistAmount:(float)distAmount {
    _kernel.setDistAmount(distAmount);
}

standardKernelPassthroughs()

- (void)createParameters {
    
    standardSetup(RhinoGuitarProcessor)
    
    // Create a parameter object for the preGain.
    AUParameter *preGainAUParameter =
    [AUParameter parameter:@"preGain"
                      name:@"Pregain"
                   address:preGainAddress
                       min:0.0
                       max:10.0
                      unit:kAudioUnitParameterUnit_Generic];
    // Create a parameter object for the postGain.
    AUParameter *postGainAUParameter =
    [AUParameter parameter:@"postGain"
                      name:@"Postgain"
                   address:postGainAddress
                       min:0.0
                       max:1.0
                      unit:kAudioUnitParameterUnit_Generic];
    // Create a parameter object for the lowGain.
    AUParameter *lowGainAUParameter =
    [AUParameter parameter:@"lowGain"
                      name:@"Low frequencies."
                   address:lowGainAddress
                       min:-1.0
                       max:1.0
                      unit:kAudioUnitParameterUnit_Generic];
    // Create a parameter object for the midGain.
    AUParameter *midGainAUParameter =
    [AUParameter parameter:@"midGain"
                      name:@"Low frequencies."
                   address:midGainAddress
                       min:-1.0
                       max:1.0
                      unit:kAudioUnitParameterUnit_Generic];
    // Create a parameter object for the highGain.
    AUParameter *highGainAUParameter =
    [AUParameter parameter:@"highGain"
                      name:@"Low frequencies."
                   address:highGainAddress
                       min:-1.0
                       max:1.0
                      unit:kAudioUnitParameterUnit_Generic];
    // Create a parameter object for the distType.
    AUParameter *distTypeAUParameter =
    [AUParameter parameter:@"distType"
                      name:@"Distortion Type"
                   address:distTypeAddress
                       min:1.0
                       max:3.0
                      unit:kAudioUnitParameterUnit_Generic];
    // Create a parameter object for the distAmount.
    AUParameter *distAmountAUParameter =
    [AUParameter parameter:@"distAmount"
                      name:@"Distortion Amount"
                   address:distAmountAddress
                       min:1.0
                       max:20.0
                      unit:kAudioUnitParameterUnit_Generic];
    
    
    // Initialize the parameter values.
    preGainAUParameter.value = 5.0;
    postGainAUParameter.value = 0.7;
    lowGainAUParameter.value = 0.0;
    midGainAUParameter.value = 0.0;
    highGainAUParameter.value = 0.0;
    distTypeAUParameter.value = 1.0;
    distAmountAUParameter.value = 1.0;
    
    _kernel.setParameter(preGainAddress,  preGainAUParameter.value);
    _kernel.setParameter(postGainAddress, postGainAUParameter.value);
    _kernel.setParameter(lowGainAddress,  lowGainAUParameter.value);
    _kernel.setParameter(midGainAddress,  midGainAUParameter.value);
    _kernel.setParameter(highGainAddress, highGainAUParameter.value);
    _kernel.setParameter(distTypeAddress, distTypeAUParameter.value);
    _kernel.setParameter(distAmountAddress, distAmountAUParameter.value);
    
    // Create the parameter tree.
    _parameterTree = [AUParameterTree tree:@[
                                             preGainAUParameter,
                                             postGainAUParameter,
                                             lowGainAUParameter,
                                             midGainAUParameter,
                                             highGainAUParameter,
                                             distTypeAUParameter,
                                             distAmountAUParameter
                                             ]];
    
    parameterTreeBlock(RhinoGuitarProcessor)
}

AUAudioUnitOverrides(RhinoGuitarProcessor);

@end


