//
//  OCSAdditiveCosines.m
//  Explorable Explanations
//
//  Created by Adam Boulanger on 10/8/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//

#import "OCSAdditiveCosines.h"

@interface OCSAdditiveCosines ()
{
    OCSConstant *pts;
    OCSConstant *phs;
    OCSControl *numHarmonics;
    OCSControl *firstHarmonic;
    OCSControl *partialMul;
    OCSParameter *freq;
    OCSParameter *amp;
    
    OCSFTable *f;
}
@end

@implementation OCSAdditiveCosines

-(instancetype)initWithFTable:(OCSFTable *)cosineTable
               harmonicsCount:(OCSControl *)harmonicsCount
             firstHarmonicIdx:(OCSControl *)firstHarmonicIdx
            partialMultiplier:(OCSControl *)partialMultiplier
         fundamentalFrequency:(OCSParameter *)fundamentalFrequency
                    amplitude:(OCSParameter *)amplitude
{
    self = [super initWithString:[self operationName]];
    if (self) {
        f = cosineTable;
        phs = ocspi(0);
        numHarmonics = harmonicsCount;
        firstHarmonic = firstHarmonicIdx;
        partialMul = partialMultiplier;
        freq = fundamentalFrequency;
        amp = amplitude;
    }
    return self;
}

- (NSString *)stringForCSD
{
    return [NSString stringWithFormat:
            @"%@ gbuzz %@, %@, %@, %@, %@, %@, %@",
            self, amp, freq, numHarmonics, firstHarmonic, partialMul, f, phs];
}

@end
