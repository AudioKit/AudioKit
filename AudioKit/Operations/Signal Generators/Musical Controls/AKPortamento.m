//
//  AKPortamento.m
//  AudioKit
//
//  Auto-generated on 12/25/14.
//  Copyright (c) 2014 Aurelius Prochazka. All rights reserved.
//
//  Implementation of Csound's portk:
//  http://www.csounds.com/manual/html/portk.html
//

#import "AKPortamento.h"
#import "AKManager.h"

@implementation AKPortamento
{
    AKParameter * _controlSource;
}

- (instancetype)initWithControlSource:(AKParameter *)controlSource
                             halfTime:(AKParameter *)halfTime
{
    self = [super initWithString:[self operationName]];
    if (self) {
        _controlSource = controlSource;
        _halfTime = halfTime;
    }
    return self;
}

- (instancetype)initWithControlSource:(AKParameter *)controlSource
{
    self = [super initWithString:[self operationName]];
    if (self) {
        _controlSource = controlSource;
        // Default Values
        _halfTime = akp(1);
    }
    return self;
}

+ (instancetype)controlWithControlSource:(AKParameter *)controlSource
{
    return [[AKPortamento alloc] initWithControlSource:controlSource];
}

- (void)setOptionalHalfTime:(AKParameter *)halfTime {
    _halfTime = halfTime;
}

- (NSString *)stringForCSD {
    NSMutableString *csdString = [[NSMutableString alloc] init];

    [csdString appendFormat:@"%@ portk ", self];

    if ([_controlSource isKindOfClass:[AKControl class]] ) {
        [csdString appendFormat:@"%@, ", _controlSource];
    } else {
        [csdString appendFormat:@"AKControl(%@), ", _controlSource];
    }

    if ([_halfTime isKindOfClass:[AKControl class]] ) {
        [csdString appendFormat:@"%@", _halfTime];
    } else {
        [csdString appendFormat:@"AKControl(%@)", _halfTime];
    }
return csdString;
}

@end
