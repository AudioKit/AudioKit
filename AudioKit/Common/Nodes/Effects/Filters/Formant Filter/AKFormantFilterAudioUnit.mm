//
//  AKFormantFilterAudioUnit.mm
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright (c) 2016 Aurelius Prochazka. All rights reserved.
//

#import "AKFormantFilterAudioUnit.h"
#import "AKFormantFilterDSPKernel.hpp"

#import <AVFoundation/AVFoundation.h>
#import "BufferedAudioBus.hpp"

#import <AudioKit/AudioKit-Swift.h>

@implementation AKFormantFilterAudioUnit {
    // C++ members need to be ivars; they would be copied on access if they were properties.
    AKFormantFilterDSPKernel _kernel;
    BufferedInputBus _inputBus;
}
@synthesize parameterTree = _parameterTree;

- (void)setX:(float)x {
    _kernel.setX(x);
}

- (void)setY:(float)y {
    _kernel.setY(y);
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
    
    standardSetup(FormantFilter)

    AUParameter *xAUParameter =
    [AUParameterTree createParameterWithIdentifier:@"x"
                                              name:@"x Position"
                                           address:xAddress
                                               min:0.0
                                               max:1.0
                                              unit:kAudioUnitParameterUnit_Generic
                                          unitName:nil
                                             flags:0
                                      valueStrings:nil
                               dependentParameters:nil];

    AUParameter *yAUParameter =
    [AUParameterTree createParameterWithIdentifier:@"y"
                                              name:@"y Position"
                                           address:yAddress
                                               min:0.0
                                               max:1.0
                                              unit:kAudioUnitParameterUnit_Generic
                                          unitName:nil
                                             flags:0
                                      valueStrings:nil
                               dependentParameters:nil];


    // Initialize the parameter values.
    xAUParameter.value = 0;
    yAUParameter.value = 0;

    _kernel.setParameter(xAddress, xAUParameter.value);
    _kernel.setParameter(yAddress,  yAUParameter.value);

    // Create the parameter tree.
    _parameterTree = [AUParameterTree createTreeWithChildren:@[
        xAUParameter,
        yAUParameter
    ]];

    // A function to provide string representations of parameter values.
    _parameterTree.implementorStringFromValueCallback = ^(AUParameter *param, const AUValue *__nullable valuePtr) {
        AUValue value = valuePtr == nil ? param.value : *valuePtr;

        switch (param.address) {
            case xAddress:
                return [NSString stringWithFormat:@"%.3f", value];

            case yAddress:
                return [NSString stringWithFormat:@"%.3f", value];

            default:
                return @"?";
        }
    };
    parameterTreeBlock(FormantFilter)
}

AUAudioUnitOverrides(FormantFilter)

@end


