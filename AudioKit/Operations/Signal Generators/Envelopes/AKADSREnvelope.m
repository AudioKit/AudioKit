//
//  AKADSREnvelope.m
//  AudioKit
//
//  Auto-generated on 1/3/15.
//  Copyright (c) 2015 Aurelius Prochazka. All rights reserved.
//
//  Implementation of Csound's xadsr:
//  http://www.csounds.com/manual/html/xadsr.html
//

#import "AKADSREnvelope.h"
#import "AKManager.h"

@implementation AKADSREnvelope

- (instancetype)initWithAttackDuration:(AKConstant *)attackDuration
                         decayDuration:(AKConstant *)decayDuration
                          sustainLevel:(AKConstant *)sustainLevel
                       releaseDuration:(AKConstant *)releaseDuration
                                 delay:(AKConstant *)delay
{
    self = [super initWithString:[self operationName]];
    if (self) {
        _attackDuration = attackDuration;
        _decayDuration = decayDuration;
        _sustainLevel = sustainLevel;
        _releaseDuration = releaseDuration;
        _delay = delay;
    }
    return self;
}

- (instancetype)init
{
    self = [super initWithString:[self operationName]];
    if (self) {
        // Default Values
        _attackDuration = akp(0.1);
        _decayDuration = akp(0.1);
        _sustainLevel = akp(0.5);
        _releaseDuration = akp(1);
        _delay = akp(0);
    }
    return self;
}

+ (instancetype)envelope
{
    return [[AKADSREnvelope alloc] init];
}

- (void)setOptionalAttackDuration:(AKConstant *)attackDuration {
    _attackDuration = attackDuration;
}
- (void)setOptionalDecayDuration:(AKConstant *)decayDuration {
    _decayDuration = decayDuration;
}
- (void)setOptionalSustainLevel:(AKConstant *)sustainLevel {
    _sustainLevel = sustainLevel;
}
- (void)setOptionalReleaseDuration:(AKConstant *)releaseDuration {
    _releaseDuration = releaseDuration;
}
- (void)setOptionalDelay:(AKConstant *)delay {
    _delay = delay;
}

- (NSString *)stringForCSD {
    NSMutableString *csdString = [[NSMutableString alloc] init];

    [csdString appendFormat:@"%@ mxadsr ", self];

    [csdString appendFormat:@"%@, ", _attackDuration];
    
    [csdString appendFormat:@"%@, ", _decayDuration];
    
    [csdString appendFormat:@"%@, ", _sustainLevel];
    
    [csdString appendFormat:@"%@, ", _releaseDuration];
    
    [csdString appendFormat:@"%@", _delay];
    return csdString;
}

@end
