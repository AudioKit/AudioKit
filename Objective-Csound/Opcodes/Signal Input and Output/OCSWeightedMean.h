//
//  OCSWeightedMean.h
//  Objective-Csound
//
//  Created by Aurelius Prochazka on 6/28/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//

#import "OCSOpcode.h"

/** Calculates the weighted mean value of two input signals.
 
 http://www.csounds.com/manual/html/ntrpol.html
 */

@interface OCSWeightedMean : OCSOpcode

/// The output as audio.
@property (nonatomic, strong) OCSParameter *audio;
/// The output as a control.
@property (nonatomic, strong) OCSControl *control;
/// The output as a constant.
@property (nonatomic, strong) OCSConstant *constant;
/// The output can either an audio signal, a control, or a constant.
@property (nonatomic, strong) OCSParameter *output;

- (id)initWithSignal1:(OCSParameter *)signal1 
              signal2:(OCSParameter *)signal2
              balance:(OCSParameter *)balancePoint;

@end
