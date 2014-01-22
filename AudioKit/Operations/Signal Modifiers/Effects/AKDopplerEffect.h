//
//  AKDopplerEffect.h
//  AudioKit
//
//  Auto-generated from scripts by Aurelius Prochazka on 11/24/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//

#import "AKAudio.h"
#import "AKParameter+Operation.h"

/** A fast and robust method for approximating sound propagation, achieving convincing Doppler shifts without having to solve equations.
 
 A fast and robust method for approximating sound propagation, achieving convincing Doppler shifts without having to solve equations. The method computes frequency shifts based on reading an input delay line at a delay time computed from the distance between source and mic and the speed of sound. One instance of the opcode is required for each dimension of space through which the sound source moves. If the source sound moves at a constant speed from in front of the microphone, through the microphone, to behind the microphone, then the output will be frequency shifted above the source frequency at a constant frequency while the source approaches, then discontinuously will be shifted below the source frequency at a constant frequency as the source recedes from the microphone. If the source sound moves at a constant speed through a point to one side of the microphone, then the rate of change of position will not be constant, and the familiar Doppler frequency shift typical of a siren or engine approaching and receding along a road beside a listener will be heard.
 */

@interface AKDopplerEffect : AKAudio

/// Instantiates the doppler effect
/// @param audioSource Input signal at the sound source.
/// @param micPosition Position of the recording microphone in meters. The distance between source and mic should not be changed faster than about 3/4 the speed of sound.
/// @param sourcePosition Position of the source sound in meters. The distance between source and mic should not be changed faster than about 3/4 the speed of sound.
- (instancetype)initWithAudioSource:(AKAudio *)audioSource
                        micPosition:(AKControl *)micPosition
                     sourcePosition:(AKControl *)sourcePosition;


/// Set an optional sound speed
/// @param soundSpeed Speed of sound in meters/second.
- (void)setOptionalSoundSpeed:(AKConstant *)soundSpeed;

/// Set an optional smoothing filter update rate
/// @param smoothingFilterUpdateRate Rate of updating the position smoothing filter, in cycles/second.
- (void)setOptionalSmoothingFilterUpdateRate:(AKConstant *)smoothingFilterUpdateRate;


@end