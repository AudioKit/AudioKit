//
//  AKDCBlockAudioUnit.mm
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright (c) 2016 Aurelius Prochazka. All rights reserved.
//

#import "AKDCBlockAudioUnit.h"
#import "AKDCBlockDSPKernel.hpp"

#import "BufferedAudioBus.hpp"

#import <AudioKit/AudioKit-Swift.h>

@implementation AKDCBlockAudioUnit {
    // C++ members need to be ivars; they would be copied on access if they were properties.
    AKDCBlockDSPKernel _kernel;
    BufferedInputBus _inputBus;
}
@synthesize parameterTree = _parameterTree;


standardKernelPassthroughs()

- (void)createParameters {
    standardSetup(DCBlock)
    // Create the parameter tree.
    _parameterTree = [AUParameterTree createTreeWithChildren:@[]];
	parameterTreeBlock(DCBlock)
}

AUAudioUnitOverrides(DCBlock);

@end


