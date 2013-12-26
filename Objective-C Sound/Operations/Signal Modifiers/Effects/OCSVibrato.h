//
//  OCSVibrato.h
//  Objective-C Sound
//
//  Auto-generated from scripts by Aurelius Prochazka on 11/4/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//

#import "OCSControl.h"
#import "OCSParameter+Operation.h"

/** Generates a natural-sounding user-controllable vibrato.
 
 vibrato outputs a natural-sounding user-controllable vibrato. The concept is to randomly vary both frequency and amplitude of the oscillator generating the vibrato, in order to simulate the irregularities of a real vibrato. In order to have a total control of these random variations, several input arguments are present. Random variations are obtained by two separated segmented lines, the first controlling frequency deviations, the second the amplitude deviations. Average duration of each segment of each line can be shortened or enlarged by the minimum and maximum randomness arguments, and the deviation from the average amplitude and frequency values can be independently adjusted by means of randomness arguments.
 */

@interface OCSVibrato : OCSControl

/// Instantiates the vibrato
/// @param vibratoShapeTable Vibrato table. It normally contains a sine or a triangle wave.
/// @param averageFrequency Average frequency value of vibrato in Hz
/// @param frequencyRandomness Amount of random frequency deviation
/// @param minimumFrequencyRandomness Minimum frequency of random frequency deviation segments in Hz
/// @param maximumFrequencyRandomness Maximum frequency of random frequency deviation segments in Hz
/// @param averageAmplitude Average amplitude value of vibrato.
/// @param amplitudeDeviation Amount of random amplitude deviation,
/// @param minimumAmplitudeRandomness Minimum frequency of random amplitude deviation segments in Hz
/// @param maximumAmplitudeRandomness Maximum frequency of random amplitude deviation segments in Hz
- (instancetype)initWithVibratoShapeTable:(OCSFTable *)vibratoShapeTable
                         averageFrequency:(OCSControl *)averageFrequency
                      frequencyRandomness:(OCSControl *)frequencyRandomness
               minimumFrequencyRandomness:(OCSControl *)minimumFrequencyRandomness
               maximumFrequencyRandomness:(OCSControl *)maximumFrequencyRandomness
                         averageAmplitude:(OCSControl *)averageAmplitude
                       amplitudeDeviation:(OCSControl *)amplitudeDeviation
               minimumAmplitudeRandomness:(OCSControl *)minimumAmplitudeRandomness
               maximumAmplitudeRandomness:(OCSControl *)maximumAmplitudeRandomness;


/// Set an optional phase
/// @param phase Initial phase of table, expressed as a fraction of a cycle (0 to 1).
- (void)setOptionalPhase:(OCSConstant *)phase;


@end