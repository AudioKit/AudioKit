//
//  AKCabasa.h
//  AudioKit
//
//  Auto-generated on 12/15/14.
//  Copyright (c) 2014 Aurelius Prochazka. All rights reserved.
//

#import "AKAudio.h"
#import "AKParameter+Operation.h"

/** Semi-physical model of a cabasa sound.

 This one of the PhISEM percussion opcodes. PhISEM (Physically Informed Stochastic Event Modeling) is an algorithmic approach for simulating collisions of multiple independent sound producing objects.
 */

@interface AKCabasa : AKAudio
/// Instantiates the cabasa with all values
/// @param count The number of beads, teeth, bells, timbrels, etc. [Default Value: 100]
/// @param dampingFactor Damping factor where 0 is no damping and 1 is fully damped. [Default Value: 0.14]
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
/// Damping factor where 0 is no damping and 1 is fully damped. [Default Value: 0.14]
@property AKConstant *dampingFactor;

/// Set an optional damping factor
/// @param dampingFactor Damping factor where 0 is no damping and 1 is fully damped. [Default Value: 0.14]
- (void)setOptionalDampingFactor:(AKConstant *)dampingFactor;



@end
