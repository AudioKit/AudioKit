//
//  AKCrossSynthesizedFFT.h
//  AudioKit
//
//  Auto-generated on 3/29/13.
//  Copyright (c) 2012 Aurelius Prochazka. All rights reserved.
//

#import "AKFSignal.h"
#import "AKParameter+Operation.h"

/** Performs cross-synthesis between two source F-Signals.

 Used to perform cross-synthesis on real-time audio input.
 */

NS_ASSUME_NONNULL_BEGIN
@interface AKCrossSynthesizedFFT : AKFSignal

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
NS_ASSUME_NONNULL_END
