//
//  AKJitter.h
//  AudioKit
//
//  Auto-generated on 2/19/15.
//  Copyright (c) 2015 Aurelius Prochazka. All rights reserved.
//

#import "AKControl.h"
#import "AKParameter+Operation.h"

/** Generates a segmented line whose segments are randomly generated.

 This operation generates a segmented line whose segments are randomly generated inside the interval amplitude to -amplitude. Duration of each segment is a random value generated according to minimum and maximum frequency values.
This can be used to make more natural and “analog-sounding” some static, dull sound. For best results, it is suggested to keep its amplitude moderate.
 */

NS_ASSUME_NONNULL_BEGIN
@interface AKJitter : AKControl
/// Instantiates the jitter with all values
/// @param amplitude Amplitude of jitter deviation Updated at Control-rate. [Default Value: 1]
/// @param minimumFrequency Minimum speed of random frequency variations (expressed in Hz) Updated at Control-rate. [Default Value: 0]
/// @param maximumFrequency Maximum speed of random frequency variations (expressed in Hz) Updated at Control-rate. [Default Value: 60]
- (instancetype)initWithAmplitude:(AKParameter *)amplitude
                 minimumFrequency:(AKParameter *)minimumFrequency
                 maximumFrequency:(AKParameter *)maximumFrequency;

/// Instantiates the jitter with default values
- (instancetype)init;

/// Instantiates the jitter with default values
+ (instancetype)jitter;


/// Amplitude of jitter deviation [Default Value: 1]
@property (nonatomic) AKParameter *amplitude;

/// Set an optional amplitude
/// @param amplitude Amplitude of jitter deviation Updated at Control-rate. [Default Value: 1]
- (void)setOptionalAmplitude:(AKParameter *)amplitude;

/// Minimum speed of random frequency variations (expressed in Hz) [Default Value: 0]
@property (nonatomic) AKParameter *minimumFrequency;

/// Set an optional minimum frequency
/// @param minimumFrequency Minimum speed of random frequency variations (expressed in Hz) Updated at Control-rate. [Default Value: 0]
- (void)setOptionalMinimumFrequency:(AKParameter *)minimumFrequency;

/// Maximum speed of random frequency variations (expressed in Hz) [Default Value: 60]
@property (nonatomic) AKParameter *maximumFrequency;

/// Set an optional maximum frequency
/// @param maximumFrequency Maximum speed of random frequency variations (expressed in Hz) Updated at Control-rate. [Default Value: 60]
- (void)setOptionalMaximumFrequency:(AKParameter *)maximumFrequency;



@end
NS_ASSUME_NONNULL_END
