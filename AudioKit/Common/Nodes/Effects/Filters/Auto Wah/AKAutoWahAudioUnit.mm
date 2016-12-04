//
//  AKAutoWahAudioUnit.mm
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright (c) 2016 Aurelius Prochazka. All rights reserved.
//

#import "AKAutoWahAudioUnit.h"
#import "AKAutoWahDSPKernel.hpp"

#import <AVFoundation/AVFoundation.h>
#import "BufferedAudioBus.hpp"

#import <AudioKit/AudioKit-Swift.h>

@implementation AKAutoWahAudioUnit {
    // C++ members need to be ivars; they would be copied on access if they were properties.
    AKAutoWahDSPKernel _kernel;
    BufferedInputBus _inputBus;
}
@synthesize parameterTree = _parameterTree;

- (void)setWah:(float)wah {
    _kernel.setWah(wah);
}
- (void)setMix:(float)mix {
    _kernel.setMix(mix);
}
- (void)setAmplitude:(float)amplitude {
    _kernel.setAmplitude(amplitude);
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

    standardSetup(AutoWah)

    // Create a parameter object for the wah.
    AUParameter *wahAUParameter =
    [AUParameterTree createParameterWithIdentifier:@"wah"
                                              name:@"Wah Amount"
                                           address:wahAddress
                                               min:0.0
                                               max:1.0
                                              unit:kAudioUnitParameterUnit_Generic
                                          unitName:nil
                                             flags:0
                                      valueStrings:nil
                               dependentParameters:nil];
    // Create a parameter object for the mix.
    AUParameter *mixAUParameter =
    [AUParameterTree createParameterWithIdentifier:@"mix"
                                              name:@"Dry/Wet Mix"
                                           address:mixAddress
                                               min:0.0
                                               max:1.0
                                              unit:kAudioUnitParameterUnit_Percent
                                          unitName:nil
                                             flags:0
                                      valueStrings:nil
                               dependentParameters:nil];
    // Create a parameter object for the amplitude.
    AUParameter *amplitudeAUParameter =
    [AUParameterTree createParameterWithIdentifier:@"amplitude"
                                              name:@"Overall level"
                                           address:amplitudeAddress
                                               min:0.0
                                               max:1.0
                                              unit:kAudioUnitParameterUnit_Generic
                                          unitName:nil
                                             flags:0
                                      valueStrings:nil
                               dependentParameters:nil];

    // Initialize the parameter values.
    wahAUParameter.value = 0.0;
    mixAUParameter.value = 1.0;
    amplitudeAUParameter.value = 0.1;

    _kernel.setParameter(wahAddress,       wahAUParameter.value);
    _kernel.setParameter(mixAddress,       mixAUParameter.value);
    _kernel.setParameter(amplitudeAddress, amplitudeAUParameter.value);

    // Create the parameter tree.
    _parameterTree = [AUParameterTree createTreeWithChildren:@[
        wahAUParameter,
        mixAUParameter,
        amplitudeAUParameter
    ]];

    // A function to provide string representations of parameter values.
    _parameterTree.implementorStringFromValueCallback = ^(AUParameter *param, const AUValue *__nullable valuePtr) {
        AUValue value = valuePtr == nil ? param.value : *valuePtr;

        switch (param.address) {
            case wahAddress:
                return [NSString stringWithFormat:@"%.3f", value];

            case mixAddress:
                return [NSString stringWithFormat:@"%.3f", value];

            case amplitudeAddress:
                return [NSString stringWithFormat:@"%.3f", value];

            default:
                return @"?";
        }
    };
	parameterTreeBlock(AutoWah)
}

AUAudioUnitOverrides(AutoWah);

@end


