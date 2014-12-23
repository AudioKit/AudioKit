//
//  AKMixedControl.h
//  AudioKit
//
//  Created by Aurelius Prochazka on 10/12/12.
//  Copyright (c) 2012 Aurelius Prochazka. All rights reserved.
//

#import "AKControl.h"
#import "AKParameter+Operation.h"

/** Calculates the weighted mean value of two control signals.
 */

@interface AKMixedControl : AKControl

/// Create a weighted mean of two signals using a balance point.
/// @param control1 First control
/// @param control2 Second control
/// @param balancePoint A number from 0 (all signal 1) to 1 (all signal 2).
- (instancetype)initWithControl1:(AKControl *)control1
                        control2:(AKControl *)control2
                         balance:(AKControl *)balancePoint;

/// Set the minimum balance point.
/// @param minimumBalancePoint The value for which the balance point would indicate all signal 1.
- (void)setMinimumBalancePoint:(AKConstant *)minimumBalancePoint;

/// Set the maximum balance point.
/// @param maximumBalancePoint The value for which the balance point would indicate all
- (void)setMaximumBalancePoint:(AKConstant *)maximumBalancePoint;


@end
