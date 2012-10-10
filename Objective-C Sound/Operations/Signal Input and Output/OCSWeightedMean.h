//
//  OCSWeightedMean.h
//  Objective-C Sound
//
//  Created by Aurelius Prochazka on 6/28/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//

#import "OCSParameter+Operation.h"

/** Calculates the weighted mean value of two input signals.
 */

@interface OCSWeightedMean : OCSParameter

/// @name Properties

/// The output as audio.
@property (nonatomic, strong) OCSParameter *audio;
/// The output as a control.
@property (nonatomic, strong) OCSControl *control;
/// The output as a constant.
@property (nonatomic, strong) OCSConstant *constant;
/// The output can either an audio signal, a control, or a constant.
@property (nonatomic, strong) OCSParameter *output;

/// @name Initialization

/// Create a weighted mean of two signals using a balance point.
/// @param signal1 First signal
/// @param signal2 Second signal
/// @param balancePoint A number from 0 (all signal 1) to 1 (all signal 2).
- (id)initWithSignal1:(OCSParameter *)signal1 
              signal2:(OCSParameter *)signal2
              balance:(OCSParameter *)balancePoint;

/// Create a weighted mean of two signals using a balance point.
/// @param signal1 First signal
/// @param signal2 Second signal
/// @param balancePoint A number from 0 (all signal 1) to 1 (all signal 2).
/// @param minimum The value for which the balance point would indicate all signal 1.
/// @param maximum The value for which the balance point would indicate all signal 2.
- (id)initWithSignal1:(OCSParameter *)signal1 
              signal2:(OCSParameter *)signal2
              balance:(OCSParameter *)balancePoint
              minimum:(OCSConstant *)minimum
              maximum:(OCSConstant *)maximum;


@end
