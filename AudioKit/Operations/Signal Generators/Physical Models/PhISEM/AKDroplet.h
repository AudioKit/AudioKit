//
//  AKDroplet.h
//  AudioKit
//
//  Auto-generated on 2/18/15.
//  Copyright (c) 2015 Aurelius Prochazka. All rights reserved.
//

#import "AKAudio.h"
#import "AKParameter+Operation.h"

/** Semi-physical model of a water drop.

 This is one of the PhISEM percussion opcodes. PhISEM (Physically Informed Stochastic Event Modeling) is an algorithmic approach for simulating collisions of multiple independent sound producing objects.
 */

NS_ASSUME_NONNULL_BEGIN
@interface AKDroplet : AKAudio
/// Instantiates the droplet with all values
/// @param intensity The intensity of the dripping sound. [Default Value: 10]
/// @param dampingFactor Damping factor where 0 is no damping and 1 is fully damped. [Default Value: 0.1]
/// @param energyReturn Amount of energy to add back into the system. The value should be in range 0 to 1. [Default Value: 0.5]
/// @param mainResonantFrequency The main resonant frequency. [Default Value: 450]
/// @param firstResonantFrequency The first resonant frequency. [Default Value: 600]
/// @param secondResonantFrequency The second resonant frequency. [Default Value: 750]
/// @param amplitude Amplitude of output. Since these instruments are stochastic this is only an approximation. Updated at Control-rate. [Default Value: 1]
- (instancetype)initWithIntensity:(AKConstant *)intensity
                    dampingFactor:(AKConstant *)dampingFactor
                     energyReturn:(AKConstant *)energyReturn
            mainResonantFrequency:(AKConstant *)mainResonantFrequency
           firstResonantFrequency:(AKConstant *)firstResonantFrequency
          secondResonantFrequency:(AKConstant *)secondResonantFrequency
                        amplitude:(AKParameter *)amplitude;

/// Instantiates the droplet with default values
- (instancetype)init;

/// Instantiates the droplet with default values
+ (instancetype)droplet;


/// The intensity of the dripping sound. [Default Value: 10]
@property (nonatomic) AKConstant *intensity;

/// Set an optional intensity
/// @param intensity The intensity of the dripping sound. [Default Value: 10]
- (void)setOptionalIntensity:(AKConstant *)intensity;

/// Damping factor where 0 is no damping and 1 is fully damped. [Default Value: 0.1]
@property (nonatomic) AKConstant *dampingFactor;

/// Set an optional damping factor
/// @param dampingFactor Damping factor where 0 is no damping and 1 is fully damped. [Default Value: 0.1]
- (void)setOptionalDampingFactor:(AKConstant *)dampingFactor;

/// Amount of energy to add back into the system. The value should be in range 0 to 1. [Default Value: 0.5]
@property (nonatomic) AKConstant *energyReturn;

/// Set an optional energy return
/// @param energyReturn Amount of energy to add back into the system. The value should be in range 0 to 1. [Default Value: 0.5]
- (void)setOptionalEnergyReturn:(AKConstant *)energyReturn;

/// The main resonant frequency. [Default Value: 450]
@property (nonatomic) AKConstant *mainResonantFrequency;

/// Set an optional main resonant frequency
/// @param mainResonantFrequency The main resonant frequency. [Default Value: 450]
- (void)setOptionalMainResonantFrequency:(AKConstant *)mainResonantFrequency;

/// The first resonant frequency. [Default Value: 600]
@property (nonatomic) AKConstant *firstResonantFrequency;

/// Set an optional first resonant frequency
/// @param firstResonantFrequency The first resonant frequency. [Default Value: 600]
- (void)setOptionalFirstResonantFrequency:(AKConstant *)firstResonantFrequency;

/// The second resonant frequency. [Default Value: 750]
@property (nonatomic) AKConstant *secondResonantFrequency;

/// Set an optional second resonant frequency
/// @param secondResonantFrequency The second resonant frequency. [Default Value: 750]
- (void)setOptionalSecondResonantFrequency:(AKConstant *)secondResonantFrequency;

/// Amplitude of output. Since these instruments are stochastic this is only an approximation. [Default Value: 1]
@property (nonatomic) AKParameter *amplitude;

/// Set an optional amplitude
/// @param amplitude Amplitude of output. Since these instruments are stochastic this is only an approximation. Updated at Control-rate. [Default Value: 1]
- (void)setOptionalAmplitude:(AKParameter *)amplitude;



@end
NS_ASSUME_NONNULL_END
