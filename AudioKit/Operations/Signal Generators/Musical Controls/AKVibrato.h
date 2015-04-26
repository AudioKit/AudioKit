//
//  AKVibrato.h
//  AudioKit
//
//  Auto-generated on 3/2/15.
//  Copyright (c) 2015 Aurelius Prochazka. All rights reserved.
//

#import "AKControl.h"
#import "AKParameter+Operation.h"

/** Generates a natural-sounding user-controllable vibrato.

 AKVibrato outputs a natural-sounding user-controllable vibrato. The concept is to randomly vary both frequency and amplitude of the oscillator generating the vibrato, in order to simulate the irregularities of a real vibrato. In order to have a total control of these random variations, several input arguments are present. Random variations are obtained by two separated segmented lines, the first controlling frequency deviations, the second the amplitude deviations. Average duration of each segment of each line can be shortened or enlarged by the minimum and maximum randomness arguments, and the deviation from the average amplitude and frequency values can be independently adjusted by means of randomness arguments.
 */

NS_ASSUME_NONNULL_BEGIN
@interface AKVibrato : AKControl
/// Instantiates the vibrato with all values
/// @param shape Vibrato shape table. It normally contains a sine or a triangle wave. [Default Value: sine]
/// @param averageFrequency Average frequency value of vibrato in Hz Updated at Control-rate. [Default Value: 2]
/// @param frequencyRandomness Amount of random frequency deviation Updated at Control-rate. [Default Value: 0]
/// @param minimumFrequencyRandomness Minimum frequency of random frequency deviation segments in Hz Updated at Control-rate. [Default Value: 0]
/// @param maximumFrequencyRandomness Maximum frequency of random frequency deviation segments in Hz Updated at Control-rate. [Default Value: 60]
/// @param averageAmplitude Average amplitude value of vibrato. Updated at Control-rate. [Default Value: 1]
/// @param amplitudeDeviation Amount of random amplitude deviation, Updated at Control-rate. [Default Value: 0]
/// @param minimumAmplitudeRandomness Minimum frequency of random amplitude deviation segments in Hz Updated at Control-rate. [Default Value: 0]
/// @param maximumAmplitudeRandomness Maximum frequency of random amplitude deviation segments in Hz Updated at Control-rate. [Default Value: 0]
/// @param phase Initial phase of table, expressed as a fraction of a cycle (0 to 1). [Default Value: 0]
- (instancetype)initWithShape:(AKTable *)shape
             averageFrequency:(AKParameter *)averageFrequency
          frequencyRandomness:(AKParameter *)frequencyRandomness
   minimumFrequencyRandomness:(AKParameter *)minimumFrequencyRandomness
   maximumFrequencyRandomness:(AKParameter *)maximumFrequencyRandomness
             averageAmplitude:(AKParameter *)averageAmplitude
           amplitudeDeviation:(AKParameter *)amplitudeDeviation
   minimumAmplitudeRandomness:(AKParameter *)minimumAmplitudeRandomness
   maximumAmplitudeRandomness:(AKParameter *)maximumAmplitudeRandomness
                        phase:(AKConstant *)phase;

/// Instantiates the vibrato with default values
- (instancetype)init;

/// Instantiates the vibrato with default values
+ (instancetype)vibrato;


/// Vibrato shape table. It normally contains a sine or a triangle wave. [Default Value: sine]
@property (nonatomic) AKTable *shape;

/// Set an optional shape
/// @param shape Vibrato shape table. It normally contains a sine or a triangle wave. [Default Value: sine]
- (void)setOptionalShape:(AKTable *)shape;

/// Average frequency value of vibrato in Hz [Default Value: 2]
@property (nonatomic) AKParameter *averageFrequency;

/// Set an optional average frequency
/// @param averageFrequency Average frequency value of vibrato in Hz Updated at Control-rate. [Default Value: 2]
- (void)setOptionalAverageFrequency:(AKParameter *)averageFrequency;

/// Amount of random frequency deviation [Default Value: 0]
@property (nonatomic) AKParameter *frequencyRandomness;

/// Set an optional frequency randomness
/// @param frequencyRandomness Amount of random frequency deviation Updated at Control-rate. [Default Value: 0]
- (void)setOptionalFrequencyRandomness:(AKParameter *)frequencyRandomness;

/// Minimum frequency of random frequency deviation segments in Hz [Default Value: 0]
@property (nonatomic) AKParameter *minimumFrequencyRandomness;

/// Set an optional minimum frequency randomness
/// @param minimumFrequencyRandomness Minimum frequency of random frequency deviation segments in Hz Updated at Control-rate. [Default Value: 0]
- (void)setOptionalMinimumFrequencyRandomness:(AKParameter *)minimumFrequencyRandomness;

/// Maximum frequency of random frequency deviation segments in Hz [Default Value: 60]
@property (nonatomic) AKParameter *maximumFrequencyRandomness;

/// Set an optional maximum frequency randomness
/// @param maximumFrequencyRandomness Maximum frequency of random frequency deviation segments in Hz Updated at Control-rate. [Default Value: 60]
- (void)setOptionalMaximumFrequencyRandomness:(AKParameter *)maximumFrequencyRandomness;

/// Average amplitude value of vibrato. [Default Value: 1]
@property (nonatomic) AKParameter *averageAmplitude;

/// Set an optional average amplitude
/// @param averageAmplitude Average amplitude value of vibrato. Updated at Control-rate. [Default Value: 1]
- (void)setOptionalAverageAmplitude:(AKParameter *)averageAmplitude;

/// Amount of random amplitude deviation, [Default Value: 0]
@property (nonatomic) AKParameter *amplitudeDeviation;

/// Set an optional amplitude deviation
/// @param amplitudeDeviation Amount of random amplitude deviation, Updated at Control-rate. [Default Value: 0]
- (void)setOptionalAmplitudeDeviation:(AKParameter *)amplitudeDeviation;

/// Minimum frequency of random amplitude deviation segments in Hz [Default Value: 0]
@property (nonatomic) AKParameter *minimumAmplitudeRandomness;

/// Set an optional minimum amplitude randomness
/// @param minimumAmplitudeRandomness Minimum frequency of random amplitude deviation segments in Hz Updated at Control-rate. [Default Value: 0]
- (void)setOptionalMinimumAmplitudeRandomness:(AKParameter *)minimumAmplitudeRandomness;

/// Maximum frequency of random amplitude deviation segments in Hz [Default Value: 0]
@property (nonatomic) AKParameter *maximumAmplitudeRandomness;

/// Set an optional maximum amplitude randomness
/// @param maximumAmplitudeRandomness Maximum frequency of random amplitude deviation segments in Hz Updated at Control-rate. [Default Value: 0]
- (void)setOptionalMaximumAmplitudeRandomness:(AKParameter *)maximumAmplitudeRandomness;

/// Initial phase of table, expressed as a fraction of a cycle (0 to 1). [Default Value: 0]
@property (nonatomic) AKConstant *phase;

/// Set an optional phase
/// @param phase Initial phase of table, expressed as a fraction of a cycle (0 to 1). [Default Value: 0]
- (void)setOptionalPhase:(AKConstant *)phase;



@end
NS_ASSUME_NONNULL_END
