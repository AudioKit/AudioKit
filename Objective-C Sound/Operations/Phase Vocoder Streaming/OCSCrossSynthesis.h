//
//  OCSCrossSynthesis.h
//  Objective-C Sound
//
//  Auto-generated from database on 3/29/13.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//

#import "OCSFSignal.h"
#import "OCSParameter+Operation.h"

/** Performs cross-synthesis between two source F-Signals.
 
 Used to perform cross-synthesis on real-time audio input.
 */

@interface OCSCrossSynthesis : OCSFSignal

/// Instantiates the cross synthesis
/// @param signal1 First F-Signal
/// @param signal2 Second F-Signal
/// @param amplitude1 First signal's amplitude scaling factor from 0 to 1.
/// @param amplitude2 Second signal's amplitude scaling factor from 0 to 1.
- (instancetype)initWithSignal1:(OCSFSignal *)signal1
                        signal2:(OCSFSignal *)signal2
                     amplitude1:(OCSControl *)amplitude1
                     amplitude2:(OCSControl *)amplitude2;

@end