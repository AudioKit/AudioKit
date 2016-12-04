//
//  AKWhiteNoiseAudioUnit.mm
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright (c) 2016 Aurelius Prochazka. All rights reserved.
//

#import "AKWhiteNoiseAudioUnit.h"
#import "AKWhiteNoiseDSPKernel.hpp"

#import <AVFoundation/AVFoundation.h>
#import "BufferedAudioBus.hpp"

#import <AudioKit/AudioKit-Swift.h>

@implementation AKWhiteNoiseAudioUnit {
    // C++ members need to be ivars; they would be copied on access if they were properties.
    AKWhiteNoiseDSPKernel _kernel;
    BufferedInputBus _inputBus;
}
@synthesize parameterTree = _parameterTree;

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

    self.defaultFormat = [[AVAudioFormat alloc] initStandardFormatWithSampleRate:AKSettings.sampleRate
                                                                        channels:AKSettings.numberOfChannels];
    
    // Create a DSP kernel to handle the signal processing.
    _kernel.init(self.defaultFormat.channelCount, self.defaultFormat.sampleRate);

    // Create a parameter object for the amplitude.
    AUParameter *amplitudeAUParameter =
    [AUParameterTree createParameterWithIdentifier:@"amplitude"
                                              name:@"Amplitude"
                                           address:amplitudeAddress
                                               min:0.0
                                               max:1.0
                                              unit:kAudioUnitParameterUnit_Generic
                                          unitName:nil
                                             flags:0
                                      valueStrings:nil
                               dependentParameters:nil];


    // Initialize the parameter values.
    amplitudeAUParameter.value = 1;

    self.rampTime = AKSettings.rampTime;

    _kernel.setParameter(amplitudeAddress, amplitudeAUParameter.value);

    // Make a local pointer to the kernel to avoid capturing self.
    __block AKWhiteNoiseDSPKernel *noiseKernel = &_kernel;

    // implementorValueObserver is called when a parameter changes value.
    _parameterTree.implementorValueObserver = ^(AUParameter *param, AUValue value) {
        noiseKernel->setParameter(param.address, value);
    };

    // implementorValueProvider is called when the value needs to be refreshed.
    _parameterTree.implementorValueProvider = ^(AUParameter *param) {
        return noiseKernel->getParameter(param.address);
    };

    // A function to provide string representations of parameter values.
    _parameterTree.implementorStringFromValueCallback = ^(AUParameter *param, const AUValue *__nullable valuePtr) {
        AUValue value = valuePtr == nil ? param.value : *valuePtr;

        switch (param.address) {
            case amplitudeAddress:
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

AUAudioUnitGeneratorOverrides(WhiteNoise)

@end


