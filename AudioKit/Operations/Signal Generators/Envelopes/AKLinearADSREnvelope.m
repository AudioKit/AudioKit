//
//  AKLinearADSREnvelope.m
//  AudioKit
//
//  Auto-generated on 2/19/15.  Customized to skip on tied values.
//  Copyright (c) 2015 Aurelius Prochazka. All rights reserved.
//
//  Implementation of Csound's madsr:
//  http://www.csounds.com/manual/html/madsr.html
//

#import "AKLinearADSREnvelope.h"
#import "AKManager.h"

@implementation AKLinearADSREnvelope

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
        [self setUpConnections];
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
        [self setUpConnections];
    }
    return self;
}

+ (instancetype)envelope
{
    return [[AKLinearADSREnvelope alloc] init];
}

- (void)setAttackDuration:(AKConstant *)attackDuration {
    _attackDuration = attackDuration;
    [self setUpConnections];
}

- (void)setOptionalAttackDuration:(AKConstant *)attackDuration {
    [self setAttackDuration:attackDuration];
}

- (void)setDecayDuration:(AKConstant *)decayDuration {
    _decayDuration = decayDuration;
    [self setUpConnections];
}

- (void)setOptionalDecayDuration:(AKConstant *)decayDuration {
    [self setDecayDuration:decayDuration];
}

- (void)setSustainLevel:(AKConstant *)sustainLevel {
    _sustainLevel = sustainLevel;
    [self setUpConnections];
}

- (void)setOptionalSustainLevel:(AKConstant *)sustainLevel {
    [self setSustainLevel:sustainLevel];
}

- (void)setReleaseDuration:(AKConstant *)releaseDuration {
    _releaseDuration = releaseDuration;
    [self setUpConnections];
}

- (void)setOptionalReleaseDuration:(AKConstant *)releaseDuration {
    [self setReleaseDuration:releaseDuration];
}

- (void)setDelay:(AKConstant *)delay {
    _delay = delay;
    [self setUpConnections];
}

- (void)setOptionalDelay:(AKConstant *)delay {
    [self setDelay:delay];
}


- (void)setUpConnections
{
    self.state = @"connectable";
    self.dependencies = @[_attackDuration, _decayDuration, _sustainLevel, _releaseDuration, _delay];
}

- (NSString *)inlineStringForCSD
{
    NSMutableString *inlineCSDString = [[NSMutableString alloc] init];

    [inlineCSDString appendString:@"madsr("];
    [inlineCSDString appendString:[self inputsString]];
    [inlineCSDString appendString:@")"];

    return inlineCSDString;
}


- (NSString *)stringForCSD
{
    NSMutableString *csdString = [[NSMutableString alloc] init];

    [csdString appendFormat:@"tigoto skip%@\n", self];
    [csdString appendFormat:@"%@ madsr ", self];
    [csdString appendString:[self inputsString]];
    [csdString appendFormat:@"\nskip%@:\n", self];
    return csdString;
}

- (NSString *)inputsString {
    NSMutableString *inputsString = [[NSMutableString alloc] init];

    
    [inputsString appendFormat:@"%@, ", _attackDuration];
    
    [inputsString appendFormat:@"%@, ", _decayDuration];
    
    [inputsString appendFormat:@"%@, ", _sustainLevel];
    
    [inputsString appendFormat:@"%@, ", _releaseDuration];
    
    [inputsString appendFormat:@"%@", _delay];
    return inputsString;
}

@end
