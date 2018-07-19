//
//  AKFrequencyTrackerAudioUnit.mm
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright © 2018 AudioKit. All rights reserved.
//

#import "AKFrequencyTrackerAudioUnit.h"
#import "AKFrequencyTrackerDSPKernel.hpp"

#import "BufferedAudioBus.hpp"

#import <AudioKit/AudioKit-Swift.h>

@implementation AKFrequencyTrackerAudioUnit {
    // C++ members need to be ivars; they would be copied on access if they were properties.
    AKFrequencyTrackerDSPKernel _kernel;
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
- (float)frequency {
    return _kernel.trackedFrequency;
}

- (void)setHopSize:(UInt32)hopSize {
    _kernel.hopSize = hopSize;
}
- (void)setPeakCount:(UInt32)peakCount {
    _kernel.peakCount = peakCount;
}


- (void)createParameters {

    standardSetup(FrequencyTracker)

    // Create the parameter tree.
    _parameterTree = [AUParameterTree createTreeWithChildren:@[]];

    parameterTreeBlock(FrequencyTracker)
}

AUAudioUnitOverrides(FrequencyTracker)


@end


