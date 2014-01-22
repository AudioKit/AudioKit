//
//  OCSLinearControlEnvelope.h
//  City Sounds
//
//  Created by Aurelius Prochazka on 10/12/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//

#import "OCSControl.h"
#import "OCSParameter+Operation.h"

/** Applies a straight line rise and decay pattern to an input amp signal.
 
 Rise modifications are applied for the first irise seconds, and decay from time
 totalDuration - decayTime. If these periods are separated in time there will be
 a steady state during which amp will be unmodified. If linen rise and decay
 periods overlap then both modifications will be in effect for that time. If the
 overall duration is exceeded in performance, the final decay will continue on in
 the same direction, going negative.
 */

@interface OCSLinearControlEnvelope : OCSControl

/// Creates a straight line rise and decay patter to an input signal.
/// @param riseTime      Rise time in seconds. A zero or negative value signifies no rise modification.
/// @param totalDuration Overall duration in seconds. A zero or negative value will cause initialization to be skipped.
/// @param decayTime     Decay time in seconds. Zero means no decay. If it is greater than the total duration, it will cause a truncated decay.
/// @param amplitude     Amplitude to rise to and decay from.
- (instancetype)initWithRiseTime:(OCSConstant *)riseTime
                   totalDuration:(OCSConstant *)totalDuration
                       decayTime:(OCSConstant *)decayTime
                       amplitude:(OCSControl  *)amplitude;


@end
