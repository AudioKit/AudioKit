//
//  AKDynamicRangeCompressorAudioUnit.mm
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright © 2017 Aurelius Prochazka. All rights reserved.
//

#import "AKDynamicRangeCompressorAudioUnit.h"
#import "AKDynamicRangeCompressorDSPKernel.hpp"

#import "BufferedAudioBus.hpp"

#import <AudioKit/AudioKit-Swift.h>

@implementation AKDynamicRangeCompressorAudioUnit {
    // C++ members need to be ivars; they would be copied on access if they were properties.
    AKDynamicRangeCompressorDSPKernel _kernel;
    BufferedInputBus _inputBus;
}
@synthesize parameterTree = _parameterTree;

- (void)setRatio:(float)ratio {
    _kernel.setRatio(ratio);
}
- (void)setThreshold:(float)threshold {
    _kernel.setThreshold(threshold);
}
- (void)setAttackTime:(float)attackTime {
    _kernel.setAttackTime(attackTime);
}
- (void)setReleaseTime:(float)releaseTime {
    _kernel.setReleaseTime(releaseTime);
}

standardKernelPassthroughs()

- (void)createParameters {

    standardSetup(DynamicRangeCompressor)

    // Create a parameter object for the ratio.
    AUParameter *ratioAUParameter =
    [AUParameter parameter:@"ratio"
                      name:@"Ratio to compress with, a value > 1 will compress"
                   address:ratioAddress
                       min:0.01
                       max:100.0
                      unit:kAudioUnitParameterUnit_Hertz];
    // Create a parameter object for the threshold.
    AUParameter *thresholdAUParameter =
    [AUParameter parameter:@"threshold"
                      name:@"Threshold (in dB) 0 = max"
                   address:thresholdAddress
                       min:-100.0
                       max:0.0
                      unit:kAudioUnitParameterUnit_Generic];
    // Create a parameter object for the attackTime.
    AUParameter *attackTimeAUParameter =
    [AUParameter parameter:@"attackTime"
                      name:@"Attack time"
                   address:attackTimeAddress
                       min:0.0
                       max:1.0
                      unit:kAudioUnitParameterUnit_Seconds];
    // Create a parameter object for the releaseTime.
    AUParameter *releaseTimeAUParameter =
    [AUParameter parameter:@"releaseTime"
                      name:@"Release time"
                   address:releaseTimeAddress
                       min:0.0
                       max:1.0
                      unit:kAudioUnitParameterUnit_Seconds];


    // Initialize the parameter values.
    ratioAUParameter.value = 1;
    thresholdAUParameter.value = 0.0;
    attackTimeAUParameter.value = 0.1;
    releaseTimeAUParameter.value = 0.1;

    _kernel.setParameter(ratioAddress,       ratioAUParameter.value);
    _kernel.setParameter(thresholdAddress,   thresholdAUParameter.value);
    _kernel.setParameter(attackTimeAddress,  attackTimeAUParameter.value);
    _kernel.setParameter(releaseTimeAddress, releaseTimeAUParameter.value);

    // Create the parameter tree.
    _parameterTree = [AUParameterTree tree:@[
        ratioAUParameter,
        thresholdAUParameter,
        attackTimeAUParameter,
        releaseTimeAUParameter
    ]];

    parameterTreeBlock(DynamicRangeCompressor)
}

AUAudioUnitOverrides(DynamicRangeCompressor);

@end


