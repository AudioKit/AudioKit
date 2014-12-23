//
//  AKMixedAudio.h
//  AudioKit
//
//  Created by Aurelius Prochazka on 6/28/12.
//  Copyright (c) 2012 Aurelius Prochazka. All rights reserved.
//

#import "AKAudio.h"
#import "AKParameter+Operation.h"

/** Calculates the weighted mean value of two input signals.
 */

@interface AKMixedAudio : AKAudio

/// Create a weighted mean of two signals using a balance point.
/// @param signal1 First signal
/// @param signal2 Second signal
/// @param balancePoint A number from 0 (all signal 1) to 1 (all signal 2).
- (instancetype)initWithSignal1:(AKAudio *)signal1
                        signal2:(AKAudio *)signal2
                        balance:(AKControl *)balancePoint;

/// Set the minimum balance point.
/// @param minimumBalancePoint The value for which the balance point would indicate all signal 1.
- (void)setMinimumBalancePoint:(AKConstant *)minimumBalancePoint;

/// Set the maximum balance point.
/// @param maximumBalancePoint The value for which the balance point would indicate all
- (void)setMaximumBalancePoint:(AKConstant *)maximumBalancePoint;

@end
