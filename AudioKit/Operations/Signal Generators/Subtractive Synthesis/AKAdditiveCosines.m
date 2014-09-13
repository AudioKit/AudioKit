//
//  AKAdditiveCosines.m
//  AudioKit
//
//  Created by Adam Boulanger on 10/8/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//

#import "AKAdditiveCosines.h"

@implementation AKAdditiveCosines
{
    AKConstant *pts;
    AKConstant *phs;
    AKControl *numHarmonics;
    AKControl *firstHarmonic;
    AKControl *partialMul;
    AKParameter *freq;
    AKParameter *amp;
    
    AKFTable *f;
}

- (instancetype)initWithFTable:(AKFTable *)cosineTable
                harmonicsCount:(AKControl *)harmonicsCount
            firstHarmonicIndex:(AKControl *)firstHarmonicIndex
             partialMultiplier:(AKControl *)partialMultiplier
          fundamentalFrequency:(AKParameter *)fundamentalFrequency
                     amplitude:(AKParameter *)amplitude
{
    self = [super initWithString:[self operationName]];
    if (self) {
        f = cosineTable;
        phs = akpi(0);
        numHarmonics = harmonicsCount;
        firstHarmonic = firstHarmonicIndex;
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
