//
//  AKBowedString.m
//  AudioKit
//
//  Auto-generated from scripts by Aurelius Prochazka on 11/4/12.
//  Manually modified by Aurelius Prochazka on 11/4/12 in the way iminfreq defaults to kfreq.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//
//  Implementation of Csound's wgbow:
//  http://www.csounds.com/manual/html/wgbow.html
//

#import "AKBowedString.h"

@interface AKBowedString () {
    AKControl *kfreq;
    AKControl *kpres;
    AKControl *krat;
    AKControl *kamp;
    AKFTable *ifn;
    AKControl *kvibf;
    AKControl *kvamp;
    AKConstant *iminfreq;
}
@end

@implementation AKBowedString

- (instancetype)initWithFrequency:(AKControl *)frequency
                         pressure:(AKControl *)pressure
                         position:(AKControl *)position
                        amplitude:(AKControl *)amplitude
                vibratoShapeTable:(AKFTable *)vibratoShapeTable
                 vibratoFrequency:(AKControl *)vibratoFrequency
                 vibratoAmplitude:(AKControl *)vibratoAmplitude
{
    self = [super initWithString:[self operationName]];
    if (self) {
        kfreq = frequency;
        kpres = pressure;
        krat = position;
        kamp = amplitude;
        ifn = vibratoShapeTable;
        kvibf = vibratoFrequency;
        kvamp = vibratoAmplitude;
        iminfreq = [AKConstant constantWithControl:kfreq];
    }
    return self;
}

- (void)setOptionalMinimumFrequency:(AKConstant *)minimumFrequency {
	iminfreq = minimumFrequency;
}

- (NSString *)stringForCSD {
    return [NSString stringWithFormat:
            @"%@ wgbow %@, %@, %@, %@, %@, %@, %@, %@",
            self, kamp, kfreq, kpres, krat, kvibf, kvamp, ifn, iminfreq];
}

@end