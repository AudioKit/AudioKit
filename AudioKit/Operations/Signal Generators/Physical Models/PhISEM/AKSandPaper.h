//
//  AKSandPaper.h
//  AudioKit
//
//  Auto-generated on 2/19/15.
//  Copyright (c) 2015 Aurelius Prochazka. All rights reserved.
//

#import "AKAudio.h"
#import "AKParameter+Operation.h"

/** Semi-physical model of a sandpaper sound.

 This is one of the PhISEM percussion opcodes. PhISEM (Physically Informed Stochastic Event Modeling) is an algorithmic approach for simulating collisions of multiple independent sound producing objects.
 */

NS_ASSUME_NONNULL_BEGIN
@interface AKSandPaper : AKAudio
/// Instantiates the sand paper with all values
/// @param intensity The intensity of the sandpaper sound [Default Value: 128]
/// @param dampingFactor Damping factor where 0 is no damping and 1 is fully damped. [Default Value: 0.1]
- (instancetype)initWithIntensity:(AKConstant *)intensity
                    dampingFactor:(AKConstant *)dampingFactor;

/// Instantiates the sand paper with default values
- (instancetype)init;

/// Instantiates the sand paper with default values
+ (instancetype)sandPaper;

/// Instantiates the sand paper with default values
+ (instancetype)presetDefaultSandPaper;

/// Instantiates the sand paper with values for a muffled sound
- (instancetype)initWithPresetMuffledSandPaper;

/// Instantiates the sand paper with values for a muffled sound
+ (instancetype)presetMuffledSandPaper;

/// The intensity of the sandpaper sound [Default Value: 128]
@property (nonatomic) AKConstant *intensity;

/// Set an optional intensity
/// @param intensity The intensity of the sandpaper sound [Default Value: 128]
- (void)setOptionalIntensity:(AKConstant *)intensity;

/// Damping factor where 0 is no damping and 1 is fully damped. [Default Value: 0.1]
@property (nonatomic) AKConstant *dampingFactor;

/// Set an optional damping factor
/// @param dampingFactor Damping factor where 0 is no damping and 1 is fully damped. [Default Value: 0.1]
- (void)setOptionalDampingFactor:(AKConstant *)dampingFactor;



@end
NS_ASSUME_NONNULL_END
