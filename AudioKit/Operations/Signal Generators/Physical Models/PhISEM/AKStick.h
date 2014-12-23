//
//  AKStick.h
//  AudioKit
//
//  Auto-generated on 12/15/14.
//  Copyright (c) 2014 Aurelius Prochazka. All rights reserved.
//

#import "AKAudio.h"
#import "AKParameter+Operation.h"

/** Semi-physical model of a stick sound.

 This one of the PhISEM percussion opcodes. PhISEM (Physically Informed Stochastic Event Modeling) is an algorithmic approach for simulating collisions of multiple independent sound producing objects.
 */

@interface AKStick : AKAudio
/// Instantiates the stick with all values
/// @param intensity The intensity of the stick sound. [Default Value: 30]
/// @param dampingFactor This value ranges from 0 to 1, but seems to be most stable at values under 1. [Default Value: 0.3]
- (instancetype)initWithIntensity:(AKConstant *)intensity
                    dampingFactor:(AKConstant *)dampingFactor;

/// Instantiates the stick with default values
- (instancetype)init;

/// Instantiates the stick with default values
+ (instancetype)audio;

/// The intensity of the stick sound. [Default Value: 30]
@property AKConstant *intensity;

/// Set an optional intensity
/// @param intensity The intensity of the stick sound. [Default Value: 30]
- (void)setOptionalIntensity:(AKConstant *)intensity;
/// This value ranges from 0 to 1, but seems to be most stable at values under 1. [Default Value: 0.3]
@property AKConstant *dampingFactor;

/// Set an optional damping factor
/// @param dampingFactor This value ranges from 0 to 1, but seems to be most stable at values under 1. [Default Value: 0.3]
- (void)setOptionalDampingFactor:(AKConstant *)dampingFactor;



@end
