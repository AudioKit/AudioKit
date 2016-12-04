//
//  AKChowningReverbAudioUnit.mm
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright (c) 2016 Aurelius Prochazka. All rights reserved.
//

#import "AKChowningReverbAudioUnit.h"
#import "AKChowningReverbDSPKernel.hpp"

#import <AVFoundation/AVFoundation.h>
#import "BufferedAudioBus.hpp"

#import <AudioKit/AudioKit-Swift.h>

@implementation AKChowningReverbAudioUnit {
    // C++ members need to be ivars; they would be copied on access if they were properties.
    AKChowningReverbDSPKernel _kernel;
    BufferedInputBus _inputBus;
}
@synthesize parameterTree = _parameterTree;

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

    standardSetup(ChowningReverb)

    // Create the parameter tree.
    _parameterTree = [AUParameterTree createTreeWithChildren:@[]];
	parameterTreeBlock(ChowningReverb)
}

AUAudioUnitOverrides(ChowningReverb);

@end


