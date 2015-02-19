//
//  AKBambooSticks.h
//  AudioKit
//
//  Auto-generated on 2/18/15.
//  Copyright (c) 2015 Aurelius Prochazka. All rights reserved.
//

#import "AKAudio.h"
#import "AKParameter+Operation.h"

/** Semi-physical model of a bamboo sound.

 This is one of the PhISEM percussion opcodes. PhISEM (Physically Informed Stochastic Event Modeling) is an algorithmic approach for simulating collisions of multiple independent sound producing objects.
 */

@interface AKBambooSticks : AKAudio
/// Instantiates the bamboo sticks with all values
/// @param count The number of bamboo sticks. [Default Value: 2]
/// @param mainResonantFrequency The main resonant frequency. [Default Value: 2800]
/// @param firstResonantFrequency The first resonant frequency. [Default Value: 2240]
/// @param secondResonantFrequency The second resonant frequency. [Default Value: 3360]
/// @param amplitude Amplitude of output. Since these instruments are stochastic this is only an approximation. [Default Value: 1]
- (instancetype)initWithCount:(AKConstant *)count
        mainResonantFrequency:(AKConstant *)mainResonantFrequency
       firstResonantFrequency:(AKConstant *)firstResonantFrequency
      secondResonantFrequency:(AKConstant *)secondResonantFrequency
                    amplitude:(AKConstant *)amplitude;

/// Instantiates the bamboo sticks with default values
- (instancetype)init;

/// Instantiates the bamboo sticks with default values
+ (instancetype)sticks;


/// The number of bamboo sticks. [Default Value: 2]
@property (nonatomic) AKConstant *count;

/// Set an optional count
/// @param count The number of bamboo sticks. [Default Value: 2]
- (void)setOptionalCount:(AKConstant *)count;

/// The main resonant frequency. [Default Value: 2800]
@property (nonatomic) AKConstant *mainResonantFrequency;

/// Set an optional main resonant frequency
/// @param mainResonantFrequency The main resonant frequency. [Default Value: 2800]
- (void)setOptionalMainResonantFrequency:(AKConstant *)mainResonantFrequency;

/// The first resonant frequency. [Default Value: 2240]
@property (nonatomic) AKConstant *firstResonantFrequency;

/// Set an optional first resonant frequency
/// @param firstResonantFrequency The first resonant frequency. [Default Value: 2240]
- (void)setOptionalFirstResonantFrequency:(AKConstant *)firstResonantFrequency;

/// The second resonant frequency. [Default Value: 3360]
@property (nonatomic) AKConstant *secondResonantFrequency;

/// Set an optional second resonant frequency
/// @param secondResonantFrequency The second resonant frequency. [Default Value: 3360]
- (void)setOptionalSecondResonantFrequency:(AKConstant *)secondResonantFrequency;

/// Amplitude of output. Since these instruments are stochastic this is only an approximation. [Default Value: 1]
@property (nonatomic) AKConstant *amplitude;

/// Set an optional amplitude
/// @param amplitude Amplitude of output. Since these instruments are stochastic this is only an approximation. [Default Value: 1]
- (void)setOptionalAmplitude:(AKConstant *)amplitude;



@end
