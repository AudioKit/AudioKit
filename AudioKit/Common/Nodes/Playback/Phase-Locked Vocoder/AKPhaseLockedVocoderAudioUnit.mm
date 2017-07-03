//
//  AKPhaseLockedVocoderAudioUnit.mm
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright © 2017 Aurelius Prochazka. All rights reserved.
//

#import "AKPhaseLockedVocoderAudioUnit.h"
#import "AKPhaseLockedVocoderDSPKernel.hpp"

#import "BufferedAudioBus.hpp"

#import <AudioKit/AudioKit-Swift.h>

@implementation AKPhaseLockedVocoderAudioUnit {
    // C++ members need to be ivars; they would be copied on access if they were properties.
    AKPhaseLockedVocoderDSPKernel _kernel;
    BufferedOutputBus _outputBusBuffer;
}
@synthesize parameterTree = _parameterTree;

- (void)setPosition:(float)position {
    _kernel.setPosition(position);
}
- (void)setAmplitude:(float)amplitude {
    _kernel.setAmplitude(amplitude);
}
- (void)setPitchRatio:(float)pitchRatio {
    _kernel.setPitchRatio(pitchRatio);
}

- (void)setupAudioFileTable:(float *)data size:(UInt32)size {
    _kernel.setUpTable(data, size);
}

standardKernelPassthroughs()

- (void)createParameters {

    standardGeneratorSetup(PhaseLockedVocoder)

    // Create a parameter object for the position.
    AUParameter *positionAUParameter = [AUParameter parameter:@"position"
                                                         name:@"Position in time. When non-changing it will do a spectral freeze of a the current point in time."
                                                      address:positionAddress
                                                          min:0
                                                          max:1
                                                         unit:kAudioUnitParameterUnit_Generic];

    // Create a parameter object for the amplitude.
    AUParameter *amplitudeAUParameter = [AUParameter parameter:@"amplitude"
                                                          name:@"Amplitude."
                                                       address:amplitudeAddress
                                                           min:0
                                                           max:1
                                                          unit:kAudioUnitParameterUnit_Generic];
    // Create a parameter object for the pitchRatio.
    AUParameter *pitchRatioAUParameter = [AUParameter parameter:@"pitchRatio"
                                                           name:@"Pitch ratio. A value of. 1  normal, 2 is double speed, 0.5 is halfspeed, etc."
                                                        address:pitchRatioAddress
                                                            min:0
                                                            max:1000
                                                           unit:kAudioUnitParameterUnit_Hertz];

    // Initialize the parameter values.
    positionAUParameter.value = 0;
    amplitudeAUParameter.value = 1;
    pitchRatioAUParameter.value = 1;

    _kernel.setParameter(positionAddress,   positionAUParameter.value);
    _kernel.setParameter(amplitudeAddress,  amplitudeAUParameter.value);
    _kernel.setParameter(pitchRatioAddress, pitchRatioAUParameter.value);

    // Create the parameter tree.
    _parameterTree = [AUParameterTree tree:@[
        positionAUParameter,
        amplitudeAUParameter,
        pitchRatioAUParameter
    ]];

	parameterTreeBlock(PhaseLockedVocoder)
}

AUAudioUnitGeneratorOverrides(PhaseLockedVocoder)

@end


