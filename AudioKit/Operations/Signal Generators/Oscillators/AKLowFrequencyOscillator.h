//
//  AKLowFrequencyOscillator.h
//  AudioKit
//
//  Auto-generated on 2/19/15.
//  Customized by Aurelius Prochazka adding type helpers
//  Copyright (c) 2015 Aurelius Prochazka. All rights reserved.
//

#import "AKAudio.h"
#import "AKParameter+Operation.h"

/** A low frequency oscillator of various shapes.
 */

NS_ASSUME_NONNULL_BEGIN
@interface AKLowFrequencyOscillator : AKAudio

//Type Helpers

/// Sine Waveform
+ (AKConstant *)waveformTypeForSine;

/// Triangle waveform
+ (AKConstant *)waveformTypeForTriangle;

/// Bipolar square waveform
+ (AKConstant *)waveformTypeForBipolarSquare;

/// Unipolar Square waveform
+ (AKConstant *)waveformTypeForUnipolarSquare;

/// Sawtooth waveform
+ (AKConstant *)waveformTypeForSawtooth;

/// Reverse sawtooth waveform
+ (AKConstant *)waveformTypeForDownSawtooth;

/// Instantiates the low frequency oscillator with all values
/// @param waveformType Waveform of the oscillator, can be sine, triangle, square (bipolar), square (unipolar), saw-tooth, saw-tooth (down). [Default Value: AKLowFrequencyOscillatorTypeSine]
/// @param frequency Frequency of the note. Updated at Control-rate. [Default Value: 110]
/// @param amplitude Amplitude of output. Updated at Control-rate. [Default Value: 1]
- (instancetype)initWithWaveformType:(AKConstant *)waveformType
                           frequency:(AKParameter *)frequency
                           amplitude:(AKParameter *)amplitude;

/// Instantiates the low frequency oscillator with default values
- (instancetype)init;

/// Instantiates the low frequency oscillator with default values
+ (instancetype)oscillator;


/// Waveform of the oscillator, can be sine, triangle, square (bipolar), square (unipolar), saw-tooth, saw-tooth (down). [Default Value: AKLowFrequencyOscillatorTypeSine]
@property AKConstant *waveformType;

/// Set an optional type
/// @param waveformType Waveform of the oscillator, can be sine, triangle, square (bipolar), square (unipolar), saw-tooth, saw-tooth (down). [Default Value: AKLowFrequencyOscillatorTypeSine]
- (void)setOptionalWaveformType:(AKConstant *)waveformType;

/// Frequency of the note. [Default Value: 110]
@property (nonatomic) AKParameter *frequency;

/// Set an optional frequency
/// @param frequency Frequency of the note. Updated at Control-rate. [Default Value: 110]
- (void)setOptionalFrequency:(AKParameter *)frequency;

/// Amplitude of output. [Default Value: 1]
@property (nonatomic) AKParameter *amplitude;

/// Set an optional amplitude
/// @param amplitude Amplitude of output. Updated at Control-rate. [Default Value: 1]
- (void)setOptionalAmplitude:(AKParameter *)amplitude;



@end
NS_ASSUME_NONNULL_END
