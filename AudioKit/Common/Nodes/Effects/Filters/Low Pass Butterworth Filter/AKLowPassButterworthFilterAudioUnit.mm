//
//  AKLowPassButterworthFilterAudioUnit.mm
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright (c) 2016 Aurelius Prochazka. All rights reserved.
//

#import "AKLowPassButterworthFilterAudioUnit.h"
#import "AKLowPassButterworthFilterDSPKernel.hpp"

#import <AVFoundation/AVFoundation.h>
#import "BufferedAudioBus.hpp"

#import <AudioKit/AudioKit-Swift.h>

@implementation AKLowPassButterworthFilterAudioUnit {
    // C++ members need to be ivars; they would be copied on access if they were properties.
    AKLowPassButterworthFilterDSPKernel _kernel;
    BufferedInputBus _inputBus;
}
@synthesize parameterTree = _parameterTree;

- (void)setCutoffFrequency:(float)cutoffFrequency {
    _kernel.setCutoffFrequency(cutoffFrequency);
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

    // Create a parameter object for the cutoffFrequency.
    AUParameter *cutoffFrequencyAUParameter =
    [AUParameterTree createParameterWithIdentifier:@"cutoffFrequency"
                                              name:@"Cutoff Frequency (Hz)"
                                           address:cutoffFrequencyAddress
                                               min:12.0
                                               max:20000.0
                                              unit:kAudioUnitParameterUnit_Hertz
                                          unitName:nil
                                             flags:0
                                      valueStrings:nil
                               dependentParameters:nil];


    // Initialize the parameter values.
    cutoffFrequencyAUParameter.value = 1000.0;

    self.rampTime = AKSettings.rampTime;

    _kernel.setParameter(cutoffFrequencyAddress, cutoffFrequencyAUParameter.value);

    // Create the parameter tree.
    _parameterTree = [AUParameterTree createTreeWithChildren:@[
        cutoffFrequencyAUParameter
    ]];

    // Make a local pointer to the kernel to avoid capturing self.
    __block AKLowPassButterworthFilterDSPKernel *filterKernel = &_kernel;

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
            case cutoffFrequencyAddress:
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

AUAudioUnitOverrides(LowPassButterworthFilter);

@end


