//
//  AKSekere.h
//  AudioKit
//
//  Auto-generated on 2/19/15.
//  Copyright (c) 2015 Aurelius Prochazka. All rights reserved.
//

#import "AKAudio.h"
#import "AKParameter+Operation.h"

/** Semi-physical model of a sekere sound.

 This is one of the PhISEM percussion opcodes. PhISEM (Physically Informed Stochastic Event Modeling) is an algorithmic approach for simulating collisions of multiple independent sound producing objects.
 */

NS_ASSUME_NONNULL_BEGIN
@interface AKSekere : AKAudio
/// Instantiates the sekere with all values
/// @param count The number of beads, teeth, bells, timbrels, etc. If zero, the default value is 64. [Default Value: 64]
/// @param dampingFactor Damping factor where 0 is no damping and 1 is fully damped. [Default Value: 0.1]
/// @param amplitude Amplitude of output. Note: As these instruments are stochastic, this is only a approximation. [Default Value: 1]
- (instancetype)initWithCount:(AKConstant *)count
                dampingFactor:(AKConstant *)dampingFactor
                    amplitude:(AKConstant *)amplitude;

/// Instantiates the sekere with default values
- (instancetype)init;

/// Instantiates the sekere with default values
+ (instancetype)sekere;

/// Instantiates the sekere with default values
+ (instancetype)presetDefaultSekere;

/// Instantiates the sekere with large number of beads
- (instancetype)initWithPresetManyBeadsSekere;

/// Instantiates the sekere with large number of beads
+ (instancetype)presetManyBeadsSekere;

/// The number of beads, teeth, bells, timbrels, etc. If zero, the default value is 64. [Default Value: 64]
@property (nonatomic) AKConstant *count;

/// Set an optional count
/// @param count The number of beads, teeth, bells, timbrels, etc. If zero, the default value is 64. [Default Value: 64]
- (void)setOptionalCount:(AKConstant *)count;

/// Damping factor where 0 is no damping and 1 is fully damped. [Default Value: 0.1]
@property (nonatomic) AKConstant *dampingFactor;

/// Set an optional damping factor
/// @param dampingFactor Damping factor where 0 is no damping and 1 is fully damped. [Default Value: 0.1]
- (void)setOptionalDampingFactor:(AKConstant *)dampingFactor;

/// Amplitude of output. Note: As these instruments are stochastic, this is only a approximation. [Default Value: 1]
@property (nonatomic) AKConstant *amplitude;

/// Set an optional amplitude
/// @param amplitude Amplitude of output. Note: As these instruments are stochastic, this is only a approximation. [Default Value: 1]
- (void)setOptionalAmplitude:(AKConstant *)amplitude;



@end
NS_ASSUME_NONNULL_END
