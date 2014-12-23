//
//  AKPhasingControl.m
//  AudioKit
//
//  Auto-generated on 12/23/14.
//  Copyright (c) 2014 Aurelius Prochazka. All rights reserved.
//
//  Implementation of Csound's phasor:
//  http://www.csounds.com/manual/html/phasor.html
//

#import "AKPhasingControl.h"
#import "AKManager.h"

@implementation AKPhasingControl

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
        _frequency = akp(1);    
        _phase = akp(0);    
    }
    return self;
}

+ (instancetype)control
{
    return [[AKPhasingControl alloc] init];
}

- (void)setOptionalFrequency:(AKParameter *)frequency {
    _frequency = frequency;
}
- (void)setOptionalPhase:(AKConstant *)phase {
    _phase = phase;
}

- (NSString *)stringForCSD {
    return [NSString stringWithFormat:
            @"%@ phasor AKControl(%@), %@",
            self,
            _frequency,
            _phase];
}

@end
