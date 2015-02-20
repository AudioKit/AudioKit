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

- (instancetype)initWithAmplitude:(AKFSignal *)amplitude
            excitationFrequencies:(AKFSignal *)excitationFrequencies
                            depth:(AKControl *)depth
                             gain:(AKControl *)gain
{
    self = [super initWithString:[self operationName]];
    if (self) {
        famp = amplitude;
        fexc = excitationFrequencies;
        kdepth = depth;
        kgain = gain;
        kcoefs = akp(80);
        self.state = @"connectable";
        self.dependencies = @[famp, fexc, kdepth, kgain];

    }
    return self;
}

- (void)setOptionalCoefficents:(AKControl *)coefs {
    kcoefs = coefs;
}

- (NSString *)stringForCSD {
    return [NSString stringWithFormat:
            @"%@ pvsvoc %@, %@, %@, %@, %@",
            self, famp, fexc, kdepth, kgain, kcoefs];
}

@end