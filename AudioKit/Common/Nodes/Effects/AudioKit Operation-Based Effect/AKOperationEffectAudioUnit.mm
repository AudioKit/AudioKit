//
//  AKOperationEffectAudioUnit.mm
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright (c) 2015 Aurelius Prochazka. All rights reserved.
//

#import "AKOperationEffectAudioUnit.h"
#import "AKOperationEffectDSPKernel.hpp"

#import <AVFoundation/AVFoundation.h>
#import "BufferedAudioBus.hpp"

#import <AudioKit/AudioKit-Swift.h>

@implementation AKOperationEffectAudioUnit {
    // C++ members need to be ivars; they would be copied on access if they were properties.
    AKOperationEffectDSPKernel _kernel;
    BufferedInputBus _inputBus;
}
@synthesize parameterTree = _parameterTree;

- (void)setSporth:(NSString *)sporth {
    _kernel.setSporth((char *)[sporth UTF8String]);
}

- (NSArray *)parameters {
    NSMutableArray *temp = [NSMutableArray arrayWithCapacity:14];
    for (int i = 0; i < 14; i++) {
        [temp setObject:[NSNumber numberWithFloat:_kernel.parameters[i]] atIndexedSubscript:i];
    }
    return [NSArray arrayWithArray:temp];
}

- (void)setParameters:(NSArray *)parameters {
    float params[14] = {0,0,0,0,0,0,0,0,0,0,0,0,0,0};
    for (int i = 0; i < parameters.count; i++) {
        params[i] =[parameters[i] floatValue];
    }
    _kernel.setParameters(params);
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

- (void)createParameters {

    self.defaultFormat = [[AVAudioFormat alloc] initStandardFormatWithSampleRate:AKSettings.sampleRate
                                                                        channels:AKSettings.numberOfChannels];
    
    // Create a DSP kernel to handle the signal processing.
    _kernel.init(self.defaultFormat.channelCount, self.defaultFormat.sampleRate);

    // Create the parameter tree.
    _parameterTree = [AUParameterTree createTreeWithChildren:@[
    ]];

    // Make a local pointer to the kernel to avoid capturing self.
    __block AKOperationEffectDSPKernel *effectKernel = &_kernel;

    // implementorValueObserver is called when a parameter changes value.
    _parameterTree.implementorValueObserver = ^(AUParameter *param, AUValue value) {
        effectKernel->setParameter(param.address, value);
    };

    // implementorValueProvider is called when the value needs to be refreshed.
    _parameterTree.implementorValueProvider = ^(AUParameter *param) {
        return effectKernel->getParameter(param.address);
    };

    _inputBus.init(self.defaultFormat, 8);
    self.inputBusArray = [[AUAudioUnitBusArray alloc] initWithAudioUnit:self
                                                                busType:AUAudioUnitBusTypeInput
                                                                 busses:@[_inputBus.bus]];
}

AUAudioUnitOverrides(OperationEffect)
@end


