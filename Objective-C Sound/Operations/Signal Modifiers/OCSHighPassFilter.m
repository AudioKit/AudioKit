//
//  OCSHighPassFilter.m
//  Objective-C Sound
//
//  Auto-generated from database on 11/6/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//
//  Implementation of Csound's atone:
//  http://www.csounds.com/manual/html/atone.html
//

#import "OCSHighPassFilter.h"

@interface OCSHighPassFilter () {
    OCSAudio *asig;
    OCSControl *khp;
}
@end

@implementation OCSHighPassFilter

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
            @"%@ atone %@, %@",
            self, asig, khp];
}

@end