//
//  AKDynaRageCompressorAudioUnit.mm
//  AudioKit
//
//  Created by Mike Gazzaruso, revision history on Github.
//  Copyright © 2018 AudioKit. All rights reserved.
//

#import "AKDynaRageCompressorAudioUnit.h"
#import "AKDynaRageCompressorDSPKernel.hpp"

#import "BufferedAudioBus.hpp"

#import <AudioKit/AudioKit-Swift.h>

@implementation AKDynaRageCompressorAudioUnit {
    // C++ members need to be ivars; they would be copied on access if they were properties.
    AKDynaRageCompressorDSPKernel _kernel;
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
- (void)setRage:(float)rage {
    _kernel.setRage(rage);
}
- (void)setRageIsOn:(BOOL)rageIsOn {
    _kernel.setRageIsOn(rageIsOn);
}

standardKernelPassthroughs()

- (void)createParameters {

    standardSetup(DynaRageCompressor)

    // Create a parameter object for the ratio.
    AUParameter *ratioAUParameter =
    [AUParameter parameter:@"ratio"
                      name:@"Ratio to compress with, a value > 1 will compress"
                   address:AKDynaRageCompressorDSPKernel::ratioAddress
                       min:1.0
                       max:20.0
                      unit:kAudioUnitParameterUnit_Hertz];
    // Create a parameter object for the threshold.
    AUParameter *thresholdAUParameter =
    [AUParameter parameter:@"threshold"
                      name:@"Threshold (in dB) 0 = max"
                   address:AKDynaRageCompressorDSPKernel::thresholdAddress
                       min:-100.0
                       max:0.0
                      unit:kAudioUnitParameterUnit_Generic];
    // Create a parameter object for the attackTime.
    AUParameter *attackTimeAUParameter =
    [AUParameter parameter:@"attackTime"
                      name:@"Attack time"
                   address:AKDynaRageCompressorDSPKernel::attackTimeAddress
                       min:0.1
                       max:500.0
                      unit:kAudioUnitParameterUnit_Seconds];
    // Create a parameter object for the releaseTime.
    AUParameter *releaseTimeAUParameter =
    [AUParameter parameter:@"releaseTime"
                      name:@"Release time"
                   address:AKDynaRageCompressorDSPKernel::releaseTimeAddress
                       min:0.1
                       max:500.0
                      unit:kAudioUnitParameterUnit_Seconds];

    // Create a parameter object for the rage.
    AUParameter *rageAUParameter =
    [AUParameter parameter:@"rage"
                      name:@"Rage Amount"
                   address:AKDynaRageCompressorDSPKernel::rageAddress
                       min:0.1
                       max:20.0
                      unit:kAudioUnitParameterUnit_Generic];


    // Initialize the parameter values.
    ratioAUParameter.value = 1.0;
    thresholdAUParameter.value = 0.0;
    attackTimeAUParameter.value = 0.1;
    releaseTimeAUParameter.value = 0.1;
    rageAUParameter.value = 0.1;

    _kernel.setParameter(AKDynaRageCompressorDSPKernel::ratioAddress,       ratioAUParameter.value);
    _kernel.setParameter(AKDynaRageCompressorDSPKernel::thresholdAddress,   thresholdAUParameter.value);
    _kernel.setParameter(AKDynaRageCompressorDSPKernel::attackTimeAddress,  attackTimeAUParameter.value);
    _kernel.setParameter(AKDynaRageCompressorDSPKernel::releaseTimeAddress, releaseTimeAUParameter.value);
    _kernel.setParameter(AKDynaRageCompressorDSPKernel::rageAddress,  rageAUParameter.value);

    // Create the parameter tree.
    _parameterTree = [AUParameterTree tree:@[
                                             ratioAUParameter,
                                             thresholdAUParameter,
                                             attackTimeAUParameter,
                                             releaseTimeAUParameter,
                                             rageAUParameter
                                             ]];

    parameterTreeBlock(DynaRageCompressor)
}

AUAudioUnitOverrides(DynaRageCompressor);

@end


