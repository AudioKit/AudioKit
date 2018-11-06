//
//  AKDoNothingAudioUnit.mm
//  AudioKit
//
//  Created by Jeff Cooper, revision history on Github.
//  Copyright © 2018 AudioKit. All rights reserved.
//
#import <AudioKit/AudioKit-Swift.h>

#import "AKDoNothingAudioUnit.h"
#import "AKDoNothingDSPKernel.hpp"

#import "BufferedAudioBus.hpp"

@implementation AKDoNothingAudioUnit {
    // C++ members need to be ivars; they would be copied on access if they were properties.
    AKDoNothingDSPKernel _kernel;
    BufferedOutputBus _outputBusBuffer;
}
@synthesize parameterTree = _parameterTree;

- (void)destroy {
    _kernel.destroy();
}

standardKernelPassthroughs()

- (void)createParameters {

    standardGeneratorSetup(DoNothing)

    // Create the parameter tree.
    _parameterTree = [AUParameterTree tree:@[]];

    parameterTreeBlock(DoNothing)
}

AUAudioUnitGeneratorOverrides(DoNothing)

@end


