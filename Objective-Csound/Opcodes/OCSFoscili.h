//
//  OCSFoscili.h
//
//  Created by Adam Boulanger on 5/29/12.
//  Copyright (c) 2012 MIT Media Lab. All rights reserved.
//

#import "OCSOpcode.h"

/** Basic frequency modulated oscillator with linear interpolation.

Interpolating generators will produce a noticeably cleaner output signal, but
they may take as much as twice as long to run. Adequate accuracy can also be
gained without the time cost of interpolation by using large stored function
tables of 2K, 4K or 8K points if the space is available.  

http://www.csounds.com/manual/html/foscili.html
*/

@interface OCSFoscili : OCSOpcode 

/// The output is mono audio signal.
@property (nonatomic, strong) OCSParam *output;

/// Initializes a frequency modulated oscillator with linear interpolation.
/// @param amplitude            The amplitude of the output signal.
/// @param baseFrequency        In cycles per second, or Hz, this is the common denominator for the carrier and modulating frequencies.
/// @param carrierMutliplier    This multiplied by the baseFrequency gives the carrier frequency.
/// @param modulatingMultiplier This multiplied by the baseFrequency gives the modulating frequency.
/// @param modulationIndex      This multiplied by the modulating frequency gives the modulation amplitude.
/// @param functionTable        Function table to use.  Requires a wrap-around guard point.
/// @param phase                Initial phase of waveform in functionTable, expressed as a fraction of a cycle (0 to 1). 
/// A negative value will cause phase initialization to be skipped.
- (id)initWithAmplitude:(OCSParam *)amplitude
          BaseFrequency:(OCSParamControl *)baseFrequency
      CarrierMultiplier:(OCSParam *)carrierMutliplier
   ModulatingMultiplier:(OCSParam *)modulatingMultiplier
        ModulationIndex:(OCSParamControl *)modulationIndex
          FunctionTable:(OCSFunctionTable *)functionTable
                  Phase:(OCSParamConstant *)phase;

/// Initializes a frequency modulated oscillator with linear interpolation with no phasing.
/// @param amplitude            The amplitude of the output signal.
/// @param baseFrequency        In cycles per second, or Hz, this is the common denominator for the carrier and modulating frequencies.
/// @param carrierMutliplier    This multiplied by the baseFrequency gives the carrier frequency.
/// @param modulatingMultiplier This multiplied by the baseFrequency gives the modulating frequency.
/// @param modulationIndex      This multiplied by the modulating frequency gives the modulation amplitude.
/// @param functionTable        Function table to use.  Requires a wrap-around guard point.
- (id)initWithAmplitude:(OCSParam *)amplitude
          BaseFrequency:(OCSParamControl *)baseFrequency
      CarrierMultiplier:(OCSParam *)carrierMutliplier
   ModulatingMultiplier:(OCSParam *)modulatingMultiplier
        ModulationIndex:(OCSParamControl *)modulationIndex
          FunctionTable:(OCSFunctionTable *)functionTable;




@end
