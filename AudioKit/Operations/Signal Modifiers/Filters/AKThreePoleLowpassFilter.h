//
//  AKThreePoleLowpassFilter.h
//  AudioKit
//
//  Auto-generated from scripts by Aurelius Prochazka on 12/21/14.
//  Copyright (c) 2014 Hear For Yourself. All rights reserved.
//

#import "AKAudio.h"
#import "AKParameter+Operation.h"

/** A 3-pole sweepable resonant lowpass filter.

 This a digital emulation of a 3 pole (18 dB/oct.) lowpass filter capable of self-oscillation with a built-in distortion unit. It is really a 3-pole version of moogvcf, retuned, recalibrated and with some performance improvements. The tuning and feedback tables use no more than 6 adds and 6 multiplies per control rate. The distortion unit, itself, is based on a modified tanh function driven by the filter controls.
 */

@interface AKThreePoleLowpassFilter : AKAudio
/// Instantiates the three pole lowpass filter with all values
/// @param audioSource Signal that will be modified. [Default Value: ]
/// @param distortion Amount of distortion. Zero gives a clean output. kdist > 0 adds tanh() distortion controlled by the filter parameters, in such a way that both low cutoff and high resonance increase the distortion amount. Some experimentation is encouraged. [Default Value: 0.5]
/// @param cutoffFrequency The filter cutoff frequency in Hz. [Default Value: 1500]
/// @param resonance Amount of resonance. Self-oscillation occurs when approximately 1. Should usually be in the range 0 to 1, however, values slightly greater than 1 are possible for more sustained oscillation and an “overdrive” effect. [Default Value: 0.5]
- (instancetype)initWithAudioSource:(AKAudio *)audioSource
                         distortion:(AKControl *)distortion
                    cutoffFrequency:(AKControl *)cutoffFrequency
                          resonance:(AKControl *)resonance;

/// Instantiates the three pole lowpass filter with default values
/// @param audioSource Signal that will be modified.
- (instancetype)initWithAudioSource:(AKAudio *)audioSource;

/// Instantiates the three pole lowpass filter with default values
/// @param audioSource Signal that will be modified.
+ (instancetype)audioWithAudioSource:(AKAudio *)audioSource;

/// Amount of distortion. Zero gives a clean output. kdist > 0 adds tanh() distortion controlled by the filter parameters, in such a way that both low cutoff and high resonance increase the distortion amount. Some experimentation is encouraged. [Default Value: 0.5]
@property AKControl *distortion;

/// Set an optional distortion
/// @param distortion Amount of distortion. Zero gives a clean output. kdist > 0 adds tanh() distortion controlled by the filter parameters, in such a way that both low cutoff and high resonance increase the distortion amount. Some experimentation is encouraged. [Default Value: 0.5]
- (void)setOptionalDistortion:(AKControl *)distortion;

/// The filter cutoff frequency in Hz. [Default Value: 1500]
@property AKControl *cutoffFrequency;

/// Set an optional cutoff frequency
/// @param cutoffFrequency The filter cutoff frequency in Hz. [Default Value: 1500]
- (void)setOptionalCutoffFrequency:(AKControl *)cutoffFrequency;

/// Amount of resonance. Self-oscillation occurs when approximately 1. Should usually be in the range 0 to 1, however, values slightly greater than 1 are possible for more sustained oscillation and an “overdrive” effect. [Default Value: 0.5]
@property AKControl *resonance;

/// Set an optional resonance
/// @param resonance Amount of resonance. Self-oscillation occurs when approximately 1. Should usually be in the range 0 to 1, however, values slightly greater than 1 are possible for more sustained oscillation and an “overdrive” effect. [Default Value: 0.5]
- (void)setOptionalResonance:(AKControl *)resonance;



@end
