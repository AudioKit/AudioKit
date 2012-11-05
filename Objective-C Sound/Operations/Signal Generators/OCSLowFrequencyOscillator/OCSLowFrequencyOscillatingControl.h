//
//  OCSLowFrequencyOscillatingControl.h
//  Objective-C Sound
//
//  Auto-generated from database on 11/4/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//

#import "OCSControl.h"
#import "OCSParameter+Operation.h"

/** A low frequency oscillator of various shapes.
 
 More detailed description from http://www.csounds.com/manual/html/
 */

@interface OCSLowFrequencyOscillatingControl : OCSControl

/// Instantiates the low frequency oscillating control
/// @param frequency Frequency of the note.
/// @param amplitude Amplitude of output.
- (id)initWithFrequency:(OCSControl *)frequency
              amplitude:(OCSControl *)amplitude;


typedef enum
{
    kLFOTypeSine = 0,
    kLFOTypeTriangle = 1,
    kLFOTypeBipolarSquare =2,
    kLFOTypeUnipolarSquare = 3,
    kLFOTypeSawTooth = 4,
    kLFOTypeDownSawTooth = 5
} LFOType;

/// Set an optional type
/// @param type Waveform of the oscillator, can be sine, triangle, square (bipolar), square (unipolar), saw-tooth, saw-tooth (down).
- (void)setOptionalType:(LFOType)type;
@end