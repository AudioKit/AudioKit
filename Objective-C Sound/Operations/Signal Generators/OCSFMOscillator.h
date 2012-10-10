//
//  OCSFMOscillator.h
//  Objective-C Sound
//
//  Created by Adam Boulanger on 5/29/12.
//  Copyright (c) 2012 MIT Media Lab. All rights reserved.
//

#import "OCSParameter+Operation.h"

/** Basic frequency modulated oscillator with linear interpolation.

Interpolating generators will produce a noticeably cleaner output signal, but
they may take as much as twice as long to run. Adequate accuracy can also be
gained without the time cost of interpolation by using large stored function
tables of 2K, 4K or 8K points if the space is available.  

*/

@interface OCSFMOscillator : OCSParameter

/// @name Initialization

/// Initializes a frequency modulated oscillator with linear interpolation.
/// @param fTable               Function table to use.  Requires a wrap-around guard point.
/// @param phase                Initial phase of waveform in fTable, expressed as a fraction of a cycle (0 to 1).
/// @param baseFrequency        In cycles per second, or Hz, this is the common denominator for the carrier and modulating frequencies.
/// @param carrierMultiplier    This multiplied by the baseFrequency gives the carrier frequency.
/// @param modulatingMultiplier This multiplied by the baseFrequency gives the modulating frequency.
/// @param modulationIndex      This multiplied by the modulating frequency gives the modulation amplitude.
/// @param amplitude            The amplitude of the output signal.
- (id)initWithFTable:(OCSFTable *)fTable
               phase:(OCSConstant *)phase
       baseFrequency:(OCSControl *)baseFrequency
   carrierMultiplier:(OCSParameter *)carrierMultiplier
modulatingMultiplier:(OCSParameter *)modulatingMultiplier
     modulationIndex:(OCSControl *)modulationIndex
           amplitude:(OCSParameter *)amplitude;

/// Initializes a frequency modulated oscillator with linear interpolation with no phasing.
/// @param fTable               Function table to use.  Requires a wrap-around guard point.
/// @param baseFrequency        In cycles per second, or Hz, this is the common denominator for the carrier and modulating frequencies.
/// @param carrierMultiplier    This multiplied by the baseFrequency gives the carrier frequency.
/// @param modulatingMultiplier This multiplied by the baseFrequency gives the modulating frequency.
/// @param modulationIndex      This multiplied by the modulating frequency gives the modulation amplitude.
/// @param amplitude            The amplitude of the output signal.
- (id)initWithFTable:(OCSFTable *)fTable
       baseFrequency:(OCSControl *)baseFrequency
   carrierMultiplier:(OCSParameter *)carrierMultiplier
modulatingMultiplier:(OCSParameter *)modulatingMultiplier
     modulationIndex:(OCSControl *)modulationIndex
           amplitude:(OCSParameter *)amplitude;

@end
