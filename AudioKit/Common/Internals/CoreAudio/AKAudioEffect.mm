//
//  AKAudioEffect.m
//  AudioKit
//
//  Created by Andrew Voelkel on 8/28/17.
//  Copyright © 2017 AudioKit. All rights reserved.
//

#import "AKAudioEffect.h"
#import "AKAudioUnit.h"
#import "AKDSPKernel.hpp"
#import "BufferedAudioBus.hpp"


#import <AVFoundation/AVFoundation.h>

@implementation AKAudioEffect {
    AKDSPKernelWithParams* _kernel;
    BufferedInputBus _inputBus;
}

- (void)start { if (_kernel != NULL) _kernel->start(); }
- (void)stop { if (_kernel != NULL) _kernel->stop(); }
- (BOOL)isPlaying { return (_kernel == NULL) ? false : _kernel->started; }
- (BOOL)isSetUp { return (_kernel == NULL) ? false : _kernel->resetted; }

- (void)standardSetup {
    self.rampTime = AKSettings.rampTime;
    self.defaultFormat = [[AVAudioFormat alloc] initStandardFormatWithSampleRate:AKSettings.sampleRate
                                                                        channels:AKSettings.numberOfChannels];
    //_kernel->init(self.defaultFormat.channelCount, self.defaultFormat.sampleRate);
    _inputBus.init(self.defaultFormat, 8);
    self.inputBusArray = [[AUAudioUnitBusArray alloc] initWithAudioUnit:self
                                                                busType:AUAudioUnitBusTypeInput
                                                                 busses:@[_inputBus.bus]];
}



@end
