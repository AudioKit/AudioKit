//
//  AKPWMOscillatorAudioUnit.mm
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright (c) 2016 Aurelius Prochazka. All rights reserved.
//

#import "AKPWMOscillatorAudioUnit.h"
#import "AKPWMOscillatorDSPKernel.hpp"

#import <AVFoundation/AVFoundation.h>
#import "BufferedAudioBus.hpp"

#import <AudioKit/AudioKit-Swift.h>

@implementation AKPWMOscillatorAudioUnit {
    // C++ members need to be ivars; they would be copied on access if they were properties.
    AKPWMOscillatorDSPKernel _kernel;
    BufferedInputBus _inputBus;
}
@synthesize parameterTree = _parameterTree;

- (void)setFrequency:(float)frequency {
    _kernel.setFrequency(frequency);
}
- (void)setAmplitude:(float)amplitude {
    _kernel.setAmplitude(amplitude);
}
- (void)setPulseWidth:(float)pulseWidth {
    _kernel.setPulseWidth(pulseWidth);
}
- (void)setDetuningOffset:(float)detuningOffset {
    _kernel.setDetuningOffset(detuningOffset);
}
- (void)setDetuningMultiplier:(float)detuningMultiplier {
    _kernel.setDetuningMultiplier(detuningMultiplier);
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

    // Create a parameter object for the frequency.
    AUParameter *frequencyAUParameter =
    [AUParameterTree createParameterWithIdentifier:@"frequency"
                                              name:@"Frequency (Hz)"
                                           address:frequencyAddress
                                               min:0.0
                                               max:20000.0
                                              unit:kAudioUnitParameterUnit_Hertz
                                          unitName:nil
                                             flags:0
                                      valueStrings:nil
                               dependentParameters:nil];
    // Create a parameter object for the amplitude.
    AUParameter *amplitudeAUParameter =
    [AUParameterTree createParameterWithIdentifier:@"amplitude"
                                              name:@"Amplitude"
                                           address:amplitudeAddress
                                               min:0.0
                                               max:10.0
                                              unit:kAudioUnitParameterUnit_Hertz
                                          unitName:nil
                                             flags:0
                                      valueStrings:nil
                               dependentParameters:nil];
    // Create a parameter object for the pulseWidth.
    AUParameter *pulseWidthAUParameter =
    [AUParameterTree createParameterWithIdentifier:@"pulseWidth"
                                              name:@"Pulse Width"
                                           address:pulseWidthAddress
                                               min:0.0
                                               max:1.0
                                              unit:kAudioUnitParameterUnit_Generic
                                          unitName:nil
                                             flags:0
                                      valueStrings:nil
                               dependentParameters:nil];
    // Create a parameter object for the detuningOffset.
    AUParameter *detuningOffsetAUParameter =
    [AUParameterTree createParameterWithIdentifier:@"detuningOffset"
                                              name:@"Frequency offset (Hz)"
                                           address:detuningOffsetAddress
                                               min:-1000.0
                                               max:1000.0
                                              unit:kAudioUnitParameterUnit_Hertz
                                          unitName:nil
                                             flags:0
                                      valueStrings:nil
                               dependentParameters:nil];
    // Create a parameter object for the detuningMultiplier.
    AUParameter *detuningMultiplierAUParameter =
    [AUParameterTree createParameterWithIdentifier:@"detuningMultiplier"
                                              name:@"Frequency detuning multiplier"
                                           address:detuningMultiplierAddress
                                               min:0.5
                                               max:2.0
                                              unit:kAudioUnitParameterUnit_Generic
                                          unitName:nil
                                             flags:0
                                      valueStrings:nil
                               dependentParameters:nil];


    // Initialize the parameter values.
    frequencyAUParameter.value = 440;
    amplitudeAUParameter.value = 1.0;
    pulseWidthAUParameter.value = 0.5;
    detuningOffsetAUParameter.value = 0;
    detuningMultiplierAUParameter.value = 1;

    self.rampTime = AKSettings.rampTime;

    _kernel.setParameter(frequencyAddress,          frequencyAUParameter.value);
    _kernel.setParameter(amplitudeAddress,          amplitudeAUParameter.value);
    _kernel.setParameter(pulseWidthAddress,         pulseWidthAUParameter.value);
    _kernel.setParameter(detuningOffsetAddress,     detuningOffsetAUParameter.value);
    _kernel.setParameter(detuningMultiplierAddress, detuningMultiplierAUParameter.value);

    // Create the parameter tree.
    _parameterTree = [AUParameterTree createTreeWithChildren:@[
        frequencyAUParameter,
        amplitudeAUParameter,
        pulseWidthAUParameter,
        detuningOffsetAUParameter,
        detuningMultiplierAUParameter
    ]];

    // Make a local pointer to the kernel to avoid capturing self.
    __block AKPWMOscillatorDSPKernel *oscillatorKernel = &_kernel;

    // implementorValueObserver is called when a parameter changes value.
    _parameterTree.implementorValueObserver = ^(AUParameter *param, AUValue value) {
        oscillatorKernel->setParameter(param.address, value);
    };

    // implementorValueProvider is called when the value needs to be refreshed.
    _parameterTree.implementorValueProvider = ^(AUParameter *param) {
        return oscillatorKernel->getParameter(param.address);
    };

    // A function to provide string representations of parameter values.
    _parameterTree.implementorStringFromValueCallback = ^(AUParameter *param, const AUValue *__nullable valuePtr) {
        AUValue value = valuePtr == nil ? param.value : *valuePtr;

        switch (param.address) {
            case frequencyAddress:
                return [NSString stringWithFormat:@"%.3f", value];

            case amplitudeAddress:
                return [NSString stringWithFormat:@"%.3f", value];

            case pulseWidthAddress:
                return [NSString stringWithFormat:@"%.3f", value];

            case detuningOffsetAddress:
                return [NSString stringWithFormat:@"%.3f", value];

            case detuningMultiplierAddress:
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

AUAudioUnitGeneratorOverrides(PWMOscillator)

@end


