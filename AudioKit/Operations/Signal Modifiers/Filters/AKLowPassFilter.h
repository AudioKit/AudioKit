//
//  AKLowPassFilter.h
//  AudioKit
//
//  Auto-generated on 2/19/15.
//  Copyright (c) 2015 Aurelius Prochazka. All rights reserved.
//

#import "AKAudio.h"
#import "AKParameter+Operation.h"

/** A first-order recursive low-pass filter with variable frequency response.

 More detailed description from http://www.csounds.com/manual/html/tone.html
 */

NS_ASSUME_NONNULL_BEGIN
@interface AKLowPassFilter : AKAudio
/// Instantiates the low pass filter with all values
/// @param input The control to be filtered 
/// @param halfPowerPoint The response curve's half-power point, in Hertz. Half power is defined as peak power / root 2. Updated at Control-rate. [Default Value: 1000]
- (instancetype)initWithInput:(AKParameter *)input
               halfPowerPoint:(AKParameter *)halfPowerPoint;

/// Instantiates the low pass filter with default values
/// @param input The control to be filtered
- (instancetype)initWithInput:(AKParameter *)input;

/// Instantiates the low pass filter with default values
/// @param input The control to be filtered
+ (instancetype)filterWithInput:(AKParameter *)input;

/// Instantiates the low pass filter with default values
/// @param input The control to be filtered
- (instancetype)initWithPresetDefaultFilterWithInput:(AKParameter *)input;

/// Instantiates the low pass filter with default values
/// @param input The control to be filtered
+ (instancetype)presetDefaultFilterWithInput:(AKParameter *)input;

/// Instantiates the low pass filter with a muffled sound
/// @param input The control to be filtered
- (instancetype)initWithPresetMuffledFilterWithInput:(AKParameter *)input;

/// Instantiates the low pass filter with a muffled sound
/// @param input The control to be filtered
+ (instancetype)presetMuffledFilterWithInput:(AKParameter *)input;


/// The response curve's half-power point, in Hertz. Half power is defined as peak power / root 2. [Default Value: 1000]
@property (nonatomic) AKParameter *halfPowerPoint;

/// Set an optional half power point
/// @param halfPowerPoint The response curve's half-power point, in Hertz. Half power is defined as peak power / root 2. Updated at Control-rate. [Default Value: 1000]
- (void)setOptionalHalfPowerPoint:(AKParameter *)halfPowerPoint;



@end
NS_ASSUME_NONNULL_END
