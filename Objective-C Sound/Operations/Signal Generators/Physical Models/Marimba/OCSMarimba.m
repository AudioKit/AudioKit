//
//  OCSMarimba.m
//  Objective-C Sound
//
//  Created by Aurelius Prochazka on 10/31/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//
//  Implementation of Csound's marimba:
//  http://www.csounds.com/manual/html/marimba.html
//

#import "OCSMarimba.h"


@interface OCSMarimba () {
    OCSControl *kfreq;
    OCSConstant *idec;
    OCSConstant *ihrd;
    OCSConstant *ipos;
    OCSControl *kamp;
    OCSFTable *ifnvib;
    OCSControl *kvibf;
    OCSControl *kvamp;
    OCSConstant *idoubles;
    OCSConstant *itriples;
    OCSSoundFileTable *fileTable;
}
@end

@implementation OCSMarimba

- (id)initWithFrequency:(OCSControl *)frequency
        maximumDuration:(OCSConstant *)maximumDuration
          stickHardness:(OCSConstant *)stickHardness
         strikePosition:(OCSConstant *)strikePosition
              amplitude:(OCSControl *)amplitude
      vibratoShapeTable:(OCSFTable *)vibratoShapeTable
       vibratoFrequency:(OCSControl *)vibratoFrequency
       vibratoAmplitude:(OCSControl *)vibratoAmplitude
{
    self = [super initWithString:[self operationName]];
    if (self) {
        kfreq = frequency;
        idec = maximumDuration;
        ihrd = stickHardness;
        ipos = strikePosition;
        kamp = amplitude;
        ifnvib = vibratoShapeTable;
        kvibf = vibratoFrequency;
        kvamp = vibratoAmplitude;
        idoubles = ocsp(40);
        itriples = ocsp(20);
        
        NSString *file = [[NSBundle mainBundle] pathForResource:@"marmstk1" ofType:@"wav"];
        fileTable = [[OCSSoundFileTable alloc] initWithFilename:file];
    }
    return self;
}

- (void)setOptionalDoubleStrikePercentage:(OCSConstant *)doubleStrikePercentage {
	idoubles = doubleStrikePercentage;
}

- (void)setOptionalTripleStrikePercentage:(OCSConstant *)tripleStrikePercentage {
	itriples = tripleStrikePercentage;
}

- (void)setOptionalStrikeImpulseTable:(OCSSoundFileTable *)strikeImpulseTable {
    fileTable = strikeImpulseTable;
}



- (NSString *)stringForCSD {
    return [NSString stringWithFormat:
            @"%@\n"
            @"%@ marimba %@, %@, %@, %@, %@, %@, %@, %@, %@, %@, %@",
            [fileTable stringForCSD],
            self, kamp, kfreq, ihrd, ipos, fileTable, kvibf, kvamp, ifnvib, idec, idoubles, itriples];
}

@end