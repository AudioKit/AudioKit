//
//  AKCabasa.h
//  AudioKit
//
//  Auto-generated on 2/18/15.
//  Copyright (c) 2015 Aurelius Prochazka. All rights reserved.
//

#import "AKAudio.h"
#import "AKParameter+Operation.h"

/** Semi-physical model of a cabasa sound.

 This one of the PhISEM percussion opcodes. PhISEM (Physically Informed Stochastic Event Modeling) is an algorithmic approach for simulating collisions of multiple independent sound producing objects.
 */

NS_ASSUME_NONNULL_BEGIN
@interface AKCabasa : AKAudio
/// Instantiates the cabasa with all values
/// @param count The number of beads, teeth, bells, timbrels, etc. [Default Value: 100]
/// @param dampingFactor Damping factor where 0 is no damping and 1 is fully damped. [Default Value: 0.14]
/// @param amplitude Amplitude of output. As these instruments are stochastic this is only a approximation. [Default Value: 1]
- (instancetype)initWithCount:(AKConstant *)count
                dampingFactor:(AKConstant *)dampingFactor
                    amplitude:(AKConstant *)amplitude;

/// Instantiates the cabasa with default values
- (instancetype)init;

/// Instantiates the cabasa with default values
+ (instancetype)cabasa;

/// Instantiates the cabasa with default values
+ (instancetype)presetDefaultCabasa;

/// Instantiates the cabasa with muted values
- (instancetype)initWithPresetMutedCabasa;

/// Instantiates the cabasa with loose values
+ (instancetype)presetMutedCabasa;

/// Instantiates the cabasa with loose values
- (instancetype)initWithPresetLooseCabasa;

/// Instantiates the cabasa with muted values
+ (instancetype)presetLooseCabasa;

/// The number of beads, teeth, bells, timbrels, etc. [Default Value: 100]
@property (nonatomic) AKConstant *count;

/// Set an optional count
/// @param count The number of beads, teeth, bells, timbrels, etc. [Default Value: 100]
- (void)setOptionalCount:(AKConstant *)count;

/// Damping factor where 0 is no damping and 1 is fully damped. [Default Value: 0.14]
@property (nonatomic) AKConstant *dampingFactor;

/// Set an optional damping factor
/// @param dampingFactor Damping factor where 0 is no damping and 1 is fully damped. [Default Value: 0.14]
- (void)setOptionalDampingFactor:(AKConstant *)dampingFactor;

/// Amplitude of output. As these instruments are stochastic this is only a approximation. [Default Value: 1]
@property (nonatomic) AKConstant *amplitude;

/// Set an optional amplitude
/// @param amplitude Amplitude of output. As these instruments are stochastic this is only a approximation. [Default Value: 1]
- (void)setOptionalAmplitude:(AKConstant *)amplitude;



@end
NS_ASSUME_NONNULL_END
