//
//  AKLowPassControlFilter.m
//  AudioKit
//
//  Auto-generated on 12/25/14.
//  Copyright (c) 2014 Aurelius Prochazka. All rights reserved.
//
//  Implementation of Csound's tonek:
//  http://www.csounds.com/manual/html/tonek.html
//

#import "AKLowPassControlFilter.h"
#import "AKManager.h"

@implementation AKLowPassControlFilter
{
    AKParameter * _sourceControl;
}

- (instancetype)initWithSourceControl:(AKParameter *)sourceControl
                       halfPowerPoint:(AKParameter *)halfPowerPoint
{
    self = [super initWithString:[self operationName]];
    if (self) {
        _sourceControl = sourceControl;
        _halfPowerPoint = halfPowerPoint;
    }
    return self;
}

- (instancetype)initWithSourceControl:(AKParameter *)sourceControl
{
    self = [super initWithString:[self operationName]];
    if (self) {
        _sourceControl = sourceControl;
        // Default Values
        _halfPowerPoint = akp(100);
    }
    return self;
}

+ (instancetype)controlWithSourceControl:(AKParameter *)sourceControl
{
    return [[AKLowPassControlFilter alloc] initWithSourceControl:sourceControl];
}

- (void)setOptionalHalfPowerPoint:(AKParameter *)halfPowerPoint {
    _halfPowerPoint = halfPowerPoint;
}

- (NSString *)stringForCSD {
    NSMutableString *csdString = [[NSMutableString alloc] init];

    [csdString appendFormat:@"%@ tonek ", self];

    if ([_sourceControl isKindOfClass:[AKControl class]] ) {
        [csdString appendFormat:@"%@, ", _sourceControl];
    } else {
        [csdString appendFormat:@"AKControl(%@), ", _sourceControl];
    }

    if ([_halfPowerPoint isKindOfClass:[AKControl class]] ) {
        [csdString appendFormat:@"%@", _halfPowerPoint];
    } else {
        [csdString appendFormat:@"AKControl(%@)", _halfPowerPoint];
    }
return csdString;
}

@end
