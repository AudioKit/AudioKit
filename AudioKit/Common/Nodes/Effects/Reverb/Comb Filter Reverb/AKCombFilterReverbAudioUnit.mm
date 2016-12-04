//
//  AKCombFilterReverbAudioUnit.mm
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright (c) 2016 Aurelius Prochazka. All rights reserved.
//

#import "AKCombFilterReverbAudioUnit.h"
#import "AKCombFilterReverbDSPKernel.hpp"

#import <AVFoundation/AVFoundation.h>
#import "BufferedAudioBus.hpp"

#import <AudioKit/AudioKit-Swift.h>

@implementation AKCombFilterReverbAudioUnit {
    // C++ members need to be ivars; they would be copied on access if they were properties.
    AKCombFilterReverbDSPKernel _kernel;
    BufferedInputBus _inputBus;
}
@synthesize parameterTree = _parameterTree;

- (void)setReverbDuration:(float)reverbDuration {
    _kernel.setReverbDuration(reverbDuration);
}

- (void)setLoopDuration:(float)duration {
    _kernel.setLoopDuration(duration);
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

    // Create a parameter object for the reverbDuration.
    AUParameter *reverbDurationAUParameter =
    [AUParameterTree createParameterWithIdentifier:@"reverbDuration"
                                              name:@"Reverb Duration (Seconds)"
                                           address:reverbDurationAddress
                                               min:0.0
                                               max:10.0
                                              unit:kAudioUnitParameterUnit_Seconds
                                          unitName:nil
                                             flags:0
                                      valueStrings:nil
                               dependentParameters:nil];


    // Initialize the parameter values.
    reverbDurationAUParameter.value = 1.0;

    self.rampTime = AKSettings.rampTime;

    _kernel.setParameter(reverbDurationAddress, reverbDurationAUParameter.value);

    // Create the parameter tree.
    _parameterTree = [AUParameterTree createTreeWithChildren:@[
        reverbDurationAUParameter
    ]];

    // Make a local pointer to the kernel to avoid capturing self.
    __block AKCombFilterReverbDSPKernel *filterKernel = &_kernel;

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
            case reverbDurationAddress:
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

AUAudioUnitOverrides(CombFilterReverb);

@end


