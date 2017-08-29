//
//  AKAudioEffect.m
//  AudioKit For macOS
//
//  Created by Andrew Voelkel on 8/28/17.
//  Copyright © 2017 AudioKit. All rights reserved.
//

#import "AKAudioEffect.h"
#import "AKAudioUnit.h"
#import "AKDSPKernel.hpp"
#import <AVFoundation/AVFoundation.h>

@implementation AKAudioEffect {
    AKDSPKernelWithParams* _kernel;
}

- (void)start { _kernel.start(); } \
- (void)stop { _kernel.stop(); } \
- (BOOL)isPlaying { return _kernel.started; } \
- (BOOL)isSetUp { return _kernel.resetted; }


@end
