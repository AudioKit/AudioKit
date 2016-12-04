//
//  AKPannerAudioUnit.mm
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright (c) 2016 Aurelius Prochazka. All rights reserved.
//

#import "AKPannerAudioUnit.h"
#import "AKPannerDSPKernel.hpp"

#import <AVFoundation/AVFoundation.h>
#import "BufferedAudioBus.hpp"

#import <AudioKit/AudioKit-Swift.h>

@implementation AKPannerAudioUnit {
    // C++ members need to be ivars; they would be copied on access if they were properties.
    AKPannerDSPKernel _kernel;
    BufferedInputBus _inputBus;
}
@synthesize parameterTree = _parameterTree;

- (void)setPan:(float)pan {
    _kernel.setPan(pan);
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

    standardSetup(Panner)

    // Create a parameter object for the pan.
    AUParameter *panAUParameter =
    [AUParameterTree createParameterWithIdentifier:@"pan"
                                              name:@"Panning. A value of -1 is hard left, and a value of 1 is hard right, and 0 is center."
                                           address:panAddress
                                               min:-1
                                               max:1
                                              unit:kAudioUnitParameterUnit_Generic
                                          unitName:nil
                                             flags:0
                                      valueStrings:nil
                               dependentParameters:nil];


    // Initialize the parameter values.
    panAUParameter.value = 0;


    _kernel.setParameter(panAddress,   panAUParameter.value);

    // Create the parameter tree.
    _parameterTree = [AUParameterTree createTreeWithChildren:@[
        panAUParameter
    ]];

    // A function to provide string representations of parameter values.
    _parameterTree.implementorStringFromValueCallback = ^(AUParameter *param, const AUValue *__nullable valuePtr) {
        AUValue value = valuePtr == nil ? param.value : *valuePtr;

        switch (param.address) {
            case panAddress:
                return [NSString stringWithFormat:@"%.3f", value];

            default:
                return @"?";
        }
    };
    parameterTreeBlock(Panner)
}

AUAudioUnitOverrides(Panner)

@end


