//
//  OCSLowPassControlFilter.h
//  Objective-C Sound
//
//  Auto-generated from scripts by Aurelius Prochazka on 11/6/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//

#import "OCSControl.h"
#import "OCSParameter+Operation.h"

/** A first-order recursive low-pass filter with variable frequency response.
 
 More detailed description from http://www.csounds.com/manual/html/tone.html
 */

@interface OCSLowPassControlFilter : OCSControl

/// Instantiates the low pass control filter
/// @param sourceControl  The control signal to be filtered
/// @param halfPowerPoint The response curve's half-power point, in Hertz. Half power is defined as peak power / root 2.
- (instancetype)initWithSourceControl:(OCSControl *)sourceControl
                       halfPowerPoint:(OCSControl *)halfPowerPoint;

@end