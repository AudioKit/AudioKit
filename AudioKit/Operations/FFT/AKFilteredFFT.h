//
//  AKFilteredFFT.h
//  AudioKit
//
//  Auto-generated on 9/12/15.
//  Copyright (c) 2015 Aurelius Prochazka. All rights reserved.
//

#import "AKFSignal.h"
#import "AKParameter+Operation.h"

/** Multiply amplitudes of an f-signal by those of a second f-signal, with dynamic scaling.

 More detailed description from http://www.csounds.com/manual/html/pvsfilter.html
 */

NS_ASSUME_NONNULL_BEGIN
@interface AKFilteredFFT : AKFSignal
/// Instantiates the filtered fft with all values
/// @param input Input AKFSignal, from which amplitudes and frequencies are taken. [Default Value: ]
/// @param amplitude Amplitude AKFSignal, the amplitudes of which are multiplied by the input signal. [Default Value: ]
/// @param depth Controls the depth of filtering of the input signal by the amplitude signal. Updated at Control-rate. [Default Value: 1.0]
/// @param gain Amplitude scaling [Default Value: 1.0]
- (instancetype)initWithInput:(AKFSignal *)input
                    amplitude:(AKFSignal *)amplitude
                        depth:(AKParameter *)depth
                         gain:(AKConstant *)gain;

/// Instantiates the filtered fft with default values
/// @param input Input AKFSignal, from which amplitudes and frequencies are taken.
/// @param amplitude Amplitude AKFSignal, the amplitudes of which are multiplied by the input signal.
/// @param depth Controls the depth of filtering of the input signal by the amplitude signal.
- (instancetype)initWithInput:(AKFSignal *)input
                    amplitude:(AKFSignal *)amplitude
                        depth:(AKParameter *)depth;

/// Instantiates the filtered fft with default values
/// @param input Input AKFSignal, from which amplitudes and frequencies are taken.
/// @param amplitude Amplitude AKFSignal, the amplitudes of which are multiplied by the input signal.
/// @param depth Controls the depth of filtering of the input signal by the amplitude signal.
+ (instancetype)filteredFFTWithInput:(AKFSignal *)input
                           amplitude:(AKFSignal *)amplitude
                               depth:(AKParameter *)depth;

/// Amplitude scaling [Default Value: 1.0]
@property (nonatomic) AKConstant *gain;

/// Set an optional gain
/// @param gain Amplitude scaling [Default Value: 1.0]
- (void)setOptionalGain:(AKConstant *)gain;



@end
NS_ASSUME_NONNULL_END

