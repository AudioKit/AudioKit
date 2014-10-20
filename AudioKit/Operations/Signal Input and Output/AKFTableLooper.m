//
//  AKFTableLooper.m
//  AudioKit
//
//  Auto-generated from scripts by Aurelius Prochazka on 11/4/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//
//  Implementation of Csound's flooper:
//  http://www.csounds.com/manual/html/flooper.html
//

#import "AKFTableLooper.h"

@implementation AKFTableLooper
{
    AKFTable *ifn;
    AKConstant *istart;
    AKConstant *idur;
    AKConstant *ifad;
    AKControl *kpitch;
    AKControl *kamp;
}

- (instancetype)initWithFTable:(AKFTable *)fTable
              startingPosition:(AKConstant *)startingPosition
                  loopDuration:(AKConstant *)loopDuration
             crossfadeDuration:(AKConstant *)crossfadeDuration
            transpositionRatio:(AKControl *)transpositionRatio
                     amplitude:(AKControl *)amplitude
{
    self = [super initWithString:[self operationName]];
    if (self) {
        ifn = fTable;
        istart = startingPosition;
        idur = loopDuration;
        ifad = crossfadeDuration;
        kpitch = transpositionRatio;
        kamp = amplitude;
    }
    return self;
}

- (NSString *)stringForCSD {
    return [NSString stringWithFormat:
            @"%@ flooper %@, %@, %@, %@, %@, %@",
            self, kamp, kpitch, istart, idur, ifad, ifn];
}

@end