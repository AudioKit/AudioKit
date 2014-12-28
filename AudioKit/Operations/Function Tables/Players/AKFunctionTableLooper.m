//
//  AKFunctionTableLooper.m
//  AudioKit
//
//  Auto-generated on 11/4/12.
//  Copyright (c) 2012 Aurelius Prochazka. All rights reserved.
//
//  Implementation of Csound's flooper:
//  http://www.csounds.com/manual/html/flooper.html
//

#import "AKFunctionTableLooper.h"

@implementation AKFunctionTableLooper
{
    AKFunctionTable *ifn;
    AKConstant *istart;
    AKConstant *idur;
    AKConstant *ifad;
    AKControl *kpitch;
    AKControl *kamp;
}

- (instancetype)initWithFunctionTable:(AKFunctionTable *)functionTable
                     startingPosition:(AKConstant *)startingPosition
                         loopDuration:(AKConstant *)loopDuration
                    crossfadeDuration:(AKConstant *)crossfadeDuration
                   transpositionRatio:(AKControl *)transpositionRatio
                            amplitude:(AKControl *)amplitude
{
    self = [super initWithString:[self operationName]];
    if (self) {
        ifn = functionTable;
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