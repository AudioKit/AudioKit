//
//  AKCabasa.h
//  AudioKit
//
//  Auto-generated from scripts by Aurelius Prochazka on 11/26/14.
//  Copyright (c) 2014 Hear For Yourself. All rights reserved.
//

#import "AKAudio.h"
#import "AKParameter+Operation.h"

/** Semi-physical model of a cabasa sound.
 
 This one of the PhISEM percussion opcodes. PhISEM (Physically Informed Stochastic Event Modeling) is an algorithmic approach for simulating collisions of multiple independent sound producing objects.
 */

@interface AKCabasa : AKAudio

/// Instantiates the cabasa with all values
/// @param count The number of beads, teeth, bells, timbrels, etc.
/// @param dampingFactor Damping factor where 0 is full damped and 1 is no damping.
- (instancetype)initWithCount:(AKConstant *)count
                dampingFactor:(AKConstant *)dampingFactor;

/// Instantiates the cabasa with default values
- (instancetype)init;


/// Instantiates the cabasa with default values
+ (instancetype)audio;




/// The number of beads, teeth, bells, timbrels, etc. [Default Value: 100]
@property AKConstant *count;

/// Set an optional count
/// @param count The number of beads, teeth, bells, timbrels, etc. [Default Value: 100]
- (void)setOptionalCount:(AKConstant *)count;


/// Damping factor where 0 is full damped and 1 is no damping. [Default Value: 0.93]
@property AKConstant *dampingFactor;

/// Set an optional damping factor
/// @param dampingFactor Damping factor where 0 is full damped and 1 is no damping. [Default Value: 0.93]
- (void)setOptionalDampingFactor:(AKConstant *)dampingFactor;


@end
