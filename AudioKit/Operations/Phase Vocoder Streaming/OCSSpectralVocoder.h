//
//  OCSSpectralVocoder.h
//  Objective-C Sound
//
//  Auto-generated from scripts by Aurelius Prochazka on 12/25/13.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//

#import "OCSFSignal.h"
#import "OCSParameter+Operation.h"

/** Combine the spectral envelope of one F-signal with the excitation (frequencies) of another.
 
 This operation provides support for cross-synthesis of amplitudes and frequencies. It takes the amplitudes of one input F-signal and combines with frequencies from another. It is a spectral version of the well-known channel vocoder.
 */

@interface OCSSpectralVocoder : OCSFSignal

/// Instantiates the spectral vocoder
/// @param amplitudeFSignal Input phase vocoder stream from which the amplitudes will be extracted.
/// @param excitationFrequenciesFSignal Input phase vocoder stream from which the frequencies will be taken.
/// @param depth Depth of effect, affecting how much of the frequencies will be taken from the second fsig: 0, the output is amplitudeFSignal, 1 the output is the amplitudeFSignal amplitudes and excitationFrequenciesFSignal frequencies.
/// @param gain Boost or attenuation applied to the output
- (instancetype)initWithAmplitudeFSignal:(OCSFSignal *)amplitudeFSignal
            excitationFrequenciesFSignal:(OCSFSignal *)excitationFrequenciesFSignal
                                   depth:(OCSControl *)depth
                                    gain:(OCSControl *)gain;


/// Set an optional coefs
/// @param coefs Number of cepstrum coefs used in spectral envelope estimation (defaults to 80).
- (void)setOptionalCoefs:(OCSControl *)coefs;


@end