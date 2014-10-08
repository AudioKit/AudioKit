//
//  AKVibes.m
//  AudioKit
//
//  Auto-generated from scripts by Aurelius Prochazka on 11/3/12.
//  Improved from database version by Aurelius Prochazka on 12/27/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//
//  Implementation of Csound's vibes:
//  http://www.csounds.com/manual/html/vibes.html
//

#import "AKVibes.h"
#import "AKSoundFileTable.h"

@implementation AKVibes
{
    AKControl *kfreq;
    AKConstant *idec;
    AKConstant *ihrd;
    AKConstant *ipos;
    AKControl *kamp;
    AKFTable *ifnvib;
    AKControl *kvibf;
    AKControl *kvamp;
}

- (instancetype)initWithFrequency:(AKControl *)frequency
                  maximumDuration:(AKConstant *)maximumDuration
                    stickHardness:(AKConstant *)stickHardness
                   strikePosition:(AKConstant *)strikePosition
                        amplitude:(AKControl *)amplitude
                tremoloShapeTable:(AKFTable *)tremoloShapeTable
                 tremoloFrequency:(AKControl *)tremoloFrequency
                 tremoloAmplitude:(AKControl *)tremoloAmplitude
{
    self = [super initWithString:[self operationName]];
    if (self) {
        kfreq = frequency;
        idec = maximumDuration;
        ihrd = stickHardness;
        ipos = strikePosition;
        kamp = amplitude;
        ifnvib = tremoloShapeTable;
        kvibf = tremoloFrequency;
        kvamp = tremoloAmplitude;
    }
    return self;
}

- (NSString *)stringForCSD {
    NSString *file;
    file = [[NSBundle mainBundle] pathForResource:@"marmstk1" ofType:@"wav"];
    AKSoundFileTable *fileTable;
    fileTable = [[AKSoundFileTable alloc] initWithFilename:file];
    
    return [NSString stringWithFormat:
            @"%@\n"
            @"%@ vibes %@, %@, %@, %@, %@, %@, %@, %@",
            [fileTable stringForCSD],
            self, kamp, kfreq, ihrd, ipos, kvibf, kvamp, ifnvib, idec];
}

@end