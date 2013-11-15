//
//  OCSAdditiveCosines.h
//  Explorable Explanations
//
//  Created by Adam Boulanger on 10/8/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//

#import "OCSAudio.h"
#import "OCSParameter+Operation.h"

/** Generate an additive set of harmonically related cosine partials of a fundamental frequency, 
 and whose amplitudes are scaled so their summation peak equal the given amplitude property. 
 Properties determine the selection and strength of partials. This is a band-limited pulse train: 
 if the partials extend to the Nyquist, i.e. harmonicsCount = int (sr / 2 / fundamental freq.), 
 the result is a real pulse train of amplitude (amplitude).
 
 */

@interface OCSAdditiveCosines : OCSAudio

/*
/// @name Initialization

/// Instantiates the additive, harmonically related cosines with the given parameters.
/// @param numberOfCosineTablePoints The number of points in the cosine function used as the basis for the additive sum of the resulting waveform.  A minimum of 8192 points and a power of 2 is recommended.
/// @param harmonicsCount         The total number of harmonic partials.
/// @param firstHarmonicIdx       The lowest harmonic present.  A negative value will reflect and add constructively with subsequent positive partials./// @param maxAmplitudeDeviation  Maximum amplitude deviation from `amplitude`. If it is set to zero then there is no random amplitude for each grain.
/// @param partialMultiplier      Multiplier by which to scale partials in the harmonic series.  If the lowest harmonic (lh) has amplitude "A" then the (lh + n)th harmonic will have a coefficient of A*(partialMultiplier ** n).
/// @param fundamentalFrequency   The fundamental frequency of harmonically related cosine partials.
/// @param amplitude              The amplitude of the output signal.

-(instancetype)initWithNumberOfCosineTablePoints:(OCSConstant *)numberOfCosineTablePoints
             harmonicsCount:(OCSControl *)harmonicsCount
           firstHarmonicIdx:(OCSControl *)firstHarmonicIdx
          partialMultiplier:(OCSControl *)partialMultiplier
       fundamentalFrequency:(OCSParameter *)fundamentalFrequency
                  amplitude:(OCSParameter *)amplitude;

/// Instantiates the additive, harmonically related cosines with the given parameters.
/// @param numberOfCosineTablePoints The number of points in the cosine function used as the basis for the additive sum of the resulting waveform.  A minimum of 8192 points and a power of 2 is recommended.
/// @param phase                  Initial phase of the fundamental frequency, expressed as a fraction of a cycle (0 to 1).
/// @param harmonicsCount         The total number of harmonic partials.
/// @param firstHarmonicIdx       The lowest harmonic present.  A negative value will reflect and add constructively with subsequent positive partials./// @param maxAmplitudeDeviation  Maximum amplitude deviation from `amplitude`. If it is set to zero then there is no random amplitude for each grain.
/// @param partialMultiplier      Multiplier by which to scale partials in the harmonic series.  If the lowest harmonic (lh) has amplitude "A" then the (lh + n)th harmonic will have a coefficient of A*(partialMultiplier ** n).
/// @param fundamentalFrequency   The fundamental frequency of harmonically related cosine partials.
/// @param amplitude              The amplitude of the output signal.

-(instancetype)initWithNumberOfCosineTablePoints:(OCSConstant *)numberOfCosineTablePoints
                                 phase:(OCSConstant *)phase
                        harmonicsCount:(OCSControl *)harmonicsCount
                      firstHarmonicIdx:(OCSControl *)firstHarmonicIdx
                     partialMultiplier:(OCSControl *)partialMultiplier
                  fundamentalFrequency:(OCSParameter *)fundamentalFrequency
                             amplitude:(OCSParameter *)amplitude;
*/


/// Instantiates the additive, harmonically related cosines with the given parameters.
/// @param cosineTable            A cosine table with a minimum of 8192 points and a power of 2 is recommended.
/// @param harmonicsCount         The total number of harmonic partials.
/// @param firstHarmonicIdx       The lowest harmonic present.  A negative value will reflect and add constructively with subsequent positive partials./// @param maxAmplitudeDeviation  Maximum amplitude deviation from `amplitude`. If it is set to zero then there is no random amplitude for each grain.
/// @param partialMultiplier      Multiplier by which to scale partials in the harmonic series.  If the lowest harmonic (lh) has amplitude "A" then the (lh + n)th harmonic will have a coefficient of A*(partialMultiplier ** n).
/// @param fundamentalFrequency   The fundamental frequency of harmonically related cosine partials.
/// @param amplitude              The amplitude of the output signal.
-(instancetype)initWithFTable:(OCSFTable *)cosineTable
     harmonicsCount:(OCSControl *)harmonicsCount
   firstHarmonicIdx:(OCSControl *)firstHarmonicIdx
  partialMultiplier:(OCSControl *)partialMultiplier
    fundamentalFrequency:(OCSParameter *)fundamentalFrequency
          amplitude:(OCSParameter *)amplitude;

@end
