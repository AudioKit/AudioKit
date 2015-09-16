//
//  AKTrackedAmplitude.h
//  AudioKit
//
//  Auto-generated on 1/3/15.
//  Copyright (c) 2015 Aurelius Prochazka. All rights reserved.
//

#import "AKControl.h"
#import "AKParameter+Operation.h"

/** Root-mean-square amplitude of an audio signal
 
This operation low-pass filters the actual value, to average in the manner of a VU meter. This unit is not a signal modifier, but functions rather as a signal power-gauge. It uses an internal low-pass filter to make the response smoother. The halfPowerPoint can be used to control this smoothing. The higher the value, the "snappier" the measurement.
 */

NS_ASSUME_NONNULL_BEGIN
@interface AKTrackedAmplitude : AKControl
/// Instantiates the tracked amplitude with all values
/// @param input Input audio signal to track. 
/// @param halfPowerPoint Half-power point (in Hz) of a special internal low-pass filter. [Default Value: 10]
- (instancetype)initWithInput:(AKParameter *)input
               halfPowerPoint:(AKConstant *)halfPowerPoint;

/// Instantiates the tracked amplitude with default values
/// @param input Input audio signal to track.
- (instancetype)initWithInput:(AKParameter *)input;

/// Instantiates the tracked amplitude with default values
/// @param input Input audio signal to track.
+ (instancetype)amplitudeWithInput:(AKParameter *)input;

/// Half-power point (in Hz) of a special internal low-pass filter. [Default Value: 10]
@property AKConstant *halfPowerPoint;

/// Set an optional half power point
/// @param halfPowerPoint Half-power point (in Hz) of a special internal low-pass filter. [Default Value: 10]
- (void)setOptionalHalfPowerPoint:(AKConstant *)halfPowerPoint;



@end
NS_ASSUME_NONNULL_END
