//
//  OCSVibes.m
//  Objective-C Sound
//
//  Auto-generated from database on 11/3/12.
//  Improved from database version by Aurelius Prochazka on 12/27/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//
//  Implementation of Csound's vibes:
//  http://www.csounds.com/manual/html/vibes.html
//

#import "OCSVibes.h"
#import "OCSSoundFileTable.h"

@interface OCSVibes () {
    OCSControl *kfreq;
    OCSConstant *idec;
    OCSConstant *ihrd;
    OCSConstant *ipos;
    OCSControl *kamp;
    OCSFTable *ifnvib;
    OCSControl *kvibf;
    OCSControl *kvamp;
}
@end

@implementation OCSVibes

- (instancetype)initWithFrequency:(OCSControl *)frequency
                  maximumDuration:(OCSConstant *)maximumDuration
                    stickHardness:(OCSConstant *)stickHardness
                   strikePosition:(OCSConstant *)strikePosition
                        amplitude:(OCSControl *)amplitude
                tremoloShapeTable:(OCSFTable *)tremoloShapeTable
                 tremoloFrequency:(OCSControl *)tremoloFrequency
                 tremoloAmplitude:(OCSControl *)tremoloAmplitude
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
    OCSSoundFileTable *fileTable;
    fileTable = [[OCSSoundFileTable alloc] initWithFilename:file];
    
    return [NSString stringWithFormat:
            @"%@\n"
            @"%@ vibes %@, %@, %@, %@, %@, %@, %@, %@",
            [fileTable stringForCSD],
            self, kamp, kfreq, ihrd, ipos, kvibf, kvamp, ifnvib, idec];
}

@end