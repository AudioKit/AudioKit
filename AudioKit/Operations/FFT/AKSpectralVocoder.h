//
//  AKSpectralVocoder.h
//  AudioKit
//
//  Auto-generated on 12/25/13.
//  Copyright (c) 2012 Aurelius Prochazka. All rights reserved.
//

#import "AKFSignal.h"
#import "AKParameter+Operation.h"

/** Combine the spectral envelope of one F-signal with the excitation (frequencies) of another.

 This operation provides support for cross-synthesis of amplitudes and frequencies. It takes the amplitudes of one input F-signal and combines with frequencies from another. It is a spectral version of the well-known channel vocoder.
 */

NS_ASSUME_NONNULL_BEGIN
@interface AKSpectralVocoder : AKFSignal

/// Instantiates the spectral vocoder
/// @param amplitude Input phase vocoder stream from which the amplitudes will be extracted.
/// @param excitationFrequencies Input phase vocoder stream from which the frequencies will be taken.
/// @param depth Depth of effect, affecting how much of the frequencies will be taken from the second fsig: 0, the output is amplitudeFSignal, 1 the output is the amplitudeFSignal amplitudes and excitationFrequenciesFSignal frequencies.
/// @param gain Boost or attenuation applied to the output
- (instancetype)initWithAmplitude:(AKFSignal *)amplitude
            excitationFrequencies:(AKFSignal *)excitationFrequencies
                            depth:(AKControl *)depth
                             gain:(AKControl *)gain;


/// Set an optional coefs
/// @param coefs Number of cepstrum coefs used in spectral envelope estimation (defaults to 80).
- (void)setOptionalCoefficents:(AKControl *)coefs;


@end
NS_ASSUME_NONNULL_END
