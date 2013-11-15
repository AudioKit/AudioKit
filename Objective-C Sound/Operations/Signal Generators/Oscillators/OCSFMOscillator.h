//
//  OCSFMOscillator.h
//  Objective-C Sound
//
//  Created by Aurelius Prochazka on 10/28/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//

#import "OCSAudio.h"
#import "OCSParameter+Operation.h"

/** Basic frequency modulated oscillator with linear interpolation.
 
 Interpolating generators will produce a noticeably cleaner output signal, but 
 they may take as much as twice as long to run. Adequate accuracy can also be 
 gained without the time cost of interpolation by using large stored function 
 tables of 2K, 4K or 8K points if the space is available.
 */

@interface OCSFMOscillator : OCSAudio

/// Instantiates the fm oscillator
/// @param fTable Function table to use.  Requires a wrap-around guard point.
/// @param baseFrequency In cycles per second
/// @param carrierMultiplier This multiplied by the baseFrequency gives the carrier frequency.
/// @param modulatingMultiplier This multiplied by the baseFrequency gives the modulating frequency.
/// @param modulationIndex This multiplied by the modulating frequency gives the modulation amplitude.
/// @param amplitude The amplitude of the output signal
- (instancetype)initWithFTable:(OCSFTable *)fTable
       baseFrequency:(OCSControl *)baseFrequency
   carrierMultiplier:(OCSParameter *)carrierMultiplier
modulatingMultiplier:(OCSParameter *)modulatingMultiplier
     modulationIndex:(OCSControl *)modulationIndex
           amplitude:(OCSParameter *)amplitude;

/// Set an optional phase
/// @param phase Initial phase of waveform in fTable
- (void)setOptionalPhase:(OCSConstant *)phase;

@end