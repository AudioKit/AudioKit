//
//  AKPhaseLockedVocoder.m
//  AudioKit
//
//  Auto-generated from scripts by Aurelius Prochazka on 12/25/13.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//
//  Implementation of Csound's mincer:
//  http://www.csounds.com/manual/html/mincer.html
//

#import "AKPhaseLockedVocoder.h"

@implementation AKPhaseLockedVocoder
{
    AKControl *ktab;
    AKAudio *atimpt;
    AKControl *kpitch;
    AKControl *kamp;
    AKConstant *ifftsize;
    AKConstant *idecim;
}

- (instancetype)initWithSourceFTable:(AKControl *)sourceFTable
                                time:(AKAudio *)time
                         scaledPitch:(AKControl *)scaledPitch
                           amplitude:(AKControl *)amplitude
{
    self = [super initWithString:[self operationName]];
    if (self) {
        ktab = sourceFTable;
        atimpt = time;
        kpitch = scaledPitch;
        kamp = amplitude;
        ifftsize = akp(2048);
        idecim = akp(4);
    }
    return self;
}

- (void)setOptionalSizeOfFFT:(AKConstant *)sizeOfFFT {
	ifftsize = sizeOfFFT;
}

- (void)setOptionalDecimation:(AKConstant *)decimation {
	idecim = decimation;
}

- (NSString *)stringForCSD {
    return [NSString stringWithFormat:
            @"%@ mincer %@, %@, %@, %@, 1, %@, %@",
            self, atimpt, kamp, kpitch, ktab, ifftsize, idecim];
}

@end