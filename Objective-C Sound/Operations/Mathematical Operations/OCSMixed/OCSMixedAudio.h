//
//  OCSMixedAudio.h
//  Objective-C Sound
//
//  Created by Aurelius Prochazka on 6/28/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//

#import "OCSParameter+Operation.h"

/** Calculates the weighted mean value of two input signals.
 */

@interface OCSMixedAudio : OCSParameter

/// Create a weighted mean of two signals using a balance point.
/// @param signal1 First signal
/// @param signal2 Second signal
/// @param balancePoint A number from 0 (all signal 1) to 1 (all signal 2).
- (id)initWithSignal1:(OCSParameter *)signal1 
              signal2:(OCSParameter *)signal2
              balance:(OCSControl *)balancePoint;

/// Set the minimum balance point.
/// @param minimumBalancePoint The value for which the balance point would indicate all signal 1.
- (void)setMinimumBalancePoint:(OCSConstant *)minimumBalancePoint;

/// Set the maximum balance point.
/// @param maximumBalancePoint The value for which the balance point would indicate all
- (void)setMaximumBalancePoint:(OCSConstant *)maximumBalancePoint;

@end
