//
//  AKTesterAudioUnit.mm
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright (c) 2015 Aurelius Prochazka. All rights reserved.
//

#import "AKTesterAudioUnit.h"
#import "AKTesterDSPKernel.hpp"

#import <AVFoundation/AVFoundation.h>
#import "BufferedAudioBus.hpp"

#import <AudioKit/AudioKit-Swift.h>

@implementation AKTesterAudioUnit {
    // C++ members need to be ivars; they would be copied on access if they were properties.
    AKTesterDSPKernel _kernel;
    BufferedInputBus _inputBus;
}
@synthesize parameterTree = _parameterTree;

- (void)setSamples:(int)samples {
    _kernel.setSamples(samples);
}

- (NSString *)getMD5 {
    return _kernel.getMD5();
}

- (int)getSamples {
    return _kernel.getSamples();
}

- (void)start {
    _kernel.start();
}

- (void)stop {
    _kernel.stop();
}

- (void)createParameters {

    self.defaultFormat = [[AVAudioFormat alloc] initStandardFormatWithSampleRate:AKSettings.sampleRate
                                                                        channels:AKSettings.numberOfChannels];
    
    // Create a DSP kernel to handle the signal processing.
    _kernel.init(self.defaultFormat.channelCount, self.defaultFormat.sampleRate);

    // Create the parameter tree.
    _parameterTree = [AUParameterTree createTreeWithChildren:@[
    ]];

    // Make a local pointer to the kernel to avoid capturing self.
    __block AKTesterDSPKernel *testerKernel = &_kernel;

    // implementorValueObserver is called when a parameter changes value.
    _parameterTree.implementorValueObserver = ^(AUParameter *param, AUValue value) {
        testerKernel->setParameter(param.address, value);
    };

    // implementorValueProvider is called when the value needs to be refreshed.
    _parameterTree.implementorValueProvider = ^(AUParameter *param) {
        return testerKernel->getParameter(param.address);
    };

    _inputBus.init(self.defaultFormat, 8);
    self.inputBusArray = [[AUAudioUnitBusArray alloc] initWithAudioUnit:self
                                                                busType:AUAudioUnitBusTypeInput
                                                                 busses:@[_inputBus.bus]];
}

AUAudioUnitOverrides(Tester)

@end


