//
//  OCSBowedString.m
//  Objective-C Sound
//
//  Auto-generated from database on 11/4/12.
//  Manually modified by Aurelius Prochazka on 11/4/12 in the way iminfreq defaults to kfreq.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//
//  Implementation of Csound's wgbow:
//  http://www.csounds.com/manual/html/wgbow.html
//

#import "OCSBowedString.h"

@interface OCSBowedString () {
    OCSControl *kfreq;
    OCSControl *kpres;
    OCSControl *krat;
    OCSControl *kamp;
    OCSFTable *ifn;
    OCSControl *kvibf;
    OCSControl *kvamp;
    OCSConstant *iminfreq;
}
@end

@implementation OCSBowedString

- (instancetype)initWithFrequency:(OCSControl *)frequency
                         pressure:(OCSControl *)pressure
                         position:(OCSControl *)position
                        amplitude:(OCSControl *)amplitude
                vibratoShapeTable:(OCSFTable *)vibratoShapeTable
                 vibratoFrequency:(OCSControl *)vibratoFrequency
                 vibratoAmplitude:(OCSControl *)vibratoAmplitude
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
        iminfreq = [OCSConstant constantWithControl:kfreq];
    }
    return self;
}

- (void)setOptionalMinimumFrequency:(OCSConstant *)minimumFrequency {
	iminfreq = minimumFrequency;
}

- (NSString *)stringForCSD {
    return [NSString stringWithFormat:
            @"%@ wgbow %@, %@, %@, %@, %@, %@, %@, %@",
            self, kamp, kfreq, kpres, krat, kvibf, kvamp, ifn, iminfreq];
}

@end