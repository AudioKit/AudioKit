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

    // Initialize a default format for the busses.
    self.defaultFormat = [[AVAudioFormat alloc] initStandardFormatWithSampleRate:AKSettings.sampleRate
                                                                        channels:AKSettings.numberOfChannels];

    // Create a DSP kernel to handle the signal processing.
    _kernel.init(self.defaultFormat.channelCount, self.defaultFormat.sampleRate);

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

    self.rampTime = AKSettings.rampTime;

    _kernel.setParameter(shiftAddress,      shiftAUParameter.value);
    _kernel.setParameter(windowSizeAddress, windowSizeAUParameter.value);
    _kernel.setParameter(crossfadeAddress,  crossfadeAUParameter.value);

    // Create the parameter tree.
    _parameterTree = [AUParameterTree createTreeWithChildren:@[
        shiftAUParameter,
        windowSizeAUParameter,
        crossfadeAUParameter
    ]];

    // Make a local pointer to the kernel to avoid capturing self.
    __block AKPitchShifterDSPKernel *pitchshifterKernel = &_kernel;

    // implementorValueObserver is called when a parameter changes value.
    _parameterTree.implementorValueObserver = ^(AUParameter *param, AUValue value) {
        pitchshifterKernel->setParameter(param.address, value);
    };

    // implementorValueProvider is called when the value needs to be refreshed.
    _parameterTree.implementorValueProvider = ^(AUParameter *param) {
        return pitchshifterKernel->getParameter(param.address);
    };

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

    _inputBus.init(self.defaultFormat, 8);
    self.inputBusArray = [[AUAudioUnitBusArray alloc] initWithAudioUnit:self
                                                                busType:AUAudioUnitBusTypeInput
                                                                 busses:@[_inputBus.bus]];
}

AUAudioUnitOverrides(PitchShifter);

@end


