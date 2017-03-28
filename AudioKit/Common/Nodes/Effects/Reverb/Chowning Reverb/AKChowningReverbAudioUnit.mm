//
//  AKChowningReverbAudioUnit.mm
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright © 2017 Aurelius Prochazka. All rights reserved.
//

#import "AKChowningReverbAudioUnit.h"
#import "AKChowningReverbDSPKernel.hpp"

#import "BufferedAudioBus.hpp"

#import <AudioKit/AudioKit-Swift.h>

@implementation AKChowningReverbAudioUnit {
    // C++ members need to be ivars; they would be copied on access if they were properties.
    AKChowningReverbDSPKernel _kernel;
    BufferedInputBus _inputBus;
}
@synthesize parameterTree = _parameterTree;

standardKernelPassthroughs()

- (void)createParameters {

    standardSetup(ChowningReverb)

    // Create the parameter tree.
    _parameterTree = [AUParameterTree createTreeWithChildren:@[]];
	parameterTreeBlock(ChowningReverb)
}

AUAudioUnitOverrides(ChowningReverb);

@end


