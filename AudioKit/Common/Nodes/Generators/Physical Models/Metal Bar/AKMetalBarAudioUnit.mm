//
//  AKMetalBarAudioUnit.mm
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright (c) 2016 Aurelius Prochazka. All rights reserved.
//

#import "AKMetalBarAudioUnit.h"
#import "AKMetalBarDSPKernel.hpp"

#import <AVFoundation/AVFoundation.h>
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

    self.defaultFormat = [[AVAudioFormat alloc] initStandardFormatWithSampleRate:AKSettings.sampleRate
                                                                        channels:AKSettings.numberOfChannels];
    
    // Create a DSP kernel to handle the signal processing.
    _kernel.init(self.defaultFormat.channelCount, self.defaultFormat.sampleRate);

    // Create a parameter object for the leftBoundaryCondition.
    AUParameter *leftBoundaryConditionAUParameter =
    [AUParameterTree createParameterWithIdentifier:@"leftBoundaryCondition"
                                              name:@"Boundary condition at left end of bar. 1 = clamped, 2 = pivoting, 3 = free"
                                           address:leftBoundaryConditionAddress
                                               min:1
                                               max:3
                                              unit:kAudioUnitParameterUnit_Hertz
                                          unitName:nil
                                             flags:0
                                      valueStrings:nil
                               dependentParameters:nil];
    // Create a parameter object for the rightBoundaryCondition.
    AUParameter *rightBoundaryConditionAUParameter =
    [AUParameterTree createParameterWithIdentifier:@"rightBoundaryCondition"
                                              name:@"Boundary condition at right end of bar. 1 = clamped, 2 = pivoting, 3 = free"
                                           address:rightBoundaryConditionAddress
                                               min:1
                                               max:3
                                              unit:kAudioUnitParameterUnit_Hertz
                                          unitName:nil
                                             flags:0
                                      valueStrings:nil
                               dependentParameters:nil];
    // Create a parameter object for the decayDuration.
    AUParameter *decayDurationAUParameter =
    [AUParameterTree createParameterWithIdentifier:@"decayDuration"
                                              name:@"30db decay time (in seconds)."
                                           address:decayDurationAddress
                                               min:0
                                               max:10
                                              unit:kAudioUnitParameterUnit_Hertz
                                          unitName:nil
                                             flags:0
                                      valueStrings:nil
                               dependentParameters:nil];
    // Create a parameter object for the scanSpeed.
    AUParameter *scanSpeedAUParameter =
    [AUParameterTree createParameterWithIdentifier:@"scanSpeed"
                                              name:@"Speed of scanning the output location."
                                           address:scanSpeedAddress
                                               min:0
                                               max:100
                                              unit:kAudioUnitParameterUnit_Hertz
                                          unitName:nil
                                             flags:0
                                      valueStrings:nil
                               dependentParameters:nil];
    // Create a parameter object for the position.
    AUParameter *positionAUParameter =
    [AUParameterTree createParameterWithIdentifier:@"position"
                                              name:@"Position along bar that strike occurs."
                                           address:positionAddress
                                               min:0
                                               max:1
                                              unit:kAudioUnitParameterUnit_Generic
                                          unitName:nil
                                             flags:0
                                      valueStrings:nil
                               dependentParameters:nil];
    // Create a parameter object for the strikeVelocity.
    AUParameter *strikeVelocityAUParameter =
    [AUParameterTree createParameterWithIdentifier:@"strikeVelocity"
                                              name:@"Normalized strike velocity"
                                           address:strikeVelocityAddress
                                               min:0
                                               max:1000
                                              unit:kAudioUnitParameterUnit_Generic
                                          unitName:nil
                                             flags:0
                                      valueStrings:nil
                               dependentParameters:nil];
    // Create a parameter object for the strikeWidth.
    AUParameter *strikeWidthAUParameter =
    [AUParameterTree createParameterWithIdentifier:@"strikeWidth"
                                              name:@"Spatial width of strike."
                                           address:strikeWidthAddress
                                               min:0
                                               max:1
                                              unit:kAudioUnitParameterUnit_Generic
                                          unitName:nil
                                             flags:0
                                      valueStrings:nil
                               dependentParameters:nil];


    // Initialize the parameter values.
    leftBoundaryConditionAUParameter.value = 1;
    rightBoundaryConditionAUParameter.value = 1;
    decayDurationAUParameter.value = 3;
    scanSpeedAUParameter.value = 0.25;
    positionAUParameter.value = 0.2;
    strikeVelocityAUParameter.value = 500;
    strikeWidthAUParameter.value = 0.05;

    self.rampTime = AKSettings.rampTime;

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

    // Make a local pointer to the kernel to avoid capturing self.
    __block AKMetalBarDSPKernel *blockKernel = &_kernel;

    // implementorValueObserver is called when a parameter changes value.
    _parameterTree.implementorValueObserver = ^(AUParameter *param, AUValue value) {
        blockKernel->setParameter(param.address, value);
    };

    // implementorValueProvider is called when the value needs to be refreshed.
    _parameterTree.implementorValueProvider = ^(AUParameter *param) {
        return blockKernel->getParameter(param.address);
    };

    _inputBus.init(self.defaultFormat, 8);
    self.inputBusArray = [[AUAudioUnitBusArray alloc] initWithAudioUnit:self
                                                                busType:AUAudioUnitBusTypeInput
                                                                 busses:@[_inputBus.bus]];
}

AUAudioUnitGeneratorOverrides(MetalBar)

@end


