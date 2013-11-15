//
//  OCSMixedControl.h
//  Objective-C Sound
//
//  Created by Aurelius Prochazka on 10/12/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//

#import "OCSControl.h"
#import "OCSParameter+Operation.h"

/** Calculates the weighted mean value of two control signals.
 */

@interface OCSMixedControl : OCSControl

/// Create a weighted mean of two signals using a balance point.
/// @param control1 First control
/// @param control2 Second control
/// @param balancePoint A number from 0 (all signal 1) to 1 (all signal 2).
- (instancetype)initWithControl1:(OCSControl *)control1
              control2:(OCSControl *)control2
               balance:(OCSControl *)balancePoint;

/// Set the minimum balance point.
/// @param minimumBalancePoint The value for which the balance point would indicate all signal 1.
- (void)setMinimumBalancePoint:(OCSConstant *)minimumBalancePoint;

/// Set the maximum balance point.
/// @param maximumBalancePoint The value for which the balance point would indicate all
- (void)setMaximumBalancePoint:(OCSConstant *)maximumBalancePoint;


@end
