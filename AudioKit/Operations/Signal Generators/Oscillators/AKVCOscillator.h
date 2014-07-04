//
//  AKVCOscillator.h
//  AudioKit
//
//  Rewritten by Aurelius Prochazka on 7/4/14.
//  Copyright (c) 2014 Hear For Yourself. All rights reserved.
//

#import "AKAudio.h"
#import "AKParameter+Operation.h"

/** Implementation of a band-limited oscillator using pre-calculated tables.  Meant to model vintage analog synthesizers.
 
 Different modes require different inputs so this could be a reason to break this up into separate classes, or use more custom initializers.
 */

typedef enum
{
    kVCOscillatorWaveformSawtooth  = 16,
    kVCOscillatorWaveformSquarePWM = 18,
    kVCOscillatorWaveformTriangleWithRamp = 20,
    kVCOscillatorWaveformPulseUnnormalized = 22,
    kVCOscillatorWaveformIntegratedSawtooth = 24,
    kVCOscillatorWaveformSquareNoPWM = 26,
    kVCOscillatorWaveformTriangleNoRamp = 28
} VCOscillatorType;

@interface AKVCOscillator : AKAudio

/// Instantiates the VC Oscillator
/// @param frequency Frequency in Hz
/// @param amplitude Amplitude scale. In the case of a imode waveform value of a pulse waveform, the actual output level can be a lot higher than this value.
- (instancetype)initWithFrequency:(AKControl *)frequency
                        amplitude:(AKControl *)amplitude;

/// Set an optional waveform type
/// @param waveformType Choose from various waveform types.
- (void)setOptionalWaveformType:(VCOscillatorType)waveformType;

/// Set an optional pulse width
/// @param pulseWidth The pulse width of the square wave or the ramp characteristics of the triangle wave. It is required only by these waveforms and ignored in all other cases. The expected range is 0 to 1, any other value is wrapped to the allowed range.
- (void)setOptionalPulseWidth:(AKControl *)pulseWidth;

/// Set an optional phase
/// @param phase Oscillator phase (depending on imode, this can be either an optional i-rate parameter that defaults to zero or required k-rate). Similarly to pulseWidth, the expected range is 0 to 1.
- (void)setOptionalPhase:(AKControl *)phase;

/// Set an optional bandwidth
/// @param bandwidth Bandwidth of the generated waveform, as percentage (0 to 1) of the sample rate. The expected range is 0 to 0.5
- (void)setOptionalBandwidth:(AKConstant *)bandwidth;


@end