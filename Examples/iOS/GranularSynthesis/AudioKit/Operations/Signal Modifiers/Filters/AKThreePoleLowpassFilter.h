//
//  AKThreePoleLowpassFilter.h
//  AudioKit
//
//  Auto-generated from scripts by Aurelius Prochazka on 11/4/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//

#import "AKAudio.h"
#import "AKParameter+Operation.h"

/** A 3-pole sweepable resonant lowpass filter.
 
 This a digital emulation of a 3 pole (18 dB/oct.) lowpass filter capable of self-oscillation with a built-in distortion unit. It is really a 3-pole version of moogvcf, retuned, recalibrated and with some performance improvements. The tuning and feedback tables use no more than 6 adds and 6 multiplies per control rate. The distortion unit, itself, is based on a modified tanh function driven by the filter controls.
 */

@interface AKThreePoleLowpassFilter : AKAudio

/// Instantiates the three pole lowpass filter
/// @param audioSource     Signal that will be modified.
/// @param distortion      Amount of distortion. Zero gives a clean output. kdist > 0 adds tanh() distortion controlled by the filter parameters, in such a way that both low cutoff and high resonance increase the distortion amount. Some experimentation is encouraged.
/// @param cutoffFrequency The filter cutoff frequency in Hz.
/// @param resonance       Amount of resonance. Self-oscillation occurs when approximately 1. Should usually be in the range 0 to 1, however, values slightly greater than 1 are possible for more sustained oscillation and an “overdrive” effect.
- (instancetype)initWithAudioSource:(AKAudio *)audioSource
                         distortion:(AKControl *)distortion
                    cutoffFrequency:(AKControl *)cutoffFrequency
                          resonance:(AKControl *)resonance;

@end