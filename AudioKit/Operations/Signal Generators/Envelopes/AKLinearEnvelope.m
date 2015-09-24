//
//  AKLinearEnvelope.m
//  AudioKit
//
//  Auto-generated on 2/18/15.  Customized to skip on tied values.
//  Copyright (c) 2015 Aurelius Prochazka. All rights reserved.
//
//  Implementation of Csound's linen:
//  http://www.csounds.com/manual/html/linen.html
//

#import "AKLinearEnvelope.h"
#import "AKManager.h"

@implementation AKLinearEnvelope

- (instancetype)initWithRiseTime:(AKConstant *)riseTime
                       decayTime:(AKConstant *)decayTime
                   totalDuration:(AKConstant *)totalDuration
                       amplitude:(AKParameter *)amplitude
{
    self = [super initWithString:[self operationName]];
    if (self) {
        _riseTime = riseTime;
        _decayTime = decayTime;
        _totalDuration = totalDuration;
        _amplitude = amplitude;
        [self setUpConnections];
}
    return self;
}

- (instancetype)init
{
    self = [super initWithString:[self operationName]];
    if (self) {
        // Default Values
        _riseTime = akp(0.33);
        _decayTime = akp(0.33);
        _totalDuration = akp(1);
        _amplitude = akp(0.5);
        [self setUpConnections];
    }
    return self;
}

+ (instancetype)envelope
{
    return [[AKLinearEnvelope alloc] init];
}

- (void)setRiseTime:(AKConstant *)riseTime {
    _riseTime = riseTime;
    [self setUpConnections];
}

- (void)setOptionalRiseTime:(AKConstant *)riseTime {
    [self setRiseTime:riseTime];
}

- (void)setDecayTime:(AKConstant *)decayTime {
    _decayTime = decayTime;
    [self setUpConnections];
}

- (void)setOptionalDecayTime:(AKConstant *)decayTime {
    [self setDecayTime:decayTime];
}

- (void)setTotalDuration:(AKConstant *)totalDuration {
    _totalDuration = totalDuration;
    [self setUpConnections];
}

- (void)setOptionalTotalDuration:(AKConstant *)totalDuration {
    [self setTotalDuration:totalDuration];
}

- (void)setAmplitude:(AKParameter *)amplitude {
    _amplitude = amplitude;
    [self setUpConnections];
}

- (void)setOptionalAmplitude:(AKParameter *)amplitude {
    [self setAmplitude:amplitude];
}

- (void)setUpConnections
{
    self.state = @"connectable";
    self.dependencies = @[_riseTime, _decayTime, _totalDuration, _amplitude];
}

- (NSString *)inlineStringForCSD
{
    NSMutableString *inlineCSDString = [[NSMutableString alloc] init];
    
    [inlineCSDString appendString:@"linen("];
    [inlineCSDString appendString:[self inputsString]];
    [inlineCSDString appendString:@")"];

    return inlineCSDString;
}


- (NSString *)stringForCSD
{
    NSMutableString *csdString = [[NSMutableString alloc] init];

    [csdString appendFormat:@"tigoto skip%@\n", self];
    [csdString appendFormat:@"%@ linen ", self];
    [csdString appendString:[self inputsString]];
    [csdString appendFormat:@"\nskip%@:\n", self];
    return csdString;
}

- (NSString *)inputsString {
    NSMutableString *inputsString = [[NSMutableString alloc] init];

    
    if ([_amplitude class] == [AKControl class]) {
        [inputsString appendFormat:@"%@, ", _amplitude];
    } else {
        [inputsString appendFormat:@"AKControl(%@), ", _amplitude];
    }

    [inputsString appendFormat:@"%@, ", _riseTime];
    
    [inputsString appendFormat:@"%@, ", _totalDuration];
    
    [inputsString appendFormat:@"%@", _decayTime];
    return inputsString;
}

@end
