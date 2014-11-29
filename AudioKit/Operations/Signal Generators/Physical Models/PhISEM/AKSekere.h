//
//  AKSekere.h
//  AudioKit
//
//  Auto-generated from scripts by Aurelius Prochazka on 11/28/14.
//  Copyright (c) 2014 Hear For Yourself. All rights reserved.
//

#import "AKAudio.h"
#import "AKParameter+Operation.h"

/** Semi-physical model of a sekere sound.
 
 This is one of the PhISEM percussion opcodes. PhISEM (Physically Informed Stochastic Event Modeling) is an algorithmic approach for simulating collisions of multiple independent sound producing objects.
 */

@interface AKSekere : AKAudio

/// Instantiates the sekere with all values
/// @param count The number of beads, teeth, bells, timbrels, etc. If zero, the default value is 64.
/// @param dampingFactor Damping factor where 0 is full damped and 1 is no damping.
- (instancetype)initWithCount:(AKConstant *)count
                dampingFactor:(AKConstant *)dampingFactor;

/// Instantiates the sekere with default values
- (instancetype)init;


/// Instantiates the sekere with default values
+ (instancetype)audio;




/// The number of beads, teeth, bells, timbrels, etc. If zero, the default value is 64. [Default Value: 64]
@property AKConstant *count;

/// Set an optional count
/// @param count The number of beads, teeth, bells, timbrels, etc. If zero, the default value is 64. [Default Value: 64]
- (void)setOptionalCount:(AKConstant *)count;


/// Damping factor where 0 is full damped and 1 is no damping. [Default Value: 0.9]
@property AKConstant *dampingFactor;

/// Set an optional damping factor
/// @param dampingFactor Damping factor where 0 is full damped and 1 is no damping. [Default Value: 0.9]
- (void)setOptionalDampingFactor:(AKConstant *)dampingFactor;


@end
