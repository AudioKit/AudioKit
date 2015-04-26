//
//  AKTambourine.h
//  AudioKit
//
//  Auto-generated on 2/19/15.
//  Copyright (c) 2015 Aurelius Prochazka. All rights reserved.
//

#import "AKAudio.h"
#import "AKParameter+Operation.h"

/** Semi-physical model of a tambourine sound.

 This is one of the PhISEM percussion opcodes. PhISEM (Physically Informed Stochastic Event Modeling) is an algorithmic approach for simulating collisions of multiple independent sound producing objects.
 */

NS_ASSUME_NONNULL_BEGIN
@interface AKTambourine : AKAudio
/// Instantiates the tambourine with all values
/// @param intensity The intensity of the tambourine sound [Default Value: 1000]
/// @param dampingFactor Damping factor where 0 is no damping and 1 is fully damped. [Default Value: 0.1]
/// @param mainResonantFrequency The main resonant frequency. [Default Value: 2300]
/// @param firstResonantFrequency The first resonant frequency. [Default Value: 5600]
/// @param secondResonantFrequency The second resonant frequency. [Default Value: 8100]
/// @param amplitude Amplitude of output. Since these instruments are stochastic this is only an approximation. [Default Value: 1]
- (instancetype)initWithIntensity:(AKConstant *)intensity
                    dampingFactor:(AKConstant *)dampingFactor
            mainResonantFrequency:(AKConstant *)mainResonantFrequency
           firstResonantFrequency:(AKConstant *)firstResonantFrequency
          secondResonantFrequency:(AKConstant *)secondResonantFrequency
                        amplitude:(AKConstant *)amplitude;

/// Instantiates the tambourine with default values
- (instancetype)init;

/// Instantiates the tambourine with default values
+ (instancetype)tambourine;

/// Instantiates the tambourine with default values
+ (instancetype)presetDefaultTambourine;

/// Instantiates the tambourine with values for an 'open' sound values
- (instancetype)initWithPresetOpenTambourine;

/// Instantiates the tambourine with default for an 'open' sound values
+ (instancetype)presetOpenTambourine;

/// Instantiates the tambourine with values for an 'closed' sound values
- (instancetype)initWithPresetClosedTambourine;

/// Instantiates the tambourine with default for an 'closed' sound values
+ (instancetype)presetClosedTambourine;

/// The intensity of the tambourine sound [Default Value: 1000]
@property (nonatomic) AKConstant *intensity;

/// Set an optional intensity
/// @param intensity The intensity of the tambourine sound [Default Value: 1000]
- (void)setOptionalIntensity:(AKConstant *)intensity;

/// Damping factor where 0 is no damping and 1 is fully damped. [Default Value: 0.1]
@property (nonatomic) AKConstant *dampingFactor;

/// Set an optional damping factor
/// @param dampingFactor Damping factor where 0 is no damping and 1 is fully damped. [Default Value: 0.1]
- (void)setOptionalDampingFactor:(AKConstant *)dampingFactor;

/// The main resonant frequency. [Default Value: 2300]
@property (nonatomic) AKConstant *mainResonantFrequency;

/// Set an optional main resonant frequency
/// @param mainResonantFrequency The main resonant frequency. [Default Value: 2300]
- (void)setOptionalMainResonantFrequency:(AKConstant *)mainResonantFrequency;

/// The first resonant frequency. [Default Value: 5600]
@property (nonatomic) AKConstant *firstResonantFrequency;

/// Set an optional first resonant frequency
/// @param firstResonantFrequency The first resonant frequency. [Default Value: 5600]
- (void)setOptionalFirstResonantFrequency:(AKConstant *)firstResonantFrequency;

/// The second resonant frequency. [Default Value: 8100]
@property (nonatomic) AKConstant *secondResonantFrequency;

/// Set an optional second resonant frequency
/// @param secondResonantFrequency The second resonant frequency. [Default Value: 8100]
- (void)setOptionalSecondResonantFrequency:(AKConstant *)secondResonantFrequency;

/// Amplitude of output. Since these instruments are stochastic this is only an approximation. [Default Value: 1]
@property (nonatomic) AKConstant *amplitude;

/// Set an optional amplitude
/// @param amplitude Amplitude of output. Since these instruments are stochastic this is only an approximation. [Default Value: 1]
- (void)setOptionalAmplitude:(AKConstant *)amplitude;



@end
NS_ASSUME_NONNULL_END
