//
//  AKAmplitudeTrackerAudioUnit.mm
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright (c) 2017 Aurelius Prochazka. All rights reserved.
//

#import "AKAmplitudeTrackerAudioUnit.h"
#import "AKAmplitudeTrackerDSPKernel.hpp"

#import "BufferedAudioBus.hpp"

#import <AudioKit/AudioKit-Swift.h>

@implementation AKAmplitudeTrackerAudioUnit {
    // C++ members need to be ivars; they would be copied on access if they were properties.
    AKAmplitudeTrackerDSPKernel _kernel;
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

- (float)amplitude {
    return _kernel.trackedAmplitude;
}

- (void)createParameters {

    standardSetup(AmplitudeTracker)

    // Create a parameter object for the halfPowerPoint.
    AUParameter *halfPowerPointAUParameter = [AUParameter parameter:@"halfPowerPoint"
                                                               name:@"Half-power point (Hz)"
                                                            address:halfPowerPointAddress
                                                                min:0
                                                                max:20000
                                                               unit:kAudioUnitParameterUnit_Hertz];

    // Initialize the parameter values.
    halfPowerPointAUParameter.value = 10;

    _kernel.setParameter(halfPowerPointAddress, halfPowerPointAUParameter.value);

    // Create the parameter tree.
    _parameterTree = [AUParameterTree createTreeWithChildren:@[
        halfPowerPointAUParameter
    ]];
    
    parameterTreeBlock(AmplitudeTracker)
}

AUAudioUnitOverrides(AmplitudeTracker)

@end


