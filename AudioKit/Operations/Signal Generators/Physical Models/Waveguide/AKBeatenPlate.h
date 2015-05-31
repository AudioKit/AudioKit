//
//  AKBeatenPlate.h
//  AudioKit
//
//  Auto-generated on 1/3/15.
//  Copyright (c) 2015 Aurelius Prochazka. All rights reserved.
//

#import "AKAudio.h"
#import "AKParameter+Operation.h"

/** A model of beaten plate consisting of two parallel delay-lines and two first-order lowpass filters.

 This  is a model of beaten plate consisting of two parallel delay-lines and two first-order lowpass filters. The two feedback lines are mixed and sent to the delay again each cycle.
 */

NS_ASSUME_NONNULL_BEGIN
@interface AKBeatenPlate : AKAudio
/// Instantiates the beaten plate with all values
/// @param input The excitation noise. 
/// @param frequency1 The inverse of delay time for the first of two parallel delay lines. [Default Value: 5000]
/// @param frequency2 The inverse of delay time for the second of two parallel delay lines. [Default Value: 2000]
/// @param cutoffFrequency1 The filter cutoff frequency in Hz for the first low-pass filter. Updated at Control-rate. [Default Value: 3000]
/// @param cutoffFrequency2 The filter cutoff frequency in Hz for the second low-pass filter. Updated at Control-rate. [Default Value: 1500]
/// @param feedback1 The feedback factor for the first effects loop. Updated at Control-rate. [Default Value: 0.25]
/// @param feedback2 The feedback factor for the second effects loop. Updated at Control-rate. [Default Value: 0.25]
- (instancetype)initWithInput:(AKParameter *)input
                   frequency1:(AKParameter *)frequency1
                   frequency2:(AKParameter *)frequency2
             cutoffFrequency1:(AKParameter *)cutoffFrequency1
             cutoffFrequency2:(AKParameter *)cutoffFrequency2
                    feedback1:(AKParameter *)feedback1
                    feedback2:(AKParameter *)feedback2;

/// Instantiates the beaten plate with default values
/// @param input The excitation noise.
- (instancetype)initWithInput:(AKParameter *)input;

/// Instantiates the beaten plate with default values
/// @param input The excitation noise.
+ (instancetype)beatenPlateWithInput:(AKParameter *)input;

/// The inverse of delay time for the first of two parallel delay lines. [Default Value: 5000]
@property AKParameter *frequency1;

/// Set an optional frequency1
/// @param frequency1 The inverse of delay time for the first of two parallel delay lines. [Default Value: 5000]
- (void)setOptionalFrequency1:(AKParameter *)frequency1;

/// The inverse of delay time for the second of two parallel delay lines. [Default Value: 2000]
@property AKParameter *frequency2;

/// Set an optional frequency2
/// @param frequency2 The inverse of delay time for the second of two parallel delay lines. [Default Value: 2000]
- (void)setOptionalFrequency2:(AKParameter *)frequency2;

/// The filter cutoff frequency in Hz for the first low-pass filter. [Default Value: 3000]
@property AKParameter *cutoffFrequency1;

/// Set an optional cutoff frequency1
/// @param cutoffFrequency1 The filter cutoff frequency in Hz for the first low-pass filter. Updated at Control-rate. [Default Value: 3000]
- (void)setOptionalCutoffFrequency1:(AKParameter *)cutoffFrequency1;

/// The filter cutoff frequency in Hz for the second low-pass filter. [Default Value: 1500]
@property AKParameter *cutoffFrequency2;

/// Set an optional cutoff frequency2
/// @param cutoffFrequency2 The filter cutoff frequency in Hz for the second low-pass filter. Updated at Control-rate. [Default Value: 1500]
- (void)setOptionalCutoffFrequency2:(AKParameter *)cutoffFrequency2;

/// The feedback factor for the first effects loop. [Default Value: 0.25]
@property AKParameter *feedback1;

/// Set an optional feedback1
/// @param feedback1 The feedback factor for the first effects loop. Updated at Control-rate. [Default Value: 0.25]
- (void)setOptionalFeedback1:(AKParameter *)feedback1;

/// The feedback factor for the second effects loop. [Default Value: 0.25]
@property AKParameter *feedback2;

/// Set an optional feedback2
/// @param feedback2 The feedback factor for the second effects loop. Updated at Control-rate. [Default Value: 0.25]
- (void)setOptionalFeedback2:(AKParameter *)feedback2;



@end
NS_ASSUME_NONNULL_END
