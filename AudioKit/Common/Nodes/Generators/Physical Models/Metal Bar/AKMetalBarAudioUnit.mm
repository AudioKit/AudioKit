//
//  AKMetalBarAudioUnit.mm
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright (c) 2016 Aurelius Prochazka. All rights reserved.
//

#import "AKMetalBarAudioUnit.h"
#import "AKMetalBarDSPKernel.hpp"

#import "BufferedAudioBus.hpp"

#import <AudioKit/AudioKit-Swift.h>

@implementation AKMetalBarAudioUnit {
    // C++ members need to be ivars; they would be copied on access if they were properties.
    AKMetalBarDSPKernel _kernel;
    BufferedInputBus _inputBus;
}
@synthesize parameterTree = _parameterTree;

- (void)setLeftBoundaryCondition:(float)leftBoundaryCondition {
    _kernel.setLeftBoundaryCondition(leftBoundaryCondition);
}
- (void)setRightBoundaryCondition:(float)rightBoundaryCondition {
    _kernel.setRightBoundaryCondition(rightBoundaryCondition);
}
- (void)setDecayDuration:(float)decayDuration {
    _kernel.setDecayDuration(decayDuration);
}
- (void)setScanSpeed:(float)scanSpeed {
    _kernel.setScanSpeed(scanSpeed);
}
- (void)setPosition:(float)position {
    _kernel.setPosition(position);
}
- (void)setStrikeVelocity:(float)strikeVelocity {
    _kernel.setStrikeVelocity(strikeVelocity);
}
- (void)setStrikeWidth:(float)strikeWidth {
    _kernel.setStrikeWidth(strikeWidth);
}

- (void)trigger {
    _kernel.trigger();
}

standardKernelPassthroughs()

- (void)createParameters {

    standardSetup(MetalBar)

    // Create a parameter object for the leftBoundaryCondition.
    AUParameter *leftBoundaryConditionAUParameter = [AUParameter parameter:@"leftBoundaryCondition"
                                                                      name:@"Boundary condition at left end of bar. 1 = clamped, 2 = pivoting, 3 = free"
                                                                   address:leftBoundaryConditionAddress
                                                                       min:1
                                                                       max:3
                                                                      unit:kAudioUnitParameterUnit_Hertz];
    // Create a parameter object for the rightBoundaryCondition.
    AUParameter *rightBoundaryConditionAUParameter = [AUParameter parameter:@"rightBoundaryCondition"
                                                                       name:@"Boundary condition at right end of bar. 1 = clamped, 2 = pivoting, 3 = free"
                                                                    address:rightBoundaryConditionAddress
                                                                        min:1
                                                                        max:3
                                                                       unit:kAudioUnitParameterUnit_Hertz];
    // Create a parameter object for the decayDuration.
    AUParameter *decayDurationAUParameter = [AUParameter parameter:@"decayDuration"
                                                              name:@"30db decay time (in seconds)."
                                                           address:decayDurationAddress
                                                               min:0
                                                               max:10
                                                              unit:kAudioUnitParameterUnit_Hertz];
    // Create a parameter object for the scanSpeed.
    AUParameter *scanSpeedAUParameter =
    [AUParameter parameter:@"scanSpeed"
                                              name:@"Speed of scanning the output location."
                                           address:scanSpeedAddress
                                               min:0
                                               max:100
                                              unit:kAudioUnitParameterUnit_Hertz];
    // Create a parameter object for the position.
    AUParameter *positionAUParameter = [AUParameter parameter:@"position"
                                                         name:@"Position along bar that strike occurs."
                                                      address:positionAddress
                                                          min:0
                                                          max:1
                                                         unit:kAudioUnitParameterUnit_Generic];
    // Create a parameter object for the strikeVelocity.
    AUParameter *strikeVelocityAUParameter = [AUParameter parameter:@"strikeVelocity"
                                                               name:@"Normalized strike velocity"
                                                            address:strikeVelocityAddress
                                                                min:0
                                                                max:1000
                                                               unit:kAudioUnitParameterUnit_Generic];
    // Create a parameter object for the strikeWidth.
    AUParameter *strikeWidthAUParameter = [AUParameter parameter:@"strikeWidth"
                                                            name:@"Spatial width of strike."
                                                         address:strikeWidthAddress
                                                             min:0
                                                             max:1
                                                            unit:kAudioUnitParameterUnit_Generic];


    // Initialize the parameter values.
    leftBoundaryConditionAUParameter.value = 1;
    rightBoundaryConditionAUParameter.value = 1;
    decayDurationAUParameter.value = 3;
    scanSpeedAUParameter.value = 0.25;
    positionAUParameter.value = 0.2;
    strikeVelocityAUParameter.value = 500;
    strikeWidthAUParameter.value = 0.05;


    _kernel.setParameter(leftBoundaryConditionAddress,  leftBoundaryConditionAUParameter.value);
    _kernel.setParameter(rightBoundaryConditionAddress, rightBoundaryConditionAUParameter.value);
    _kernel.setParameter(decayDurationAddress,          decayDurationAUParameter.value);
    _kernel.setParameter(scanSpeedAddress,              scanSpeedAUParameter.value);
    _kernel.setParameter(positionAddress,               positionAUParameter.value);
    _kernel.setParameter(strikeVelocityAddress,         strikeVelocityAUParameter.value);
    _kernel.setParameter(strikeWidthAddress,            strikeWidthAUParameter.value);

    // Create the parameter tree.
    _parameterTree = [AUParameterTree createTreeWithChildren:@[
        leftBoundaryConditionAUParameter,
        rightBoundaryConditionAUParameter,
        decayDurationAUParameter,
        scanSpeedAUParameter,
        positionAUParameter,
        strikeVelocityAUParameter,
        strikeWidthAUParameter
    ]];
	parameterTreeBlock(MetalBar)
}

AUAudioUnitGeneratorOverrides(MetalBar)

@end


