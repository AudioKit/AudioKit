//
//  OCSSpectralVocoder.m
//  Objective-C Sound
//
//  Auto-generated from database on 12/25/13.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//
//  Implementation of Csound's pvsvoc:
//  http://www.csounds.com/manual/html/pvsvoc.html
//

#import "OCSSpectralVocoder.h"

@interface OCSSpectralVocoder () {
    OCSFSignal *famp;
    OCSFSignal *fexc;
    OCSControl *kdepth;
    OCSControl *kgain;
    OCSControl *kcoefs;
}
@end

@implementation OCSSpectralVocoder

- (instancetype)initWithAmplitudeFSignal:(OCSFSignal *)amplitudeFSignal
            excitationFrequenciesFSignal:(OCSFSignal *)excitationFrequenciesFSignal
                                   depth:(OCSControl *)depth
                                    gain:(OCSControl *)gain
{
    self = [super initWithString:[self operationName]];
    if (self) {
        famp = amplitudeFSignal;
        fexc = excitationFrequenciesFSignal;
        kdepth = depth;
        kgain = gain;
        kcoefs = ocsp(80);
    }
    return self;
}

- (void)setOptionalCoefs:(OCSControl *)coefs {
	kcoefs = coefs;
}

- (NSString *)stringForCSD {
    return [NSString stringWithFormat:
            @"%@ pvsvoc %@, %@, %@, %@, %@",
            self, famp, fexc, kdepth, kgain, kcoefs];
}

@end