//
//  OCSWeightedMean.h
//  ExampleProject
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
@property (nonatomic, strong) OCSParam *audio;
/// The output as a control.
@property (nonatomic, strong) OCSParamControl *control;
/// The output as a constant.
@property (nonatomic, strong) OCSParamConstant *constant;
/// The output can either an audio signal, a control, or a constant.
@property (nonatomic, strong) OCSParam *output;

- (id)initWithSignal1:(OCSParam *)signal1 
              signal2:(OCSParam *)signal2
              balance:(OCSParam *)balancePoint;

@end
