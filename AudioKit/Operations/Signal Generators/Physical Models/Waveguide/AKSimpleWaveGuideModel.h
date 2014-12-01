//
//  AKSimpleWaveGuideModel.h
//  AudioKit
//
//  Auto-generated from scripts by Aurelius Prochazka on 11/30/14.
//  Copyright (c) 2014 Hear For Yourself. All rights reserved.
//

#import "AKAudio.h"
#import "AKParameter+Operation.h"

/** A simple waveguide model consisting of one delay-line and one first-order lowpass filter.
 
 This is the most elemental waveguide model, consisting of one delay-line and one first-order lowpass filter.
 */

@interface AKSimpleWaveGuideModel : AKAudio

/// Instantiates the simple wave guide model with all values
/// @param audioSource The excitation noise.
/// @param frequency The inverse of delay time.
/// @param cutoff Filter cut-off frequency in Hz
/// @param feedback Feedback factor usually between 0 and 1
- (instancetype)initWithAudioSource:(AKAudio *)audioSource
                          frequency:(AKParameter *)frequency
                             cutoff:(AKControl *)cutoff
                           feedback:(AKControl *)feedback;

/// Instantiates the simple wave guide model with default values
/// @param audioSource The excitation noise.
- (instancetype)initWithAudioSource:(AKAudio *)audioSource;


/// Instantiates the simple wave guide model with default values
/// @param audioSource The excitation noise.
+ (instancetype)audioWithAudioSource:(AKAudio *)audioSource;




/// The inverse of delay time. [Default Value: 440]
@property AKParameter *frequency;

/// Set an optional frequency
/// @param frequency The inverse of delay time. [Default Value: 440]
- (void)setOptionalFrequency:(AKParameter *)frequency;


/// Filter cut-off frequency in Hz [Default Value: 3000]
@property AKControl *cutoff;

/// Set an optional cutoff
/// @param cutoff Filter cut-off frequency in Hz [Default Value: 3000]
- (void)setOptionalCutoff:(AKControl *)cutoff;


/// Feedback factor usually between 0 and 1 [Default Value: 0.8]
@property AKControl *feedback;

/// Set an optional feedback
/// @param feedback Feedback factor usually between 0 and 1 [Default Value: 0.8]
- (void)setOptionalFeedback:(AKControl *)feedback;


@end
