//
//  AKStringResonatorAudioUnit.mm
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright (c) 2016 Aurelius Prochazka. All rights reserved.
//

#import "AKStringResonatorAudioUnit.h"
#import "AKStringResonatorDSPKernel.hpp"

#import <AVFoundation/AVFoundation.h>
#import "BufferedAudioBus.hpp"

#import <AudioKit/AudioKit-Swift.h>

@implementation AKStringResonatorAudioUnit {
    // C++ members need to be ivars; they would be copied on access if they were properties.
    AKStringResonatorDSPKernel _kernel;
    BufferedInputBus _inputBus;
}
@synthesize parameterTree = _parameterTree;

- (void)setFundamentalFrequency:(float)fundamentalFrequency {
    _kernel.setFundamentalFrequency(fundamentalFrequency);
}
- (void)setFeedback:(float)feedback {
    _kernel.setFeedback(feedback);
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

        // Create a parameter object for the fundamentalFrequency.
    AUParameter *fundamentalFrequencyAUParameter =
    [AUParameterTree createParameterWithIdentifier:@"fundamentalFrequency"
                                              name:@"Fundamental Frequency (Hz)"
                                           address:fundamentalFrequencyAddress
                                               min:12.0
                                               max:10000.0
                                              unit:kAudioUnitParameterUnit_Hertz
                                          unitName:nil
                                             flags:0
                                      valueStrings:nil
                               dependentParameters:nil];
    // Create a parameter object for the feedback.
    AUParameter *feedbackAUParameter =
    [AUParameterTree createParameterWithIdentifier:@"feedback"
                                              name:@"Feedback (%)"
                                           address:feedbackAddress
                                               min:0.0
                                               max:1.0
                                              unit:kAudioUnitParameterUnit_Generic
                                          unitName:nil
                                             flags:0
                                      valueStrings:nil
                               dependentParameters:nil];


    // Initialize the parameter values.
    fundamentalFrequencyAUParameter.value = 100;
    feedbackAUParameter.value = 0.95;

    self.rampTime = AKSettings.rampTime;

    _kernel.setParameter(fundamentalFrequencyAddress, fundamentalFrequencyAUParameter.value);
    _kernel.setParameter(feedbackAddress,             feedbackAUParameter.value);

    // Create the parameter tree.
    _parameterTree = [AUParameterTree createTreeWithChildren:@[
        fundamentalFrequencyAUParameter,
        feedbackAUParameter
    ]];

    // Make a local pointer to the kernel to avoid capturing self.
    __block AKStringResonatorDSPKernel *filterKernel = &_kernel;

    // implementorValueObserver is called when a parameter changes value.
    _parameterTree.implementorValueObserver = ^(AUParameter *param, AUValue value) {
        filterKernel->setParameter(param.address, value);
    };

    // implementorValueProvider is called when the value needs to be refreshed.
    _parameterTree.implementorValueProvider = ^(AUParameter *param) {
        return filterKernel->getParameter(param.address);
    };

    // A function to provide string representations of parameter values.
    _parameterTree.implementorStringFromValueCallback = ^(AUParameter *param, const AUValue *__nullable valuePtr) {
        AUValue value = valuePtr == nil ? param.value : *valuePtr;

        switch (param.address) {
            case fundamentalFrequencyAddress:
                return [NSString stringWithFormat:@"%.3f", value];

            case feedbackAddress:
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

AUAudioUnitOverrides(StringResonator);

@end


