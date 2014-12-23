//
//  AKPortamento.m
//  AudioKit
//
//  Auto-generated on 12/22/14.
//  Copyright (c) 2014 Aurelius Prochazka. All rights reserved.
//
//  Implementation of Csound's portk:
//  http://www.csounds.com/manual/html/portk.html
//

#import "AKPortamento.h"
#import "AKManager.h"

@implementation AKPortamento
{
    AKControl * _controlSource;
}

- (instancetype)initWithControlSource:(AKControl *)controlSource
                             halfTime:(AKControl *)halfTime
{
    self = [super initWithString:[self operationName]];
    if (self) {
        _controlSource = controlSource;
        _halfTime = halfTime;
    }
    return self;
}

- (instancetype)initWithControlSource:(AKControl *)controlSource
{
    self = [super initWithString:[self operationName]];
    if (self) {
        _controlSource = controlSource;
        // Default Values
        _halfTime = akp(1);    
    }
    return self;
}

+ (instancetype)controlWithControlSource:(AKControl *)controlSource
{
    return [[AKPortamento alloc] initWithControlSource:controlSource];
}

- (void)setOptionalHalfTime:(AKControl *)halfTime {
    _halfTime = halfTime;
}

- (NSString *)stringForCSD {
    return [NSString stringWithFormat:
            @"%@ portk %@, %@",
            self,
            _controlSource,
            _halfTime];
}

@end
