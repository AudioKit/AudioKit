//
//  AKSleighbells.h
//  AudioKit
//
//  Auto-generated from scripts by Aurelius Prochazka on 11/30/14.
//  Copyright (c) 2014 Hear For Yourself. All rights reserved.
//

#import "AKAudio.h"
#import "AKParameter+Operation.h"

/** Semi-physical model of a sleighbell sound.

 This is one of the PhISEM percussion opcodes. PhISEM (Physically Informed Stochastic Event Modeling) is an algorithmic approach for simulating collisions of multiple independent sound producing objects.
 */

@interface AKSleighbells : AKAudio

/// Instantiates the sleighbells with all values
/// @param intensity The intensity of the bell sound.
/// @param dampingFactor The value ranges from 0 to 1.
/// @param mainResonantFrequency The main resonant frequency.
/// @param firstResonantFrequency The first resonant frequency.
/// @param secondResonantFrequency The second resonant frequency.
- (instancetype)initWithIntensity:(AKConstant *)intensity
                    dampingFactor:(AKConstant *)dampingFactor
            mainResonantFrequency:(AKConstant *)mainResonantFrequency
           firstResonantFrequency:(AKConstant *)firstResonantFrequency
          secondResonantFrequency:(AKConstant *)secondResonantFrequency;

/// Instantiates the sleighbells with default values
- (instancetype)init;


/// Instantiates the sleighbells with default values
+ (instancetype)audio;




/// The intensity of the bell sound. [Default Value: 32]
@property AKConstant *intensity;

/// Set an optional intensity
/// @param intensity The intensity of the bell sound. [Default Value: 32]
- (void)setOptionalIntensity:(AKConstant *)intensity;


/// The value ranges from 0 to 1. [Default Value: 0.25]
@property AKConstant *dampingFactor;

/// Set an optional damping factor
/// @param dampingFactor The value ranges from 0 to 1. [Default Value: 0.25]
- (void)setOptionalDampingFactor:(AKConstant *)dampingFactor;


/// The main resonant frequency. [Default Value: 2500]
@property AKConstant *mainResonantFrequency;

/// Set an optional main resonant frequency
/// @param mainResonantFrequency The main resonant frequency. [Default Value: 2500]
- (void)setOptionalMainResonantFrequency:(AKConstant *)mainResonantFrequency;


/// The first resonant frequency. [Default Value: 5300]
@property AKConstant *firstResonantFrequency;

/// Set an optional first resonant frequency
/// @param firstResonantFrequency The first resonant frequency. [Default Value: 5300]
- (void)setOptionalFirstResonantFrequency:(AKConstant *)firstResonantFrequency;


/// The second resonant frequency. [Default Value: 6500]
@property AKConstant *secondResonantFrequency;

/// Set an optional second resonant frequency
/// @param secondResonantFrequency The second resonant frequency. [Default Value: 6500]
- (void)setOptionalSecondResonantFrequency:(AKConstant *)secondResonantFrequency;


@end
