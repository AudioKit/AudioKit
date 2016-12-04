//
//  AKClipperAudioUnit.mm
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright (c) 2016 Aurelius Prochazka. All rights reserved.
//

#import "AKClipperAudioUnit.h"
#import "AKClipperDSPKernel.hpp"

#import <AVFoundation/AVFoundation.h>
#import "BufferedAudioBus.hpp"

#import <AudioKit/AudioKit-Swift.h>

@implementation AKClipperAudioUnit {
    // C++ members need to be ivars; they would be copied on access if they were properties.
    AKClipperDSPKernel _kernel;
    BufferedInputBus _inputBus;
}
@synthesize parameterTree = _parameterTree;

- (void)setLimit:(float)limit {
    _kernel.setLimit(limit);
}

standardKernelPassthroughs()

- (void)createParameters {

    standardSetup(Clipper)

    // Create a parameter object for the limit.
    AUParameter *limitAUParameter =
    [AUParameterTree createParameterWithIdentifier:@"limit"
                                              name:@"Threshold"
                                           address:limitAddress
                                               min:0.0
                                               max:1.0
                                              unit:kAudioUnitParameterUnit_Generic
                                          unitName:nil
                                             flags:0
                                      valueStrings:nil
                               dependentParameters:nil];


    // Initialize the parameter values.
    limitAUParameter.value = 1.0;

    _kernel.setParameter(limitAddress, limitAUParameter.value);

    // Create the parameter tree.
    _parameterTree = [AUParameterTree createTreeWithChildren:@[
        limitAUParameter
    ]];

    // A function to provide string representations of parameter values.
    _parameterTree.implementorStringFromValueCallback = ^(AUParameter *param, const AUValue *__nullable valuePtr) {
        AUValue value = valuePtr == nil ? param.value : *valuePtr;

        switch (param.address) {
            case limitAddress:
                return [NSString stringWithFormat:@"%.3f", value];

            default:
                return @"?";
        }
    };

	parameterTreeBlock(Clipper)
}

AUAudioUnitOverrides(Clipper);

@end


