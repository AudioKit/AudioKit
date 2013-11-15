//
//  OCSFTablelooper.m
//  Objective-C Sound
//
//  Auto-generated from database on 11/4/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//
//  Implementation of Csound's flooper:
//  http://www.csounds.com/manual/html/flooper.html
//

#import "OCSFTablelooper.h"

@interface OCSFTablelooper () {
    OCSFTable *ifn;
    OCSConstant *istart;
    OCSConstant *idur;
    OCSConstant *ifad;
    OCSControl *kpitch;
    OCSControl *kamp;
}
@end

@implementation OCSFTablelooper

- (instancetype)initWithFTable:(OCSFTable *)fTable
    startingPosition:(OCSConstant *)startingPosition
        loopDuration:(OCSConstant *)loopDuration
   crossfadeDuration:(OCSConstant *)crossfadeDuration
  transpositionRatio:(OCSControl *)transpositionRatio
           amplitude:(OCSControl *)amplitude
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