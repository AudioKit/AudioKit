//
//  AKMandolin.h
//  AudioKit
//
//  Auto-generated from scripts by Aurelius Prochazka on 11/30/14.
//  Customized by Aurelius Prochazka on 11/30/14.
//  Copyright (c) 2014 Hear For Yourself. All rights reserved.
//

#import "AKAudio.h"
#import "AKParameter+Operation.h"

/** An emulation of a mandolin.

 A mandolin emulation with amplitude, frequency, tuning, gain and mandolin size parameters.
 */

@interface AKMandolin : AKAudio

/// Instantiates the mandolin with all values
/// @param frequency Frequency of note played.
/// @param bodySize The size of the body of the mandolin. Range 0 to 2.
/// @param pairedStringDetuning The proportional detuning between the two strings. Suggested range 0.9 to 1.
/// @param pluckPosition The pluck position, in range 0 to 1.
/// @param loopGain The loop gain of the model, in the range 0.97 to 1.
- (instancetype)initWithFrequency:(AKControl *)frequency
                         bodySize:(AKControl *)bodySize
             pairedStringDetuning:(AKControl *)pairedStringDetuning
                    pluckPosition:(AKControl *)pluckPosition
                         loopGain:(AKControl *)loopGain;

/// Instantiates the mandolin with default values
- (instancetype)init;


/// Instantiates the mandolin with default values
+ (instancetype)audio;




/// Frequency of note played. [Default Value: 220]
@property AKControl *frequency;

/// Set an optional frequency
/// @param frequency Frequency of note played. [Default Value: 220]
- (void)setOptionalFrequency:(AKControl *)frequency;


/// The size of the body of the mandolin. Range 0 to 2. [Default Value: 1]
@property AKControl *bodySize;

/// Set an optional body size
/// @param bodySize The size of the body of the mandolin. Range 0 to 2. [Default Value: 1]
- (void)setOptionalBodySize:(AKControl *)bodySize;


/// The proportional detuning between the two strings. Suggested range 0.9 to 1. [Default Value: 1]
@property AKControl *pairedStringDetuning;

/// Set an optional paired string detuning
/// @param pairedStringDetuning The proportional detuning between the two strings. Suggested range 0.9 to 1. [Default Value: 1]
- (void)setOptionalPairedStringDetuning:(AKControl *)pairedStringDetuning;


/// The pluck position, in range 0 to 1. [Default Value: 0.4]
@property AKControl *pluckPosition;

/// Set an optional pluck position
/// @param pluckPosition The pluck position, in range 0 to 1. [Default Value: 0.4]
- (void)setOptionalPluckPosition:(AKControl *)pluckPosition;


/// The loop gain of the model, in the range 0.97 to 1. [Default Value: 0.99]
@property AKControl *loopGain;

/// Set an optional loop gain
/// @param loopGain The loop gain of the model, in the range 0.97 to 1. [Default Value: 1]
- (void)setOptionalLoopGain:(AKControl *)loopGain;


@end
