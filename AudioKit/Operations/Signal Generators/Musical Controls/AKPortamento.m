//
//  AKPortamento.m
//  AudioKit
//
//  Auto-generated on 12/23/14.
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
    return [NSString stringWithFormat:
            @"%@ portk AKControl(%@), AKControl(%@)",
            self,
            _controlSource,
            _halfTime];
}

@end
