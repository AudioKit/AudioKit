//
//  AKLowFrequencyOscillator.h
//  AudioKit
//
//  Auto-generated from scripts by Aurelius Prochazka on 12/2/14.
//  Copyright (c) 2014 Hear For Yourself. All rights reserved.
//

#import "AKAudio.h"
#import "AKParameter+Operation.h"

/** A low frequency oscillator of various shapes.

 More detailed description from http://www.csounds.com/manual/html/
 */

@interface AKLowFrequencyOscillator : AKAudio

/// Instantiates the low frequency oscillator with all values
/// @param frequency Frequency of the note.
/// @param type Waveform of the oscillator, can be sine, triangle, square (bipolar), square (unipolar), saw-tooth, saw-tooth (down).
- (instancetype)initWithFrequency:(AKControl *)frequency
                             type:(AKConstant *)type;

/// Instantiates the low frequency oscillator with default values
- (instancetype)init;


/// Instantiates the low frequency oscillator with default values
+ (instancetype)audio;




/// Frequency of the note. [Default Value: 440]
@property AKControl *frequency;

/// Set an optional frequency
/// @param frequency Frequency of the note. [Default Value: 440]
- (void)setOptionalFrequency:(AKControl *)frequency;


/// Waveform of the oscillator, can be sine, triangle, square (bipolar), square (unipolar), saw-tooth, saw-tooth (down). [Default Value: 0]
@property AKConstant *type;

/// Set an optional type
/// @param type Waveform of the oscillator, can be sine, triangle, square (bipolar), square (unipolar), saw-tooth, saw-tooth (down). [Default Value: 0]
- (void)setOptionalType:(AKConstant *)type;


@end
