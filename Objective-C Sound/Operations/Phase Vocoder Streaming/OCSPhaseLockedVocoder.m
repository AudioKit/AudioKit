//
//  OCSPhaseLockedVocoder.m
//  Objective-C Sound
//
//  Auto-generated from database on 12/25/13.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//
//  Implementation of Csound's mincer:
//  http://www.csounds.com/manual/html/mincer.html
//

#import "OCSPhaseLockedVocoder.h"

@interface OCSPhaseLockedVocoder () {
    OCSControl *ktab;
    OCSAudio *atimpt;
    OCSControl *kpitch;
    OCSControl *kamp;
    OCSConstant *ifftsize;
    OCSConstant *idecim;
}
@end

@implementation OCSPhaseLockedVocoder

- (instancetype)initWithSourceFTable:(OCSControl *)sourceFTable
                                time:(OCSAudio *)time
                         scaledPitch:(OCSControl *)scaledPitch
                           amplitude:(OCSControl *)amplitude
{
    self = [super initWithString:[self operationName]];
    if (self) {
        ktab = sourceFTable;
        atimpt = time;
        kpitch = scaledPitch;
        kamp = amplitude;
        ifftsize = ocsp(2048);
        idecim = ocsp(4);
    }
    return self;
}

- (void)setOptionalSizeOfFFT:(OCSConstant *)sizeOfFFT {
	ifftsize = sizeOfFFT;
}

- (void)setOptionalDecimation:(OCSConstant *)decimation {
	idecim = decimation;
}

- (NSString *)stringForCSD {
    return [NSString stringWithFormat:
            @"%@ mincer %@, %@, %@, %@, 1, %@, %@",
            self, atimpt, kamp, kpitch, ktab, ifftsize, idecim];
}

@end