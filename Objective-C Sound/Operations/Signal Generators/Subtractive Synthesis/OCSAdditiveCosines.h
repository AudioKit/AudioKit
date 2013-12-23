//
//  OCSAdditiveCosines.h
//  Explorable Explanations
//
//  Created by Aurelius Prochazka on 12/22/23.
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

-(instancetype)initWithFTable:(OCSFTable *)cosineTable
               harmonicsCount:(OCSControl *)harmonicsCount
             firstHarmonicIdx:(OCSControl *)firstHarmonicIdx
            partialMultiplier:(OCSControl *)partialMultiplier
         fundamentalFrequency:(OCSParameter *)fundamentalFrequency
                    amplitude:(OCSParameter *)amplitude;

@end
