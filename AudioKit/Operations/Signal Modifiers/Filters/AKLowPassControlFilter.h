//
//  AKLowPassControlFilter.h
//  AudioKit
//
//  Auto-generated from scripts by Aurelius Prochazka on 11/6/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//

#import "AKControl.h"
#import "AKParameter+Operation.h"

/** A first-order recursive low-pass filter with variable frequency response.
 */

@interface AKLowPassControlFilter : AKControl

/// Instantiates the low pass control filter
/// @param sourceControl  The control signal to be filtered
/// @param halfPowerPoint The response curve's half-power point, in Hertz. Half power is defined as peak power / root 2.
- (instancetype)initWithSourceControl:(AKControl *)sourceControl
                       halfPowerPoint:(AKControl *)halfPowerPoint;

@end