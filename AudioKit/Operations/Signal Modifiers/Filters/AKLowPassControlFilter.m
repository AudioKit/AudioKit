//
//  AKLowPassControlFilter.m
//  AudioKit
//
//  Auto-generated from scripts by Aurelius Prochazka on 11/6/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//
//  Implementation of Csound's tone:
//  http://www.csounds.com/manual/html/tone.html
//

#import "AKLowPassControlFilter.h"

@interface AKLowPassControlFilter () {
    AKControl *ksig;
    AKControl *khp;
}
@end

@implementation AKLowPassControlFilter

- (instancetype)initWithSourceControl:(AKControl *)sourceControl
                       halfPowerPoint:(AKControl *)halfPowerPoint
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