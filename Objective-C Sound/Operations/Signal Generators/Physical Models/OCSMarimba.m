//
//  OCSMarimba.m
//  Objective-C Sound
//
//  Created by Aurelius Prochazka on 10/29/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//
//  Implementation of Csound's marimba:
//  http://www.csounds.com/manual/html/marimba.html
//

#import "OCSMarimba.h"

@interface OCSMarimba () {
    OCSConstant *ihrd;
    OCSConstant *ipos;
    OCSConstant *idec;
    OCSConstant *ifnmp;
    OCSConstant *ifnvib;
    OCSControl *kfreq;
    OCSControl *kamp;
    OCSControl *kvibf;
    OCSControl *kvamp;
    OCSConstant *idoubles;
    OCSConstant *itriples;
}
@end

@implementation OCSMarimba

- (id)initWithHardnesss:(OCSConstant *)hardnesss
               position:(OCSConstant *)position
              decayTime:(OCSConstant *)decayTime
     strikeImpulseTable:(OCSConstant *)strikeImpulseTable
      vibratoShapeTable:(OCSConstant *)vibratoShapeTable
              frequency:(OCSControl *)frequency
              amplitude:(OCSControl *)amplitude
       vibratoFrequency:(OCSControl *)vibratoFrequency
       vibratoAmplitude:(OCSControl *)vibratoAmplitude
{
    self = [super initWithString:[self operationName]];
    if (self) {
        ihrd = hardnesss;
        ipos = position;
        idec = decayTime;
        ifnmp = strikeImpulseTable;
        ifnvib = vibratoShapeTable;
        kfreq = frequency;
        kamp = amplitude;
        kvibf = vibratoFrequency;
        kvamp = vibratoAmplitude;
        
        idoubles = ocsp(40);
        itriples = ocsp(20);
        
        
    }
    return self;
}


- (void)setOptionalDoubleStrikePercentage:(OCSConstant *)doubleStrikePercentage {
	idoubles = doubleStrikePercentage;
}

- (void)setOptionalTripleStrikePercentage:(OCSConstant *)tripleStrikePercentage {
	itriples = tripleStrikePercentage;
}


- (NSString *)stringForCSD {
    return [NSString stringWithFormat:
            @"%@ marimba %@, %@, %@, %@, %@, %@, %@, %@, %@, %@, %@",
            self, kamp, kfreq, ihrd, ipos, ifnmp, kvibf, kvamp, ifnvib, idec, idoubles, itriples];
}
@end