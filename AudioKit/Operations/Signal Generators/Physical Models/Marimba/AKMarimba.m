//
//  AKMarimba.m
//  AudioKit
//
//  Created by Aurelius Prochazka on 10/31/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//
//  Implementation of Csound's marimba:
//  http://www.csounds.com/manual/html/marimba.html
//

#import "AKMarimba.h"


@interface AKMarimba () {
    AKControl *kfreq;
    AKConstant *idec;
    AKConstant *ihrd;
    AKConstant *ipos;
    AKControl *kamp;
    AKFTable *ifnvib;
    AKControl *kvibf;
    AKControl *kvamp;
    AKConstant *idoubles;
    AKConstant *itriples;
    AKSoundFileTable *fileTable;
}
@end

@implementation AKMarimba

- (instancetype)initWithFrequency:(AKControl *)frequency
                  maximumDuration:(AKConstant *)maximumDuration
                    stickHardness:(AKConstant *)stickHardness
                   strikePosition:(AKConstant *)strikePosition
                        amplitude:(AKControl *)amplitude
                vibratoShapeTable:(AKFTable *)vibratoShapeTable
                 vibratoFrequency:(AKControl *)vibratoFrequency
                 vibratoAmplitude:(AKControl *)vibratoAmplitude
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
        idoubles = akp(40);
        itriples = akp(20);
        
        NSString *file = [[NSBundle mainBundle] pathForResource:@"marmstk1" ofType:@"wav"];
        fileTable = [[AKSoundFileTable alloc] initWithFilename:file];
    }
    return self;
}

- (void)setOptionalDoubleStrikePercentage:(AKConstant *)doubleStrikePercentage {
	idoubles = doubleStrikePercentage;
}

- (void)setOptionalTripleStrikePercentage:(AKConstant *)tripleStrikePercentage {
	itriples = tripleStrikePercentage;
}

- (void)setOptionalStrikeImpulseTable:(AKSoundFileTable *)strikeImpulseTable {
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