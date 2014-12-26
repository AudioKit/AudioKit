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
    AKParameter * _input;
}

- (instancetype)initWithInput:(AKParameter *)input
                     halfTime:(AKParameter *)halfTime
{
    self = [super initWithString:[self operationName]];
    if (self) {
        _input = input;
        _halfTime = halfTime;
    }
    return self;
}

- (instancetype)initWithInput:(AKParameter *)input
{
    self = [super initWithString:[self operationName]];
    if (self) {
        _input = input;
        // Default Values
        _halfTime = akp(1);
    }
    return self;
}

+ (instancetype)controlWithInput:(AKParameter *)input
{
    return [[AKPortamento alloc] initWithInput:input];
}

- (void)setOptionalHalfTime:(AKParameter *)halfTime {
    _halfTime = halfTime;
}

- (NSString *)stringForCSD {
    NSMutableString *csdString = [[NSMutableString alloc] init];

    [csdString appendFormat:@"%@ portk ", self];

    if ([_input isKindOfClass:[AKControl class]] ) {
        [csdString appendFormat:@"%@, ", _input];
    } else {
        [csdString appendFormat:@"AKControl(%@), ", _input];
    }

    if ([_halfTime isKindOfClass:[AKControl class]] ) {
        [csdString appendFormat:@"%@", _halfTime];
    } else {
        [csdString appendFormat:@"AKControl(%@)", _halfTime];
    }
return csdString;
}

@end
