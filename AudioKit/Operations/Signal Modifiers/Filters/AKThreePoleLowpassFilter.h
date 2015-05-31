//
//  AKThreePoleLowpassFilter.h
//  AudioKit
//
//  Auto-generated on 2/19/15.
//  Copyright (c) 2015 Aurelius Prochazka. All rights reserved.
//

#import "AKAudio.h"
#import "AKParameter+Operation.h"

/** A 3-pole sweepable resonant lowpass filter.

 This a digital emulation of a 3 pole (18 dB/oct.) lowpass filter capable of self-oscillation with a built-in distortion unit. It is really a 3-pole version of moogvcf, retuned, recalibrated and with some performance improvements. The tuning and feedback tables use no more than 6 adds and 6 multiplies per control rate. The distortion unit, itself, is based on a modified tanh function driven by the filter controls.
 */

NS_ASSUME_NONNULL_BEGIN
@interface AKThreePoleLowpassFilter : AKAudio
/// Instantiates the three pole lowpass filter with all values
/// @param input Signal that will be modified. 
/// @param distortion Amount of distortion. Zero gives a clean output. kdist > 0 adds tanh() distortion controlled by the filter parameters, in such a way that both low cutoff and high resonance increase the distortion amount. Some experimentation is encouraged. Updated at Control-rate. [Default Value: 0.5]
/// @param cutoffFrequency The filter cutoff frequency in Hz. Updated at Control-rate. [Default Value: 1500]
/// @param resonance Amount of resonance. Self-oscillation occurs when approximately 1. Should usually be in the range 0 to 1, however, values slightly greater than 1 are possible for more sustained oscillation and an “overdrive” effect. Updated at Control-rate. [Default Value: 0.5]
- (instancetype)initWithInput:(AKParameter *)input
                   distortion:(AKParameter *)distortion
              cutoffFrequency:(AKParameter *)cutoffFrequency
                    resonance:(AKParameter *)resonance;

/// Instantiates the three pole lowpass filter with default values
/// @param input Signal that will be modified.
- (instancetype)initWithInput:(AKParameter *)input;

/// Instantiates the three pole lowpass filter with default values
/// @param input Signal that will be modified.
+ (instancetype)filterWithInput:(AKParameter *)input;

/// Instantiates the three pole lowpass filter with default values
/// @param input Signal that will be modified.
- (instancetype)initWithPresetDefaultFilterWithInput:(AKParameter *)input;

/// Instantiates the three pole lowpass filter with default values
/// @param input Signal that will be modified.
+ (instancetype)presetDefaultFilterWithInput:(AKParameter *)input;

/// Instantiates the three pole lowpass filter with a bright values
/// @param input Signal that will be modified.
- (instancetype)initWithPresetBrightFilterWithInput:(AKParameter *)input;

/// Instantiates the three pole lowpass filter with a bright values
/// @param input Signal that will be modified.
+ (instancetype)presetBrightFilterWithInput:(AKParameter *)input;

/// Instantiates the three pole lowpass filter with a bright values
/// @param input Signal that will be modified.
- (instancetype)initWithPresetDullBassWithInput:(AKParameter *)input;

/// Instantiates the three pole lowpass filter with a bright values
/// @param input Signal that will be modified.
+ (instancetype)presetDullBassWithInput:(AKParameter *)input;

/// Instantiates the three pole lowpass filter with a bright values
/// @param input Signal that will be modified.
- (instancetype)initWithPresetScreamWithInput:(AKParameter *)input;

/// Instantiates the three pole lowpass filter with a bright values
/// @param input Signal that will be modified.
+ (instancetype)presetScreamWithInput:(AKParameter *)input;

/// Amount of distortion. Zero gives a clean output. kdist > 0 adds tanh() distortion controlled by the filter parameters, in such a way that both low cutoff and high resonance increase the distortion amount. Some experimentation is encouraged. [Default Value: 0.5]
@property (nonatomic) AKParameter *distortion;

/// Set an optional distortion
/// @param distortion Amount of distortion. Zero gives a clean output. kdist > 0 adds tanh() distortion controlled by the filter parameters, in such a way that both low cutoff and high resonance increase the distortion amount. Some experimentation is encouraged. Updated at Control-rate. [Default Value: 0.5]
- (void)setOptionalDistortion:(AKParameter *)distortion;

/// The filter cutoff frequency in Hz. [Default Value: 1500]
@property (nonatomic) AKParameter *cutoffFrequency;

/// Set an optional cutoff frequency
/// @param cutoffFrequency The filter cutoff frequency in Hz. Updated at Control-rate. [Default Value: 1500]
- (void)setOptionalCutoffFrequency:(AKParameter *)cutoffFrequency;

/// Amount of resonance. Self-oscillation occurs when approximately 1. Should usually be in the range 0 to 1, however, values slightly greater than 1 are possible for more sustained oscillation and an “overdrive” effect. [Default Value: 0.5]
@property (nonatomic) AKParameter *resonance;

/// Set an optional resonance
/// @param resonance Amount of resonance. Self-oscillation occurs when approximately 1. Should usually be in the range 0 to 1, however, values slightly greater than 1 are possible for more sustained oscillation and an “overdrive” effect. Updated at Control-rate. [Default Value: 0.5]
- (void)setOptionalResonance:(AKParameter *)resonance;



@end
NS_ASSUME_NONNULL_END
