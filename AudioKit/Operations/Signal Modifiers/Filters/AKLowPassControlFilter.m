//
//  AKLowPassControlFilter.m
//  AudioKit
//
//  Auto-generated on 12/22/14.
//  Copyright (c) 2014 Aurelius Prochazka. All rights reserved.
//
//  Implementation of Csound's tonek:
//  http://www.csounds.com/manual/html/tonek.html
//

#import "AKLowPassControlFilter.h"
#import "AKManager.h"

@implementation AKLowPassControlFilter
{
    AKControl * _sourceControl;
}

- (instancetype)initWithSourceControl:(AKControl *)sourceControl
                       halfPowerPoint:(AKControl *)halfPowerPoint
{
    self = [super initWithString:[self operationName]];
    if (self) {
        _sourceControl = sourceControl;
        _halfPowerPoint = halfPowerPoint;
    }
    return self;
}

- (instancetype)initWithSourceControl:(AKControl *)sourceControl
{
    self = [super initWithString:[self operationName]];
    if (self) {
        _sourceControl = sourceControl;
        // Default Values
        _halfPowerPoint = akp(100);    
    }
    return self;
}

+ (instancetype)controlWithSourceControl:(AKControl *)sourceControl
{
    return [[AKLowPassControlFilter alloc] initWithSourceControl:sourceControl];
}

- (void)setOptionalHalfPowerPoint:(AKControl *)halfPowerPoint {
    _halfPowerPoint = halfPowerPoint;
}

- (NSString *)stringForCSD {
    return [NSString stringWithFormat:
            @"%@ tonek %@, %@",
            self,
            _sourceControl,
            _halfPowerPoint];
}

@end
