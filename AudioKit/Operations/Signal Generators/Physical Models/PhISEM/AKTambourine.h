//
//  AKTambourine.h
//  AudioKit
//
//  Auto-generated from scripts by Aurelius Prochazka on 11/30/14.
//  Copyright (c) 2014 Hear For Yourself. All rights reserved.
//

#import "AKAudio.h"
#import "AKParameter+Operation.h"

/** Semi-physical model of a tambourine sound.

 This is one of the PhISEM percussion opcodes. PhISEM (Physically Informed Stochastic Event Modeling) is an algorithmic approach for simulating collisions of multiple independent sound producing objects.
 */

@interface AKTambourine : AKAudio

/// Instantiates the tambourine with all values
/// @param intensity The intensity of the tambourine sound
/// @param dampingFactor This value ranges from 0 to 1, but seems to be most stable between 0 and .7
/// @param mainResonantFrequency The main resonant frequency.
/// @param firstResonantFrequency The first resonant frequency.
/// @param secondResonantFrequency The second resonant frequency.
- (instancetype)initWithIntensity:(AKConstant *)intensity
                    dampingFactor:(AKConstant *)dampingFactor
            mainResonantFrequency:(AKConstant *)mainResonantFrequency
           firstResonantFrequency:(AKConstant *)firstResonantFrequency
          secondResonantFrequency:(AKConstant *)secondResonantFrequency;

/// Instantiates the tambourine with default values
- (instancetype)init;


/// Instantiates the tambourine with default values
+ (instancetype)audio;




/// The intensity of the tambourine sound [Default Value: 1000]
@property AKConstant *intensity;

/// Set an optional intensity
/// @param intensity The intensity of the tambourine sound [Default Value: 1000]
- (void)setOptionalIntensity:(AKConstant *)intensity;


/// This value ranges from 0 to 1, but seems to be most stable between 0 and .7 [Default Value: 0.7]
@property AKConstant *dampingFactor;

/// Set an optional damping factor
/// @param dampingFactor This value ranges from 0 to 1, but seems to be most stable between 0 and .7 [Default Value: 0.7]
- (void)setOptionalDampingFactor:(AKConstant *)dampingFactor;


/// The main resonant frequency. [Default Value: 2300]
@property AKConstant *mainResonantFrequency;

/// Set an optional main resonant frequency
/// @param mainResonantFrequency The main resonant frequency. [Default Value: 2300]
- (void)setOptionalMainResonantFrequency:(AKConstant *)mainResonantFrequency;


/// The first resonant frequency. [Default Value: 5600]
@property AKConstant *firstResonantFrequency;

/// Set an optional first resonant frequency
/// @param firstResonantFrequency The first resonant frequency. [Default Value: 5600]
- (void)setOptionalFirstResonantFrequency:(AKConstant *)firstResonantFrequency;


/// The second resonant frequency. [Default Value: 8100]
@property AKConstant *secondResonantFrequency;

/// Set an optional second resonant frequency
/// @param secondResonantFrequency The second resonant frequency. [Default Value: 8100]
- (void)setOptionalSecondResonantFrequency:(AKConstant *)secondResonantFrequency;


@end
