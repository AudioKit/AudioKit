//
//  AKVocalTractAudioUnit.mm
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright © 2017 Aurelius Prochazka. All rights reserved.
//

#import "AKVocalTractAudioUnit.h"
#import "AKVocalTractDSPKernel.hpp"

#import "BufferedAudioBus.hpp"

#import <AudioKit/AudioKit-Swift.h>

@implementation AKVocalTractAudioUnit {
    // C++ members need to be ivars; they would be copied on access if they were properties.
    AKVocalTractDSPKernel _kernel;
    BufferedOutputBus _outputBusBuffer;
}
@synthesize parameterTree = _parameterTree;

- (void)setFrequency:(float)frequency {
    _kernel.setFrequency(frequency);
}
- (void)setTonguePosition:(float)tonguePosition {
    _kernel.setTonguePosition(tonguePosition);
}
- (void)setTongueDiameter:(float)tongueDiameter {
    _kernel.setTongueDiameter(tongueDiameter);
}
- (void)setTenseness:(float)tenseness {
    _kernel.setTenseness(tenseness);
}
- (void)setNasality:(float)nasality {
    _kernel.setNasality(nasality);
}

standardKernelPassthroughs()

- (void)createParameters {

    standardGeneratorSetup(VocalTract)

    // Create a parameter object for the frequency.
    AUParameter *frequencyAUParameter =
    [AUParameter parameter:@"frequency"
                      name:@"Glottal frequency."
                   address:frequencyAddress
                       min:0.0
                       max:22050.0
                      unit:kAudioUnitParameterUnit_Hertz];
    // Create a parameter object for the tonguePosition.
    AUParameter *tonguePositionAUParameter =
    [AUParameter parameter:@"tonguePosition"
                      name:@"Tongue position (0-1)"
                   address:tonguePositionAddress
                       min:0.0
                       max:1.0
                      unit:kAudioUnitParameterUnit_Generic];
    // Create a parameter object for the tongueDiameter.
    AUParameter *tongueDiameterAUParameter =
    [AUParameter parameter:@"tongueDiameter"
                      name:@"Tongue diameter (0-1)"
                   address:tongueDiameterAddress
                       min:0.0
                       max:1.0
                      unit:kAudioUnitParameterUnit_Generic];
    // Create a parameter object for the tenseness.
    AUParameter *tensenessAUParameter =
    [AUParameter parameter:@"tenseness"
                      name:@"Vocal tenseness. 0 = all breath. 1=fully saturated."
                   address:tensenessAddress
                       min:0.0
                       max:1.0
                      unit:kAudioUnitParameterUnit_Generic];
    // Create a parameter object for the nasality.
    AUParameter *nasalityAUParameter =
    [AUParameter parameter:@"nasality"
                      name:@"Sets the velum size. Larger values of this creates more nasally sounds."
                   address:nasalityAddress
                       min:0.0
                       max:1.0
                      unit:kAudioUnitParameterUnit_Generic];


    // Initialize the parameter values.
    frequencyAUParameter.value = 160.0;
    tonguePositionAUParameter.value = 0.5;
    tongueDiameterAUParameter.value = 1.0;
    tensenessAUParameter.value = 0.6;
    nasalityAUParameter.value = 0.0;

    _kernel.setParameter(frequencyAddress,      frequencyAUParameter.value);
    _kernel.setParameter(tonguePositionAddress, tonguePositionAUParameter.value);
    _kernel.setParameter(tongueDiameterAddress, tongueDiameterAUParameter.value);
    _kernel.setParameter(tensenessAddress,      tensenessAUParameter.value);
    _kernel.setParameter(nasalityAddress,       nasalityAUParameter.value);

    // Create the parameter tree.
    _parameterTree = [AUParameterTree tree:@[
        frequencyAUParameter,
        tonguePositionAUParameter,
        tongueDiameterAUParameter,
        tensenessAUParameter,
        nasalityAUParameter
    ]];

    parameterTreeBlock(VocalTract)
}

AUAudioUnitGeneratorOverrides(VocalTract);

@end


