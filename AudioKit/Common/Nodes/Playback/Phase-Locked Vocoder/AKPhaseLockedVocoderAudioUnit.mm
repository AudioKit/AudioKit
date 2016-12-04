//
//  AKPhaseLockedVocoderAudioUnit.mm
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright (c) 2016 Aurelius Prochazka. All rights reserved.
//

#import "AKPhaseLockedVocoderAudioUnit.h"
#import "AKPhaseLockedVocoderDSPKernel.hpp"

#import <AVFoundation/AVFoundation.h>
#import "BufferedAudioBus.hpp"

#import <AudioKit/AudioKit-Swift.h>

@implementation AKPhaseLockedVocoderAudioUnit {
    // C++ members need to be ivars; they would be copied on access if they were properties.
    AKPhaseLockedVocoderDSPKernel _kernel;
    BufferedInputBus _inputBus;
}
@synthesize parameterTree = _parameterTree;

- (void)setPosition:(float)position {
    _kernel.setPosition(position);
}
- (void)setAmplitude:(float)amplitude {
    _kernel.setAmplitude(amplitude);
}
- (void)setPitchRatio:(float)pitchRatio {
    _kernel.setPitchRatio(pitchRatio);
}

- (void)setupAudioFileTable:(float *)data size:(UInt32)size {
    _kernel.setUpTable(data, size);
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

    // Create a parameter object for the position.
    AUParameter *positionAUParameter =
    [AUParameterTree createParameterWithIdentifier:@"position"
                                              name:@"Position in time. When non-changing it will do a spectral freeze of a the current point in time."
                                           address:positionAddress
                                               min:0
                                               max:1
                                              unit:kAudioUnitParameterUnit_Generic
                                          unitName:nil
                                             flags:0
                                      valueStrings:nil
                               dependentParameters:nil];
    // Create a parameter object for the amplitude.
    AUParameter *amplitudeAUParameter =
    [AUParameterTree createParameterWithIdentifier:@"amplitude"
                                              name:@"Amplitude."
                                           address:amplitudeAddress
                                               min:0
                                               max:1
                                              unit:kAudioUnitParameterUnit_Generic
                                          unitName:nil
                                             flags:0
                                      valueStrings:nil
                               dependentParameters:nil];
    // Create a parameter object for the pitchRatio.
    AUParameter *pitchRatioAUParameter =
    [AUParameterTree createParameterWithIdentifier:@"pitchRatio"
                                              name:@"Pitch ratio. A value of. 1  normal, 2 is double speed, 0.5 is halfspeed, etc."
                                           address:pitchRatioAddress
                                               min:0
                                               max:1000
                                              unit:kAudioUnitParameterUnit_Hertz
                                          unitName:nil
                                             flags:0
                                      valueStrings:nil
                               dependentParameters:nil];


    // Initialize the parameter values.
    positionAUParameter.value = 0;
    amplitudeAUParameter.value = 1;
    pitchRatioAUParameter.value = 1;

    self.rampTime = AKSettings.rampTime;

    _kernel.setParameter(positionAddress,   positionAUParameter.value);
    _kernel.setParameter(amplitudeAddress,  amplitudeAUParameter.value);
    _kernel.setParameter(pitchRatioAddress, pitchRatioAUParameter.value);

    // Create the parameter tree.
    _parameterTree = [AUParameterTree createTreeWithChildren:@[
        positionAUParameter,
        amplitudeAUParameter,
        pitchRatioAUParameter
    ]];

    // Make a local pointer to the kernel to avoid capturing self.
    __block AKPhaseLockedVocoderDSPKernel *vocoderKernel = &_kernel;

    // implementorValueObserver is called when a parameter changes value.
    _parameterTree.implementorValueObserver = ^(AUParameter *param, AUValue value) {
        vocoderKernel->setParameter(param.address, value);
    };

    // implementorValueProvider is called when the value needs to be refreshed.
    _parameterTree.implementorValueProvider = ^(AUParameter *param) {
        return vocoderKernel->getParameter(param.address);
    };

    // A function to provide string representations of parameter values.
    _parameterTree.implementorStringFromValueCallback = ^(AUParameter *param, const AUValue *__nullable valuePtr) {
        AUValue value = valuePtr == nil ? param.value : *valuePtr;

        switch (param.address) {
            case positionAddress:
                return [NSString stringWithFormat:@"%.3f", value];

            case amplitudeAddress:
                return [NSString stringWithFormat:@"%.3f", value];

            case pitchRatioAddress:
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

AUAudioUnitGeneratorOverrides(PhaseLockedVocoder)

@end


