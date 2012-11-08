//
//  OCSLowPassControlFilter.m
//  Objective-C Sound
//
//  Auto-generated from database on 11/6/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//
//  Implementation of Csound's tone:
//  http://www.csounds.com/manual/html/tone.html
//

#import "OCSLowPassControlFilter.h"

@interface OCSLowPassControlFilter () {
    OCSControl *ksig;
    OCSControl *khp;
}
@end

@implementation OCSLowPassControlFilter

- (id)initWithSourceControl:(OCSControl *)sourceControl
             halfPowerPoint:(OCSControl *)halfPowerPoint
{
    self = [super initWithString:[self operationName]];
    if (self) {
        ksig = sourceControl;
        khp = halfPowerPoint;
    }
    return self;
}

- (NSString *)stringForCSD {
    return [NSString stringWithFormat:
            @"%@ tonek %@, %@",
            self, ksig, khp];
}

@end