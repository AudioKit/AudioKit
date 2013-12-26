//
//  OCSVCOscillator.h
//  Objective-C Sound
//
//  Auto-generated from scripts by Aurelius Prochazka on 11/4/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//

#import "OCSAudio.h"
#import "OCSParameter+Operation.h"

/** Implementation of a band-limited oscillator using pre-calculated tables.  Meant to model vintage analog synthesizers.
 
 Different modes require different inputs so this could be a reason to break this up into separate classes, or use more custom initializers.
 */

#warning In Csound, vco2 usually requires a vco2init, in the current state OCSVCOscillator is highly unstable.

@interface OCSVCOscillator : OCSAudio

/// Instantiates the VC Oscillator
/// @param frequency Frequency in Hz
/// @param amplitude Amplitude scale. In the case of a imode waveform value of a pulse waveform, the actual output level can be a lot higher than this value.
- (instancetype)initWithFrequency:(OCSControl *)frequency
                        amplitude:(OCSControl *)amplitude;

#warning Waveform type is a magic number, should change this to take an enumerated value or use separate methods for each waveform type
/// Set an optional waveform type
/// @param waveformType Choose from various waveform types.
- (void)setOptionalWaveformType:(OCSConstant *)waveformType;

/// Set an optional pulse width
/// @param pulseWidth The pulse width of the square wave or the ramp characteristics of the triangle wave. It is required only by these waveforms and ignored in all other cases. The expected range is 0 to 1, any other value is wrapped to the allowed range.
- (void)setOptionalPulseWidth:(OCSControl *)pulseWidth;

/// Set an optional phase
/// @param phase Oscillator phase (depending on imode, this can be either an optional i-rate parameter that defaults to zero or required k-rate). Similarly to pulseWidth, the expected range is 0 to 1.
- (void)setOptionalPhase:(OCSControl *)phase;

/// Set an optional bandwidth
/// @param bandwidth Bandwidth of the generated waveform, as percentage (0 to 1) of the sample rate. The expected range is 0 to 0.5
- (void)setOptionalBandwidth:(OCSConstant *)bandwidth;


@end