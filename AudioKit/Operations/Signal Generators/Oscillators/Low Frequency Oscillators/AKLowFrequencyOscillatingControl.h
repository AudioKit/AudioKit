//
//  AKLowFrequencyOscillatingControl.h
//  AudioKit
//
//  Auto-generated from scripts by Aurelius Prochazka on 11/4/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//

#import "AKControl.h"
#import "AKParameter+Operation.h"
#import "AKLowFrequencyOscillatorConstants.h"

/** A low frequency oscillator of various shapes.
 */

@interface AKLowFrequencyOscillatingControl : AKControl

/// Instantiates the low frequency oscillating control
/// @param frequency Frequency of the note.
/// @param amplitude Amplitude of output.
- (instancetype)initWithFrequency:(AKControl *)frequency
                        amplitude:(AKControl *)amplitude;



/// Set an optional type
/// @param type Waveform of the oscillator, can be sine, triangle, square (bipolar), square (unipolar), saw-tooth, saw-tooth (down).
- (void)setOptionalType:(LFOType)type;
@end