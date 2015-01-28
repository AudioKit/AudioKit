//
//  AKSpectralVocoder.m
//  AudioKit
//
//  Auto-generated on 12/25/13.
//  Copyright (c) 2012 Aurelius Prochazka. All rights reserved.
//
//  Implementation of Csound's pvsvoc:
//  http://www.csounds.com/manual/html/pvsvoc.html
//

#import "AKSpectralVocoder.h"

@implementation AKSpectralVocoder
{
    AKFSignal *famp;
    AKFSignal *fexc;
    AKControl *kdepth;
    AKControl *kgain;
    AKControl *kcoefs;
}

- (instancetype)initWithAmplitudeFSignal:(AKFSignal *)amplitudeFSignal
            excitationFrequenciesFSignal:(AKFSignal *)excitationFrequenciesFSignal
                                   depth:(AKControl *)depth
                                    gain:(AKControl *)gain
{
    self = [super initWithString:[self operationName]];
    if (self) {
        famp = amplitudeFSignal;
        fexc = excitationFrequenciesFSignal;
        kdepth = depth;
        kgain = gain;
        kcoefs = akp(80);
    }
    return self;
}

- (void)setOptionalCoefs:(AKControl *)coefs {
	kcoefs = coefs;
}

- (NSString *)stringForCSD {
    return [NSString stringWithFormat:
            @"%@ pvsvoc %@, %@, %@, %@, %@",
            self, famp, fexc, kdepth, kgain, kcoefs];
}

@end