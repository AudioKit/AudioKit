//
//  AKAdditiveCosines.h
//  AudioKit
//
//  Created by Aurelius Prochazka on 12/22/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//

#import "AKAudio.h"
#import "AKParameter+Operation.h"

/** Generate an additive set of harmonically related cosine partials of a fundamental frequency,
 and whose amplitudes are scaled so their summation peak equal the given amplitude property.
 Properties determine the selection and strength of partials. This is a band-limited pulse train:
 if the partials extend to the Nyquist, i.e. harmonicsCount = int (sr / 2 / fundamental freq.),
 the result is a real pulse train of amplitude (amplitude).
 
 */

@interface AKAdditiveCosines : AKAudio

/// Create a set of harmonically related cosine partials
/// @param cosineTable A cosine table with at least 8192 points is recommended
/// @param harmonicsCount Total number of harmonics requested.
/// @param firstHarmonicIndex The lowest harmonic present.
/// @param partialMultiplier The multiplier in the series of amplitude coefficients.
/// @param fundamentalFrequency Thefrequency which can be modulated at any rate.
/// @param amplitude Total amplitude which can be modulated at any rate.
-  (instancetype)initWithFTable:(AKFTable *)cosineTable
                 harmonicsCount:(AKControl *)harmonicsCount
             firstHarmonicIndex:(AKControl *)firstHarmonicIndex
              partialMultiplier:(AKControl *)partialMultiplier
           fundamentalFrequency:(AKParameter *)fundamentalFrequency
                      amplitude:(AKParameter *)amplitude;

@end
