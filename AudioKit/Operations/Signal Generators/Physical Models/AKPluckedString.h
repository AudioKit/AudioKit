//
//  AKPluckedString.h
//  AudioKit
//
//  Auto-generated on 11/28/14.
//  Copyright (c) 2014 Aurelius Prochazka. All rights reserved.
//

#import "AKAudio.h"
#import "AKParameter+Operation.h"

/** Physical model of the plucked string.
 
 A user can control the pluck point, the pickup point, the filter, and an additional audio signal used to excite the 'string'. Based on the Karplus-Strong algorithm.
 */

@interface AKPluckedString : AKAudio

/// Instantiates the plucked string with all values
/// @param excitationSignal A signal which excites the string.
/// @param frequency Frequency of the string
/// @param pluckPosition  The point of pluck as a fraction of the way up the string (0 to 1). A pluck point of zero means no initial pluck.
/// @param samplePosition  Proportion of the way along the string to sample the output.
/// @param reflectionCoefficient The coefficient of reflection, indicating the lossiness and the rate of decay. It must be strictly between 0 and 1 (it will complain about both 0 and 1).
/// @param amplitude Amplitude of note.
- (instancetype)initWithExcitationSignal:(AKAudio *)excitationSignal
                               frequency:(AKConstant *)frequency
                           pluckPosition:(AKConstant *)pluckPosition
                          samplePosition:(AKControl *)samplePosition
                   reflectionCoefficient:(AKControl *)reflectionCoefficient
                               amplitude:(AKControl *)amplitude;

/// Instantiates the plucked string with default values
/// @param excitationSignal A signal which excites the string.
- (instancetype)initWithExcitationSignal:(AKAudio *)excitationSignal;


/// Instantiates the plucked string with default values
/// @param excitationSignal A signal which excites the string.
+ (instancetype)audioWithExcitationSignal:(AKAudio *)excitationSignal;




/// Frequency of the string [Default Value: 440]
@property AKConstant *frequency;

/// Set an optional frequency
/// @param frequency Frequency of the string [Default Value: 440]
- (void)setOptionalFrequency:(AKConstant *)frequency;


///  The point of pluck as a fraction of the way up the string (0 to 1). A pluck point of zero means no initial pluck. [Default Value: 0.01]
@property AKConstant *pluckPosition;

/// Set an optional pluck position
/// @param pluckPosition  The point of pluck as a fraction of the way up the string (0 to 1). A pluck point of zero means no initial pluck. [Default Value: 0.01]
- (void)setOptionalPluckPosition:(AKConstant *)pluckPosition;


///  Proportion of the way along the string to sample the output. [Default Value: 0.1]
@property AKControl *samplePosition;

/// Set an optional sample position
/// @param samplePosition  Proportion of the way along the string to sample the output. [Default Value: 0.1]
- (void)setOptionalSamplePosition:(AKControl *)samplePosition;


/// The coefficient of reflection, indicating the lossiness and the rate of decay. It must be strictly between 0 and 1 (it will complain about both 0 and 1). [Default Value: 0.1]
@property AKControl *reflectionCoefficient;

/// Set an optional reflection coefficient
/// @param reflectionCoefficient The coefficient of reflection, indicating the lossiness and the rate of decay. It must be strictly between 0 and 1 (it will complain about both 0 and 1). [Default Value: 0.1]
- (void)setOptionalReflectionCoefficient:(AKControl *)reflectionCoefficient;


/// Amplitude of note. [Default Value: 1.0]
@property AKControl *amplitude;

/// Set an optional amplitude
/// @param amplitude Amplitude of note. [Default Value: 1.0]
- (void)setOptionalAmplitude:(AKControl *)amplitude;


@end
