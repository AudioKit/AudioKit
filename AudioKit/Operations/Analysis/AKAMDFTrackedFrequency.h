//
//  AKAMDFTrackedFrequency.h
//  AudioKit
//
//  Auto-generated on 12/5/15.
//  Copyright (c) 2015 Aurelius Prochazka. All rights reserved.
//

#import "AKControl.h"
#import "AKParameter+Operation.h"

/** Follows the pitch of a signal based on the AMDF method.

 Follows the pitch of a signal based on the AMDF method (Average Magnitude Difference Function). Outputs pitch and amplitude tracking signals. The method is quite fast and should run in realtime. This technique usually works best for monophonic signals.
 */

NS_ASSUME_NONNULL_BEGIN
@interface AKAMDFTrackedFrequency : AKControl
/// Instantiates the amdf tracked frequency with all values
/// @param input Audio signal to analyze [Default Value: ]
/// @param estimatedMinimumFrequency Estimated minimum frequency (expressed in Hz) present in the signal [Default Value: 20]
/// @param estimatedMaximumFrequency Estimated maximum frequency (expressed in Hz) present in the signal [Default Value: 4000]
/// @param estimatedInitialFrequency A guess at the initial, if set to 0 it will be the average of the minimum and maximum. [Default Value: 0]
/// @param medianFilterSize The actual size of the filter will be medianFilterSize*2+1. If 0, no median filtering will be applied. [Default Value: 1]
/// @param downsamplingFactor Must be an integer. A downsamplingFactor > 1 results in faster performance, but may result in worse pitch detection. Useful range is 1 - 4.  [Default Value: 1]
/// @param updateFrequency How frequently pitch analysis is executed, expressed in Hz. If 0, this is set to estimatedMinimumFrequency. This is usually reasonable, but experimentation with other values may lead to better results. [Default Value: 0]
- (instancetype)initWithInput:(AKParameter *)input
    estimatedMinimumFrequency:(AKConstant *)estimatedMinimumFrequency
    estimatedMaximumFrequency:(AKConstant *)estimatedMaximumFrequency
    estimatedInitialFrequency:(AKConstant *)estimatedInitialFrequency
             medianFilterSize:(AKConstant *)medianFilterSize
           downsamplingFactor:(AKConstant *)downsamplingFactor
              updateFrequency:(AKConstant *)updateFrequency;

/// Instantiates the amdf tracked frequency with default values
/// @param input Audio signal to analyze
- (instancetype)initWithInput:(AKParameter *)input;

/// Instantiates the amdf tracked frequency with default values
/// @param input Audio signal to analyze
+ (instancetype)WithInput:(AKParameter *)input;

/// Estimated minimum frequency (expressed in Hz) present in the signal [Default Value: 20]
@property (nonatomic) AKConstant *estimatedMinimumFrequency;

/// Set an optional estimated minimum frequency
/// @param estimatedMinimumFrequency Estimated minimum frequency (expressed in Hz) present in the signal [Default Value: 20]
- (void)setOptionalEstimatedMinimumFrequency:(AKConstant *)estimatedMinimumFrequency;

/// Estimated maximum frequency (expressed in Hz) present in the signal [Default Value: 4000]
@property (nonatomic) AKConstant *estimatedMaximumFrequency;

/// Set an optional estimated maximum frequency
/// @param estimatedMaximumFrequency Estimated maximum frequency (expressed in Hz) present in the signal [Default Value: 4000]
- (void)setOptionalEstimatedMaximumFrequency:(AKConstant *)estimatedMaximumFrequency;

/// A guess at the initial, if set to 0 it will be the average of the minimum and maximum. [Default Value: 0]
@property (nonatomic) AKConstant *estimatedInitialFrequency;

/// Set an optional estimated initial frequency
/// @param estimatedInitialFrequency A guess at the initial, if set to 0 it will be the average of the minimum and maximum. [Default Value: 0]
- (void)setOptionalEstimatedInitialFrequency:(AKConstant *)estimatedInitialFrequency;

/// The actual size of the filter will be medianFilterSize*2+1. If 0, no median filtering will be applied. [Default Value: 1]
@property (nonatomic) AKConstant *medianFilterSize;

/// Set an optional median filter size
/// @param medianFilterSize The actual size of the filter will be medianFilterSize*2+1. If 0, no median filtering will be applied. [Default Value: 1]
- (void)setOptionalMedianFilterSize:(AKConstant *)medianFilterSize;

/// Must be an integer. A downsamplingFactor > 1 results in faster performance, but may result in worse pitch detection. Useful range is 1 - 4.  [Default Value: 1]
@property (nonatomic) AKConstant *downsamplingFactor;

/// Set an optional downsampling factor
/// @param downsamplingFactor Must be an integer. A downsamplingFactor > 1 results in faster performance, but may result in worse pitch detection. Useful range is 1 - 4.  [Default Value: 1]
- (void)setOptionalDownsamplingFactor:(AKConstant *)downsamplingFactor;

/// How frequently pitch analysis is executed, expressed in Hz. If 0, this is set to estimatedMinimumFrequency. This is usually reasonable, but experimentation with other values may lead to better results. [Default Value: 0]
@property (nonatomic) AKConstant *updateFrequency;

/// Set an optional update frequency
/// @param updateFrequency How frequently pitch analysis is executed, expressed in Hz. If 0, this is set to estimatedMinimumFrequency. This is usually reasonable, but experimentation with other values may lead to better results. [Default Value: 0]
- (void)setOptionalUpdateFrequency:(AKConstant *)updateFrequency;



@end
NS_ASSUME_NONNULL_END

