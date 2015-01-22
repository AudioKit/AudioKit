//
//  AKPhasorControl.m
//  EasyExponentialCurves
//
//  Created by Adam Boulanger on 1/21/15.
//  Copyright (c) 2015 Adam Boulanger. All rights reserved.
//

#import "AKPhasorControl.h"

@implementation AKPhasorControl

- (instancetype)initWithFrequency:(AKParameter *)frequency
                            phase:(AKConstant *)phase
{
    self = [super initWithString:[self operationName]];
    if (self) {
        _frequency = frequency;
        _phase = phase;
    }
    return self;
}

- (instancetype)init
{
    self = [super initWithString:[self operationName]];
    if (self) {
        // Default Values
        _frequency = akp(440);
        _phase = akp(0);
    }
    return self;
}

+ (instancetype)phasor
{
    return [[AKPhasorControl alloc] init];
}

- (void)setOptionalFrequency:(AKParameter *)frequency {
    _frequency = frequency;
}
- (void)setOptionalPhase:(AKConstant *)phase {
    _phase = phase;
}

- (NSString *)stringForCSD {
    NSMutableString *csdString = [[NSMutableString alloc] init];
    
    [csdString appendFormat:@"%@ phasor ", self];
    
    [csdString appendFormat:@"%@, ", _frequency];
    
    [csdString appendFormat:@"%@", _phase];
    return csdString;
}

@end
