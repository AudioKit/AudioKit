//
//  AKLowPassControlFilter.h
//  AudioKit
//
//  Auto-generated on 12/23/14.
//  Copyright (c) 2014 Aurelius Prochazka. All rights reserved.
//

#import "AKControl.h"
#import "AKParameter+Operation.h"

/** A first-order recursive low-pass filter with variable frequency response.

 More detailed description from http://www.csounds.com/manual/html/tonek.html
 */

@interface AKLowPassControlFilter : AKControl
/// Instantiates the low pass control filter with all values
/// @param sourceControl The control to be filtered Updated at Control-rate. [Default Value: ]
/// @param halfPowerPoint The response curve's half-power point, in Hertz. Half power is defined as peak power / root 2. Updated at Control-rate. [Default Value: 100]
- (instancetype)initWithSourceControl:(AKParameter *)sourceControl
                       halfPowerPoint:(AKParameter *)halfPowerPoint;

/// Instantiates the low pass control filter with default values
/// @param sourceControl The control to be filtered
- (instancetype)initWithSourceControl:(AKParameter *)sourceControl;

/// Instantiates the low pass control filter with default values
/// @param sourceControl The control to be filtered
+ (instancetype)controlWithSourceControl:(AKParameter *)sourceControl;

/// The response curve's half-power point, in Hertz. Half power is defined as peak power / root 2. [Default Value: 100]
@property AKParameter *halfPowerPoint;

/// Set an optional half power point
/// @param halfPowerPoint The response curve's half-power point, in Hertz. Half power is defined as peak power / root 2. Updated at Control-rate. [Default Value: 100]
- (void)setOptionalHalfPowerPoint:(AKParameter *)halfPowerPoint;



@end
