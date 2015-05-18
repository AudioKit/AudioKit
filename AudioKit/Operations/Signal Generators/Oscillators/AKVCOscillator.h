//
//  AKVCOscillator.h
//  AudioKit
//
//  Auto-generated on 2/19/15.
//  Customized by Aurelius Prochazka to add class helpers for waveform type
//  Copyright (c) 2015 Aurelius Prochazka. All rights reserved.
//

#import "AKAudio.h"
#import "AKParameter+Operation.h"

/** Implementation of a band-limited oscillator using pre-calculated tables.  Meant to model vintage analog synthesizers.

 Different modes require different inputs so this could be a reason to break this up into separate classes, or use more custom initializers.
 */

NS_ASSUME_NONNULL_BEGIN
@interface AKVCOscillator : AKAudio

//Type Helpers

/// Sawtooth waveform
+ (AKConstant *)waveformTypeForSawtooth;

/// Square waveform with Pulse-width modulation
+ (AKConstant *)waveformTypeForSquareWithPWM;

/// Triangle waveform with ramp
+ (AKConstant *)waveformTypeForTriangleWithRamp;

/// Unnormalized pulse waveform
+ (AKConstant *)waveformTypeForUnnormalizedPulse;

/// Integrated sawtooth waveform
+ (AKConstant *)waveformTypeForIntegratedSawtooth;

/// Square waveform (without PWM)
+ (AKConstant *)waveformTypeForSquare;

/// Triangle waveform
+ (AKConstant *)waveformTypeForTriangle;

/// Instantiates the vc oscillator with all values
/// @param waveformType Valid types are given by class functions starting with waveformTypeFor... [Default Value: waveformTypeForSawtooth]
/// @param bandwidth Bandwidth of the generated waveform, as percentage (0 to 1) of the sample rate. The expected range is 0 to 0.5 [Default Value: 0.5]
/// @param pulseWidth The pulse width of the square wave or the ramp characteristics of the triangle wave. It is required only by these waveforms and ignored in all other cases. The expected range is 0 to 1, any other value is wrapped to the allowed range. Updated at Control-rate. [Default Value: 0]
/// @param frequency Frequency in Hz Updated at Control-rate. [Default Value: 440]
/// @param amplitude Amplitude scale. In the case of a imode waveform value of a pulse waveform, the actual output level can be a lot higher than this value. Updated at Control-rate. [Default Value: 1]
- (instancetype)initWithWaveformType:(AKConstant *)waveformType
                           bandwidth:(AKConstant *)bandwidth
                          pulseWidth:(AKParameter *)pulseWidth
                           frequency:(AKParameter *)frequency
                           amplitude:(AKParameter *)amplitude;

/// Instantiates the vc oscillator with default values
- (instancetype)init;

/// Instantiates the vc oscillator with default values
+ (instancetype)oscillator;

/// Instantiates the vc oscillator with a sawtooth wave
+ (instancetype)presetSawtoothOscillator;

/// Instantiates the vc oscillator with a pulse-modulated squarewave
- (instancetype)initWithSquareWithPWMOscillator;

/// Instantiates the vc oscillator with a pulse-modulated squarewave
+ (instancetype)presetSquareWithPWMOscillator;

/// Instantiates the vc oscillator with an unnormalized pulse wave
- (instancetype)initWithUnnormalizedPulseOscillator;

/// Instantiates the vc oscillator with an unnormalized pulse wave
+ (instancetype)presetUnnormalizedPulseOscillator;

/// Instantiates the vc oscillator with an integrated sawtooth wave
- (instancetype)initWithIntegratedSawtoothOscillator;

/// Instantiates the vc oscillator with an integrated sawtooth wave
+ (instancetype)presetIntegratedSawtoothOscillator;

/// Instantiates the vc oscillator with a square wave
- (instancetype)initWithSquareOscillator;

/// Instantiates the vc oscillator with a square wave
+ (instancetype)presetSquareOscillator;

/// Instantiates the vc oscillator with a triangle wave
- (instancetype)initWithTriangleOscillator;

/// Instantiates the vc oscillator with a triangle wave
+ (instancetype)presetTriangleOscillator;


/// Valid types are given by class functions starting with waveformTypeFor... [Default Value: waveformTypeForSawtooth]
@property (nonatomic) AKConstant *waveformType;

/// Set an optional waveform type
/// @param waveformType Valid types are given by class functions starting with waveformTypeFor... [Default Value: waveformTypeForSawtooth]
- (void)setOptionalWaveformType:(AKConstant *)waveformType;

/// Bandwidth of the generated waveform, as percentage (0 to 1) of the sample rate. The expected range is 0 to 0.5 [Default Value: 0.5]
@property (nonatomic) AKConstant *bandwidth;

/// Set an optional bandwidth
/// @param bandwidth Bandwidth of the generated waveform, as percentage (0 to 1) of the sample rate. The expected range is 0 to 0.5 [Default Value: 0.5]
- (void)setOptionalBandwidth:(AKConstant *)bandwidth;

/// The pulse width of the square wave or the ramp characteristics of the triangle wave. It is required only by these waveforms and ignored in all other cases. The expected range is 0 to 1, any other value is wrapped to the allowed range. [Default Value: 0]
@property (nonatomic) AKParameter *pulseWidth;

/// Set an optional pulse width
/// @param pulseWidth The pulse width of the square wave or the ramp characteristics of the triangle wave. It is required only by these waveforms and ignored in all other cases. The expected range is 0 to 1, any other value is wrapped to the allowed range. Updated at Control-rate. [Default Value: 0]
- (void)setOptionalPulseWidth:(AKParameter *)pulseWidth;

/// Frequency in Hz [Default Value: 440]
@property (nonatomic) AKParameter *frequency;

/// Set an optional frequency
/// @param frequency Frequency in Hz Updated at Control-rate. [Default Value: 440]
- (void)setOptionalFrequency:(AKParameter *)frequency;

/// Amplitude scale. In the case of a imode waveform value of a pulse waveform, the actual output level can be a lot higher than this value. [Default Value: 1]
@property (nonatomic) AKParameter *amplitude;

/// Set an optional amplitude
/// @param amplitude Amplitude scale. In the case of a imode waveform value of a pulse waveform, the actual output level can be a lot higher than this value. Updated at Control-rate. [Default Value: 1]
- (void)setOptionalAmplitude:(AKParameter *)amplitude;



@end
NS_ASSUME_NONNULL_END
