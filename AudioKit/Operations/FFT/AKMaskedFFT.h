//
//  AKMaskedFFT.h
//  AudioKit
//
//  Auto-generated on 9/20/15.
//  Customised by Daniel Clelland on 9/5/15.
//  Copyright (c) 2015 Aurelius Prochazka. All rights reserved.
//

#import "AKFSignal.h"
#import "AKParameter+Operation.h"

/** Modify amplitudes using a function table, with dynamic scaling.

 More detailed description from http://www.csounds.com/manual/html/pvsmaska.html
 */

NS_ASSUME_NONNULL_BEGIN
@interface AKMaskedFFT : AKFSignal
/// Instantiates the masked fft with all values
/// @param input An AKFSignal to be masked. [Default Value: ]
/// @param amplitudeTable The amplitude table to use to mask the input signal. Given the input signal has N analysis bins, the table must be of size N or larger. The table need not be normalized, but values should lie within the range 0 to 1. [Default Value: ]
/// @param depth Controls the degree of modification applied to the input signal, using simple linear scaling. 0 leaves amplitudes unchanged, 1 applies the full profile of the amplitude table. Updated at Control-rate. [Default Value: 1.0]
- (instancetype)initWithInput:(AKFSignal *)input
               amplitudeTable:(AKTable *)amplitudeTable
                        depth:(AKParameter *)depth;

/// Instantiates the masked fft with default values
/// @param input An AKFSignal to be masked.
/// @param amplitudeTable The amplitude table to use to mask the input signal. Given the input signal has N analysis bins, the table must be of size N or larger. The table need not be normalized, but values should lie within the range 0 to 1.
/// @param depth Controls the degree of modification applied to the input signal, using simple linear scaling. 0 leaves amplitudes unchanged, 1 applies the full profile of the amplitude table.
+ (instancetype)maskedFFTWithInput:(AKFSignal *)input
                    amplitudeTable:(AKTable *)amplitudeTable
                             depth:(AKParameter *)depth;

@end
NS_ASSUME_NONNULL_END
