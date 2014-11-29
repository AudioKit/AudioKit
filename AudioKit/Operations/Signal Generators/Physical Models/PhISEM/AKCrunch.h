//
//  AKCrunch.h
//  AudioKit
//
//  Auto-generated from scripts by Aurelius Prochazka on 11/29/14.
//  Copyright (c) 2014 Hear For Yourself. All rights reserved.
//

#import "AKAudio.h"
#import "AKParameter+Operation.h"

/** Semi-physical model of a crunch sound.
 
 This one of the PhISEM percussion opcodes. PhISEM (Physically Informed Stochastic Event Modeling) is an algorithmic approach for simulating collisions of multiple independent sound producing objects.
 */

@interface AKCrunch : AKAudio

/// Instantiates the crunch with all values
/// @param intensity The intensity of the crunch sound
/// @param dampingFactor This value ranges from 0 to 1, and is best with numbers around 0.9.
- (instancetype)initWithIntensity:(AKConstant *)intensity
                    dampingFactor:(AKConstant *)dampingFactor;

/// Instantiates the crunch with default values
- (instancetype)init;


/// Instantiates the crunch with default values
+ (instancetype)audio;




/// The intensity of the crunch sound [Default Value: 100]
@property AKConstant *intensity;

/// Set an optional intensity
/// @param intensity The intensity of the crunch sound [Default Value: 100]
- (void)setOptionalIntensity:(AKConstant *)intensity;


/// This value ranges from 0 to 1, and is best with numbers around 0.9. [Default Value: 0.9]
@property AKConstant *dampingFactor;

/// Set an optional damping factor
/// @param dampingFactor This value ranges from 0 to 1, and is best with numbers around 0.9. [Default Value: 0.9]
- (void)setOptionalDampingFactor:(AKConstant *)dampingFactor;


@end
