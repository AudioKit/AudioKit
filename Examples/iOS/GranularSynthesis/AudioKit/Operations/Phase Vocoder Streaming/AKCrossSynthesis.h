//
//  AKCrossSynthesis.h
//  AudioKit
//
//  Auto-generated from scripts by Aurelius Prochazka on 3/29/13.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//

#import "AKFSignal.h"
#import "AKParameter+Operation.h"

/** Performs cross-synthesis between two source F-Signals.
 
 Used to perform cross-synthesis on real-time audio input.
 */

@interface AKCrossSynthesis : AKFSignal

/// Instantiates the cross synthesis
/// @param signal1 First F-Signal
/// @param signal2 Second F-Signal
/// @param amplitude1 First signal's amplitude scaling factor from 0 to 1.
/// @param amplitude2 Second signal's amplitude scaling factor from 0 to 1.
- (instancetype)initWithSignal1:(AKFSignal *)signal1
                        signal2:(AKFSignal *)signal2
                     amplitude1:(AKControl *)amplitude1
                     amplitude2:(AKControl *)amplitude2;

@end