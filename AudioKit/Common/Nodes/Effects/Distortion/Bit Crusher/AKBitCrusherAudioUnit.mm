//
//  AKBitCrusherAudioUnit.mm
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright © 2017 Aurelius Prochazka. All rights reserved.
//

#import "AKBitCrusherAudioUnit.h"
#import "AKBitCrusherDSPKernel.hpp"

#import "BufferedAudioBus.hpp"

#import <AudioKit/AudioKit-Swift.h>

@implementation AKBitCrusherAudioUnit {
    // C++ members need to be ivars; they would be copied on access if they were properties.
    AKBitCrusherDSPKernel _kernel;

    BufferedInputBus _inputBus;
}
@synthesize parameterTree = _parameterTree;

- (void)setBitDepth:(float)bitDepth {
    _kernel.setBitDepth(bitDepth);
}
- (void)setSampleRate:(float)sampleRate {
    _kernel.setSampleRate(sampleRate);
}


standardKernelPassthroughs()

- (void)createParameters {

    standardSetup(BitCrusher)

    // Create a parameter object for the bitDepth.
    AUParameter *bitDepthAUParameter = [AUParameter parameter:@"bitDepth"
                                                         name:@"Bit Depth"
                                                      address:bitDepthAddress
                                                          min:1
                                                          max:24
                                                         unit:kAudioUnitParameterUnit_Generic];

    // Create a parameter object for the sampleRate.
    AUParameter *sampleRateAUParameter = [AUParameter frequency:@"sampleRate"
                                                           name:@"Sample Rate (Hz)"
                                                        address:sampleRateAddress];

    // Initialize the parameter values.
    bitDepthAUParameter.value = 8;
    sampleRateAUParameter.value = 10000;

    _kernel.setParameter(bitDepthAddress,   bitDepthAUParameter.value);
    _kernel.setParameter(sampleRateAddress, sampleRateAUParameter.value);

    // Create the parameter tree.
    _parameterTree = [AUParameterTree tree:@[
        bitDepthAUParameter,
        sampleRateAUParameter
    ]];

	parameterTreeBlock(BitCrusher)
}

AUAudioUnitOverrides(BitCrusher);

@end


