//
//  AKAmplitudeTrackerAudioUnit.mm
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright © 2018 AudioKit. All rights reserved.
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

- (float)leftAmplitude {
    return _kernel.leftAmplitude;
}

- (float)rightAmplitude {
    return _kernel.rightAmplitude;
}

- (void)setHalfPowerPoint:(float)halfPowerPoint {
    _kernel.setHalfPowerPoint(halfPowerPoint);
}

- (void)setThreshold:(float)threshold {
    _kernel.setThreshold(threshold);
}
//- (void)setSmoothness:(float)smoothness {
//    _kernel.setSmoothness(smoothness);
//} //in development

-(void)setThresholdCallback:(AKThresholdCallback)thresholdCallback {
    _kernel.thresholdCallback = thresholdCallback;
}

standardKernelPassthroughs()

- (void)createParameters {

    standardSetup(AmplitudeTracker)
}

AUAudioUnitOverrides(AmplitudeTracker)

@end


