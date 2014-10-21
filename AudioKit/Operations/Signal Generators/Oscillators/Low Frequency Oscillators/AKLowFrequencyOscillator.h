//
//  AKLowFrequencyOscillator.h
//  AudioKit
//
//  Auto-generated from scripts by Aurelius Prochazka on 11/4/12.
//  Modified by Aurelius Prochazka on 11/4/12 to enumerate types.
//
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//

#import "AKAudio.h"
#import "AKParameter+Operation.h"
#import "AKLowFrequencyOscillatorConstants.h"

/** A low frequency oscillator of various shapes.s
 */

@interface AKLowFrequencyOscillator : AKAudio

/// Instantiates the low frequency oscillator
/// @param frequency Frequency of the note.
/// @param amplitude Amplitude of output.
- (instancetype)initWithFrequency:(AKControl *)frequency
                        amplitude:(AKControl *)amplitude;



/// Set an optional type
/// @param type Waveform of the oscillator, can be sine, triangle, square (bipolar), square (unipolar), saw-tooth, saw-tooth (down).
- (void)setOptionalType:(LFOType)type;


@end