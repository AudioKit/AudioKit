//
//  OCSLowPassFilter.m
//  Objective-C Sound
//
//  Auto-generated from database on 11/6/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//
//  Implementation of Csound's tone:
//  http://www.csounds.com/manual/html/tone.html
//

#import "OCSLowPassFilter.h"

@interface OCSLowPassFilter () {
    OCSAudio *asig;
    OCSControl *khp;
}
@end

@implementation OCSLowPassFilter

- (id)initWithSourceAudio:(OCSAudio *)sourceAudio
           halfPowerPoint:(OCSControl *)halfPowerPoint
{
    self = [super initWithString:[self operationName]];
    if (self) {
        asig = sourceAudio;
        khp = halfPowerPoint;
    }
    return self;
}

- (NSString *)stringForCSD {
    return [NSString stringWithFormat:
            @"%@ tone %@, %@",
            self, asig, khp];
}

@end