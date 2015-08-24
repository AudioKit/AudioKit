//
//  AKHighPassFilter.h
//  AudioKit
//
//  Auto-generated on 2/19/15.
//  Copyright (c) 2015 Aurelius Prochazka. All rights reserved.
//

#import "AKAudio.h"
#import "AKParameter+Operation.h"

/** A first-order recursive high-pass filter with variable frequency response.

 A complement to the AKLowPassFilter.
 */

NS_ASSUME_NONNULL_BEGIN
@interface AKHighPassFilter : AKAudio
/// Instantiates the high pass filter with all values
/// @param input The input signal to be filtered 
/// @param cutoffFrequency The response curve's half-power point, in Hertz. Half power is defined as peak power / root 2. Updated at Control-rate. [Default Value: 4000]
- (instancetype)initWithInput:(AKParameter *)input
              cutoffFrequency:(AKParameter *)cutoffFrequency;

/// Instantiates the high pass filter with default values
/// @param input The input signal to be filtered
- (instancetype)initWithInput:(AKParameter *)input;

/// Instantiates the high pass filter with default values
/// @param input The input signal to be filtered
+ (instancetype)filterWithInput:(AKParameter *)input;

/// Instantiates the high pass filter with default values
/// @param input The input signal to be filtered
- (instancetype)initWithPresetDefaultFilterWithInput:(AKParameter *)input;

/// Instantiates the high pass filter with default values
/// @param input The input signal to be filtered
+ (instancetype)presetDefaultFilterWithInput:(AKParameter *)input;

/// Instantiates the high pass filter with a high cuttoff frequency
/// @param input The input signal to be filtered
- (instancetype)initWithPresetHighCutoffFilterWithInput:(AKParameter *)input;

/// Instantiates the high pass filter with a high cuttoff frequency
/// @param input The input signal to be filtered
+ (instancetype)presetHighCutoffFilterWithInput:(AKParameter *)input;

/// The response curve's half-power point, in Hertz. Half power is defined as peak power / root 2. [Default Value: 4000]
@property (nonatomic) AKParameter *cutoffFrequency;

/// Set an optional cutoff frequency
/// @param cutoffFrequency The response curve's half-power point, in Hertz. Half power is defined as peak power / root 2. Updated at Control-rate. [Default Value: 4000]
- (void)setOptionalCutoffFrequency:(AKParameter *)cutoffFrequency;



@end
NS_ASSUME_NONNULL_END
