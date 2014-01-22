//
//  AKBallWithinTheBoxReverb.h
//  AudioKit
//
//  Auto-generated from scripts by Aurelius Prochazka on 11/2/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//

#import "AKStereoAudio.h"
#import "AKParameter+Operation.h"

/** A physical model reverberator.
 
 Physical model reverberator based on the paper by Davide Rocchesso 'The Ball within the Box - a sound-processing metaphor', Computer Music Journal, Vol 19, N.4, pp.45-47, Winter 1995.
 */

@interface AKBallWithinTheBoxReverb : AKStereoAudio

/// Instantiates the ball within the box reverb
/// @param lengthOfXAxisEdge Length of x-axis edge of the box in meters.
/// @param lengthOfYAxisEdge Length of y-axis edge of the box in meters.
/// @param lengthOfZAxisEdge Length of z-axis edge of the box in meters.
/// @param xLocation The virtual x-coordinate of the source of sound (the input signal).
/// @param yLocation The virtual y-coordinate of the source of sound (the input signal).
/// @param zLocation The virtual z-coordinate of the source of sound (the input signal).
/// @param audioSource The input signal
- (instancetype)initWithLengthOfXAxisEdge:(AKConstant *)lengthOfXAxisEdge
                        lengthOfYAxisEdge:(AKConstant *)lengthOfYAxisEdge
                        lengthOfZAxisEdge:(AKConstant *)lengthOfZAxisEdge
                                xLocation:(AKControl *)xLocation
                                yLocation:(AKControl *)yLocation
                                zLocation:(AKControl *)zLocation
                              audioSource:(AKAudio *)audioSource;


/// Set an optional diffusion
/// @param diffusion Coefficient of diffusion at the walls, which regulates the amount of diffusion (0-1, where 0 = no diffusion, 1 = maximum diffusion, default= 1)
- (void)setOptionalDiffusion:(AKConstant *)diffusion;


@end