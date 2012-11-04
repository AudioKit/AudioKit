//
//  OCSVibes.m
//  Objective-C Sound
//
//  Auto-generated from database on 11/3/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//
//  Implementation of Csound's vibes:
//  http://www.csounds.com/manual/html/vibes.html
//

#import "OCSVibes.h"

@interface OCSVibes () {
    OCSControl *kfreq;
    OCSConstant *idec;
    OCSConstant *ihrd;
    OCSFTable *ifnmp;
    OCSConstant *ipos;
    OCSControl *kamp;
    OCSFTable *ifnvib;
    OCSControl *kvibf;
    OCSControl *kvamp;
}
@end

@implementation OCSVibes

- (id)initWithFrequency:(OCSControl *)frequency
        maximumDuration:(OCSConstant *)maximumDuration
          stickHardness:(OCSConstant *)stickHardness
     strikeImpulseTable:(OCSFTable *)strikeImpulseTable
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
        ifnmp = strikeImpulseTable;
        ipos = strikePosition;
        kamp = amplitude;
        ifnvib = tremoloShapeTable;
        kvibf = tremoloFrequency;
        kvamp = tremoloAmplitude;
    }
    return self;
}

- (NSString *)stringForCSD {
    return [NSString stringWithFormat:
            @"%@ vibes %@, %@, %@, %@, %@, %@, %@, %@, %@",
            self, kamp, kfreq, ihrd, ipos, ifnmp, kvibf, kvamp, ifnvib, idec];
}

@end