//
//  AKTrackedAmplitudeFromFSignal.h
//  AudioKit
//
//  Created by Aurelius Prochazka on 8/3/14.
//  Copyright (c) 2014 h4y. All rights reserved.
//

#import "AKParameter+Operation.h"
#import "AKControl.h"
#import "AKFSignal.h"

@interface AKTrackedAmplitudeFromFSignal : AKControl

/// Initialize the tracked amplitude.
/// @param fSignalSource      Input mono F-Signal.
/// @param amplitudeThreshold Amplitude threshold (0-1). Higher values will eliminate low-amplitude spectral components from being included in the analysis.
- (instancetype)initWithFSignalSource:(AKFSignal *)fSignalSource
                   amplitudeThreshold:(AKControl *)amplitudeThreshold;

@end
