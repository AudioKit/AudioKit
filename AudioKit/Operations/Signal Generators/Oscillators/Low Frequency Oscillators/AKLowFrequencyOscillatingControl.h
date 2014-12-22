//
//  AKLowFrequencyOscillatingControl.h
//  AudioKit
//
//  Auto-generated from scripts by Aurelius Prochazka on 12/22/14.
//  Copyright (c) 2014 Hear For Yourself. All rights reserved.
//

#import "AKControl.h"
#import "AKParameter+Operation.h"

/** A low frequency oscillator of various shapes.

 More detailed description from http://www.csounds.com/manual/html/
 */

@interface AKLowFrequencyOscillatingControl : AKControl
/// Instantiates the low frequency oscillating control with all values
/// @param frequency Frequency of the note. [Default Value: 110]
/// @param type Waveform of the oscillator, can be sine, triangle, square (bipolar), square (unipolar), saw-tooth, saw-tooth (down). [Default Value: 0]
/// @param amplitude Amplitude of output. [Default Value: 1]
- (instancetype)initWithFrequency:(AKControl *)frequency
                             type:(AKLowFrequencyOscillatorType)type
                        amplitude:(AKControl *)amplitude;

/// Instantiates the low frequency oscillating control with default values
- (instancetype)init;

/// Instantiates the low frequency oscillating control with default values
+ (instancetype)control;


/// Frequency of the note. [Default Value: 110]
@property AKControl *frequency;

/// Set an optional frequency
/// @param frequency Frequency of the note. [Default Value: 110]
- (void)setOptionalFrequency:(AKControl *)frequency;

/// Waveform of the oscillator, can be sine, triangle, square (bipolar), square (unipolar), saw-tooth, saw-tooth (down). [Default Value: 0]
@property AKLowFrequencyOscillatorType type;

/// Set an optional type
/// @param type Waveform of the oscillator, can be sine, triangle, square (bipolar), square (unipolar), saw-tooth, saw-tooth (down). [Default Value: 0]
- (void)setOptionalType:(AKLowFrequencyOscillatorType)type;

/// Amplitude of output. [Default Value: 1]
@property AKControl *amplitude;

/// Set an optional amplitude
/// @param amplitude Amplitude of output. [Default Value: 1]
- (void)setOptionalAmplitude:(AKControl *)amplitude;



@end
