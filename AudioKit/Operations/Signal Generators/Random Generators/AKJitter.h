//
//  AKJitter.h
//  AudioKit
//
//  Auto-generated from scripts by Aurelius Prochazka on 12/21/14.
//  Copyright (c) 2014 Hear For Yourself. All rights reserved.
//

#import "AKControl.h"
#import "AKParameter+Operation.h"

/** Generates a segmented line whose segments are randomly generated.

 This operation generates a segmented line whose segments are randomly generated inside the interval amplitude to -amplitude. Duration of each segment is a random value generated according to minimum and maximum frequency values.
This can be used to make more natural and “analog-sounding” some static, dull sound. For best results, it is suggested to keep its amplitude moderate.
 */

@interface AKJitter : AKControl
/// Instantiates the jitter with all values
/// @param amplitude Amplitude of jitter deviation [Default Value: 1]
/// @param minimumFrequency Minimum speed of random frequency variations (expressed in Hz) [Default Value: 0]
/// @param maximumFrequency Maximum speed of random frequency variations (expressed in Hz) [Default Value: 60]
- (instancetype)initWithAmplitude:(AKControl *)amplitude
                 minimumFrequency:(AKControl *)minimumFrequency
                 maximumFrequency:(AKControl *)maximumFrequency;

/// Instantiates the jitter with default values
- (instancetype)init;

/// Instantiates the jitter with default values
+ (instancetype)control;


/// Amplitude of jitter deviation [Default Value: 1]
@property AKControl *amplitude;

/// Set an optional amplitude
/// @param amplitude Amplitude of jitter deviation [Default Value: 1]
- (void)setOptionalAmplitude:(AKControl *)amplitude;

/// Minimum speed of random frequency variations (expressed in Hz) [Default Value: 0]
@property AKControl *minimumFrequency;

/// Set an optional minimum frequency
/// @param minimumFrequency Minimum speed of random frequency variations (expressed in Hz) [Default Value: 0]
- (void)setOptionalMinimumFrequency:(AKControl *)minimumFrequency;

/// Maximum speed of random frequency variations (expressed in Hz) [Default Value: 60]
@property AKControl *maximumFrequency;

/// Set an optional maximum frequency
/// @param maximumFrequency Maximum speed of random frequency variations (expressed in Hz) [Default Value: 60]
- (void)setOptionalMaximumFrequency:(AKControl *)maximumFrequency;



@end
