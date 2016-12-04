//
//  AKPitchShifterAudioUnit.mm
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright (c) 2016 Aurelius Prochazka. All rights reserved.
//

#import "AKPitchShifterAudioUnit.h"
#import "AKPitchShifterDSPKernel.hpp"

#import <AVFoundation/AVFoundation.h>
#import "BufferedAudioBus.hpp"

#import <AudioKit/AudioKit-Swift.h>

@implementation AKPitchShifterAudioUnit {
    // C++ members need to be ivars; they would be copied on access if they were properties.
    AKPitchShifterDSPKernel _kernel;
    BufferedInputBus _inputBus;
}
@synthesize parameterTree = _parameterTree;

- (void)setShift:(float)shift {
    _kernel.setShift(shift);
}
- (void)setWindowSize:(float)windowSize {
    _kernel.setWindowSize(windowSize);
}
- (void)setCrossfade:(float)crossfade {
    _kernel.setCrossfade(crossfade);
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

    standardSetup(PitchShifter)

    // Create a parameter object for the shift.
    AUParameter *shiftAUParameter =
    [AUParameterTree createParameterWithIdentifier:@"shift"
                                              name:@"Pitch shift (in semitones)"
                                           address:shiftAddress
                                               min:-24.0
                                               max:24.0
                                              unit:kAudioUnitParameterUnit_RelativeSemiTones
                                          unitName:nil
                                             flags:0
                                      valueStrings:nil
                               dependentParameters:nil];
    // Create a parameter object for the windowSize.
    AUParameter *windowSizeAUParameter =
    [AUParameterTree createParameterWithIdentifier:@"windowSize"
                                              name:@"Window size (in samples)"
                                           address:windowSizeAddress
                                               min:0.0
                                               max:10000.0
                                              unit:kAudioUnitParameterUnit_Hertz
                                          unitName:nil
                                             flags:0
                                      valueStrings:nil
                               dependentParameters:nil];
    // Create a parameter object for the crossfade.
    AUParameter *crossfadeAUParameter =
    [AUParameterTree createParameterWithIdentifier:@"crossfade"
                                              name:@"Crossfade (in samples)"
                                           address:crossfadeAddress
                                               min:0.0
                                               max:10000.0
                                              unit:kAudioUnitParameterUnit_Hertz
                                          unitName:nil
                                             flags:0
                                      valueStrings:nil
                               dependentParameters:nil];


    // Initialize the parameter values.
    shiftAUParameter.value = 0;
    windowSizeAUParameter.value = 1024;
    crossfadeAUParameter.value = 512;

    _kernel.setParameter(shiftAddress,      shiftAUParameter.value);
    _kernel.setParameter(windowSizeAddress, windowSizeAUParameter.value);
    _kernel.setParameter(crossfadeAddress,  crossfadeAUParameter.value);

    // Create the parameter tree.
    _parameterTree = [AUParameterTree createTreeWithChildren:@[
        shiftAUParameter,
        windowSizeAUParameter,
        crossfadeAUParameter
    ]];

    // A function to provide string representations of parameter values.
    _parameterTree.implementorStringFromValueCallback = ^(AUParameter *param, const AUValue *__nullable valuePtr) {
        AUValue value = valuePtr == nil ? param.value : *valuePtr;

        switch (param.address) {
            case shiftAddress:
                return [NSString stringWithFormat:@"%.3f", value];

            case windowSizeAddress:
                return [NSString stringWithFormat:@"%.3f", value];

            case crossfadeAddress:
                return [NSString stringWithFormat:@"%.3f", value];

            default:
                return @"?";
        }
    };

	parameterTreeBlock(PitchShifter)
}

AUAudioUnitOverrides(PitchShifter);

@end


