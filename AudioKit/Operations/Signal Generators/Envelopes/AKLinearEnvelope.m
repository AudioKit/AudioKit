//
//  AKLinearEnvelope.m
//  AudioKit
//
//  Auto-generated on 2/18/15.
//  Customized by Aurelius Prochazka to add decayOnlyOnRelease
//  Copyright (c) 2015 Aurelius Prochazka. All rights reserved.
//
//  Implementation of Csound's linen:
//  http://www.csounds.com/manual/html/linen.html
//

#import "AKLinearEnvelope.h"
#import "AKManager.h"

@implementation AKLinearEnvelope {
    BOOL _decayNoteAfterStop;
}

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
        _amplitude = akp(1);
    }
    return self;
}

+ (instancetype)envelope
{
    return [[AKLinearEnvelope alloc] init];
}

- (void)setOptionalRiseTime:(AKConstant *)riseTime {
    _riseTime = riseTime;
}
- (void)setOptionalDecayTime:(AKConstant *)decayTime {
    _decayTime = decayTime;
}
- (void)setOptionalTotalDuration:(AKConstant *)totalDuration {
    _totalDuration = totalDuration;
}
- (void)setOptionalAmplitude:(AKParameter *)amplitude {
    _amplitude = amplitude;
}

- (void)decayOnlyOnRelease:(BOOL)decayOnRelease
{
    _decayNoteAfterStop = decayOnRelease;
}

- (NSString *)inlineStringForCSD
{
    NSMutableString *inlineCSDString = [[NSMutableString alloc] init];

    NSString *opcode = @"linen";
    if (_decayNoteAfterStop) opcode = @"linenr";

    [inlineCSDString appendFormat:@"%@(", opcode];
    [inlineCSDString appendString:[self inputsString]];
    [inlineCSDString appendString:@")"];

    return inlineCSDString;
}


- (NSString *)stringForCSD
{
    NSMutableString *csdString = [[NSMutableString alloc] init];

    
    NSString *opcode = @"linen";
    if (_decayNoteAfterStop) opcode = @"linenr";

    [csdString appendFormat:@"%@ %@ ", self, opcode];
    [csdString appendString:[self inputsString]];
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
