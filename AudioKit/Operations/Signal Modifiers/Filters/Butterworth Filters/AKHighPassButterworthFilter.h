//
//  AKHighPassButterworthFilter.h
//  AudioKit
//
//  Auto-generated on 2/19/15.
//  Copyright (c) 2015 Aurelius Prochazka. All rights reserved.
//

#import "AKAudio.h"
#import "AKParameter+Operation.h"

/** A high-pass Butterworth filter.

 These filters are Butterworth second-order IIR filters. They offer an almost flat passband and very good precision and stopband attenuation.
 */

NS_ASSUME_NONNULL_BEGIN
@interface AKHighPassButterworthFilter : AKAudio
/// Instantiates the high pass butterworth filter with all values
/// @param input Input signal to be filtered. 
/// @param cutoffFrequency Cutoff frequency for each of the filters. Updated at Control-rate. [Default Value: 500]
- (instancetype)initWithInput:(AKParameter *)input
              cutoffFrequency:(AKParameter *)cutoffFrequency;

/// Instantiates the high pass butterworth filter with default values
/// @param input Input signal to be filtered.
- (instancetype)initWithInput:(AKParameter *)input;

/// Instantiates the high pass butterworth filter with default values
/// @param input Input signal to be filtered.
+ (instancetype)filterWithInput:(AKParameter *)input;

/// Instantiates the high pass butterworth filter with default values
/// @param input Input signal to be filtered.
- (instancetype)initWithPresetDefaultFilterWithInput:(AKParameter *)input;

/// Instantiates the high pass butterworth filter with default values
/// @param input Input signal to be filtered.
+ (instancetype)presetDefaultFilterWithInput:(AKParameter *)input;

/// Instantiates the high pass butterworth filter with a moderate cutoff
/// @param input Input signal to be filtered.
- (instancetype)initWithPresetModerateFilterWithInput:(AKParameter *)input;

/// Instantiates the high pass butterworth filter with a moderate cutoff
/// @param input Input signal to be filtered.
+ (instancetype)presetModerateFilterWithInput:(AKParameter *)input;

/// Instantiates the high pass butterworth filter with an extreme cutoff
/// @param input Input signal to be filtered.
- (instancetype)initWithPresetExtremeFilterWithInput:(AKParameter *)input;

/// Instantiates the high pass butterworth filter with extreme cutoff
/// @param input Input signal to be filtered.
+ (instancetype)presetExtremeFilterWithInput:(AKParameter *)input;


/// Cutoff frequency for each of the filters. [Default Value: 500]
@property (nonatomic) AKParameter *cutoffFrequency;

/// Set an optional cutoff frequency
/// @param cutoffFrequency Cutoff frequency for each of the filters. Updated at Control-rate. [Default Value: 500]
- (void)setOptionalCutoffFrequency:(AKParameter *)cutoffFrequency;



@end
NS_ASSUME_NONNULL_END
