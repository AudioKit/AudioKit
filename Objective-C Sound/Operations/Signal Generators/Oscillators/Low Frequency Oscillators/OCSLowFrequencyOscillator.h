//
//  OCSLowFrequencyOscillator.h
//  Objective-C Sound
//
//  Auto-generated from database on 11/4/12.
//  Modified by Aurelius Prochazka on 11/4/12 to enumerate types.
//
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//

#import "OCSAudio.h"
#import "OCSParameter+Operation.h"
#import "OCSLowFrequencyOscillatorConstants.h"

/** A low frequency oscillator of various shapes.
 
 More detailed description from http://www.csounds.com/manual/html/
 */

@interface OCSLowFrequencyOscillator : OCSAudio

/// Instantiates the low frequency oscillator
/// @param frequency Frequency of the note.
/// @param amplitude Amplitude of output.
- (instancetype)initWithFrequency:(OCSControl *)frequency
              amplitude:(OCSControl *)amplitude;



/// Set an optional type
/// @param type Waveform of the oscillator, can be sine, triangle, square (bipolar), square (unipolar), saw-tooth, saw-tooth (down).
- (void)setOptionalType:(LFOType)type;


@end