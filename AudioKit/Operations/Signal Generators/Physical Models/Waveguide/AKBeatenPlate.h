//
//  AKBeatenPlate.h
//  AudioKit
//
//  Auto-generated on 11/30/14.
//  Copyright (c) 2014 Aurelius Prochazka. All rights reserved.
//

#import "AKAudio.h"
#import "AKParameter+Operation.h"

/** A model of beaten plate consisting of two parallel delay-lines and two first-order lowpass filters.

 This  is a model of beaten plate consisting of two parallel delay-lines and two first-order lowpass filters. The two feedback lines are mixed and sent to the delay again each cycle.
 */

@interface AKBeatenPlate : AKAudio

/// Instantiates the beaten plate with all values
/// @param audioSource The excitation noise.
/// @param frequency1 The inverse of delay time for the first of two parallel delay lines.
/// @param frequency2 The inverse of delay time for the second of two parallel delay lines.
/// @param cutoffFrequency1 The filter cutoff frequency in Hz for the first low-pass filter.
/// @param cutoffFrequency2 The filter cutoff frequency in Hz for the second low-pass filter.
/// @param feedback1 The feedback factor for the first effects loop.
/// @param feedback2 The feedback factor for the second effects loop.
- (instancetype)initWithAudioSource:(AKAudio *)audioSource
                         frequency1:(AKParameter *)frequency1
                         frequency2:(AKParameter *)frequency2
                   cutoffFrequency1:(AKControl *)cutoffFrequency1
                   cutoffFrequency2:(AKControl *)cutoffFrequency2
                          feedback1:(AKControl *)feedback1
                          feedback2:(AKControl *)feedback2;

/// Instantiates the beaten plate with default values
/// @param audioSource The excitation noise.
- (instancetype)initWithAudioSource:(AKAudio *)audioSource;


/// Instantiates the beaten plate with default values
/// @param audioSource The excitation noise.
+ (instancetype)audioWithAudioSource:(AKAudio *)audioSource;




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
@property AKControl *cutoffFrequency1;

/// Set an optional cutoff frequency1
/// @param cutoffFrequency1 The filter cutoff frequency in Hz for the first low-pass filter. [Default Value: 3000]
- (void)setOptionalCutoffFrequency1:(AKControl *)cutoffFrequency1;


/// The filter cutoff frequency in Hz for the second low-pass filter. [Default Value: 1500]
@property AKControl *cutoffFrequency2;

/// Set an optional cutoff frequency2
/// @param cutoffFrequency2 The filter cutoff frequency in Hz for the second low-pass filter. [Default Value: 1500]
- (void)setOptionalCutoffFrequency2:(AKControl *)cutoffFrequency2;


/// The feedback factor for the first effects loop. [Default Value: 0.25]
@property AKControl *feedback1;

/// Set an optional feedback1
/// @param feedback1 The feedback factor for the first effects loop. [Default Value: 0.25]
- (void)setOptionalFeedback1:(AKControl *)feedback1;


/// The feedback factor for the second effects loop. [Default Value: 0.25]
@property AKControl *feedback2;

/// Set an optional feedback2
/// @param feedback2 The feedback factor for the second effects loop. [Default Value: 0.25]
- (void)setOptionalFeedback2:(AKControl *)feedback2;


@end
