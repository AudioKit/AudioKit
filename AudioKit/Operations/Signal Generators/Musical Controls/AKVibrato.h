//
//  AKVibrato.h
//  AudioKit
//
//  Auto-generated on 12/21/14.
//  Copyright (c) 2014 Aurelius Prochazka. All rights reserved.
//

#import "AKControl.h"
#import "AKParameter+Operation.h"

/** Generates a natural-sounding user-controllable vibrato.

 AKVibrato outputs a natural-sounding user-controllable vibrato. The concept is to randomly vary both frequency and amplitude of the oscillator generating the vibrato, in order to simulate the irregularities of a real vibrato. In order to have a total control of these random variations, several input arguments are present. Random variations are obtained by two separated segmented lines, the first controlling frequency deviations, the second the amplitude deviations. Average duration of each segment of each line can be shortened or enlarged by the minimum and maximum randomness arguments, and the deviation from the average amplitude and frequency values can be independently adjusted by means of randomness arguments.
 */

@interface AKVibrato : AKControl
/// Instantiates the vibrato with all values
/// @param vibratoShapeTable Vibrato table. It normally contains a sine or a triangle wave. [Default Value: sine]
/// @param averageFrequency Average frequency value of vibrato in Hz [Default Value: 2]
/// @param frequencyRandomness Amount of random frequency deviation [Default Value: 0]
/// @param minimumFrequencyRandomness Minimum frequency of random frequency deviation segments in Hz [Default Value: 0]
/// @param maximumFrequencyRandomness Maximum frequency of random frequency deviation segments in Hz [Default Value: 60]
/// @param averageAmplitude Average amplitude value of vibrato. [Default Value: 1]
/// @param amplitudeDeviation Amount of random amplitude deviation, [Default Value: 0]
/// @param minimumAmplitudeRandomness Minimum frequency of random amplitude deviation segments in Hz [Default Value: 0]
/// @param maximumAmplitudeRandomness Maximum frequency of random amplitude deviation segments in Hz [Default Value: 0]
/// @param phase Initial phase of table, expressed as a fraction of a cycle (0 to 1). [Default Value: 0]
- (instancetype)initWithVibratoShapeTable:(AKFTable *)vibratoShapeTable
                         averageFrequency:(AKControl *)averageFrequency
                      frequencyRandomness:(AKControl *)frequencyRandomness
               minimumFrequencyRandomness:(AKControl *)minimumFrequencyRandomness
               maximumFrequencyRandomness:(AKControl *)maximumFrequencyRandomness
                         averageAmplitude:(AKControl *)averageAmplitude
                       amplitudeDeviation:(AKControl *)amplitudeDeviation
               minimumAmplitudeRandomness:(AKControl *)minimumAmplitudeRandomness
               maximumAmplitudeRandomness:(AKControl *)maximumAmplitudeRandomness
                                    phase:(AKConstant *)phase;

/// Instantiates the vibrato with default values
- (instancetype)init;

/// Instantiates the vibrato with default values
+ (instancetype)control;


/// Vibrato table. It normally contains a sine or a triangle wave. [Default Value: sine]
@property AKFTable *vibratoShapeTable;

/// Set an optional vibrato shape table
/// @param vibratoShapeTable Vibrato table. It normally contains a sine or a triangle wave. [Default Value: sine]
- (void)setOptionalVibratoShapeTable:(AKFTable *)vibratoShapeTable;

/// Average frequency value of vibrato in Hz [Default Value: 2]
@property AKControl *averageFrequency;

/// Set an optional average frequency
/// @param averageFrequency Average frequency value of vibrato in Hz [Default Value: 2]
- (void)setOptionalAverageFrequency:(AKControl *)averageFrequency;

/// Amount of random frequency deviation [Default Value: 0]
@property AKControl *frequencyRandomness;

/// Set an optional frequency randomness
/// @param frequencyRandomness Amount of random frequency deviation [Default Value: 0]
- (void)setOptionalFrequencyRandomness:(AKControl *)frequencyRandomness;

/// Minimum frequency of random frequency deviation segments in Hz [Default Value: 0]
@property AKControl *minimumFrequencyRandomness;

/// Set an optional minimum frequency randomness
/// @param minimumFrequencyRandomness Minimum frequency of random frequency deviation segments in Hz [Default Value: 0]
- (void)setOptionalMinimumFrequencyRandomness:(AKControl *)minimumFrequencyRandomness;

/// Maximum frequency of random frequency deviation segments in Hz [Default Value: 60]
@property AKControl *maximumFrequencyRandomness;

/// Set an optional maximum frequency randomness
/// @param maximumFrequencyRandomness Maximum frequency of random frequency deviation segments in Hz [Default Value: 60]
- (void)setOptionalMaximumFrequencyRandomness:(AKControl *)maximumFrequencyRandomness;

/// Average amplitude value of vibrato. [Default Value: 1]
@property AKControl *averageAmplitude;

/// Set an optional average amplitude
/// @param averageAmplitude Average amplitude value of vibrato. [Default Value: 1]
- (void)setOptionalAverageAmplitude:(AKControl *)averageAmplitude;

/// Amount of random amplitude deviation, [Default Value: 0]
@property AKControl *amplitudeDeviation;

/// Set an optional amplitude deviation
/// @param amplitudeDeviation Amount of random amplitude deviation, [Default Value: 0]
- (void)setOptionalAmplitudeDeviation:(AKControl *)amplitudeDeviation;

/// Minimum frequency of random amplitude deviation segments in Hz [Default Value: 0]
@property AKControl *minimumAmplitudeRandomness;

/// Set an optional minimum amplitude randomness
/// @param minimumAmplitudeRandomness Minimum frequency of random amplitude deviation segments in Hz [Default Value: 0]
- (void)setOptionalMinimumAmplitudeRandomness:(AKControl *)minimumAmplitudeRandomness;

/// Maximum frequency of random amplitude deviation segments in Hz [Default Value: 0]
@property AKControl *maximumAmplitudeRandomness;

/// Set an optional maximum amplitude randomness
/// @param maximumAmplitudeRandomness Maximum frequency of random amplitude deviation segments in Hz [Default Value: 0]
- (void)setOptionalMaximumAmplitudeRandomness:(AKControl *)maximumAmplitudeRandomness;

/// Initial phase of table, expressed as a fraction of a cycle (0 to 1). [Default Value: 0]
@property AKConstant *phase;

/// Set an optional phase
/// @param phase Initial phase of table, expressed as a fraction of a cycle (0 to 1). [Default Value: 0]
- (void)setOptionalPhase:(AKConstant *)phase;



@end
