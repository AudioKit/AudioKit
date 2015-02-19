//
//  AKSimpleWaveGuideModel.m
//  AudioKit
//
//  Auto-generated on 2/19/15.
//  Copyright (c) 2015 Aurelius Prochazka. All rights reserved.
//
//  Implementation of Csound's wguide1:
//  http://www.csounds.com/manual/html/wguide1.html
//

#import "AKSimpleWaveGuideModel.h"
#import "AKManager.h"

@implementation AKSimpleWaveGuideModel
{
    AKParameter * _input;
}

- (instancetype)initWithInput:(AKParameter *)input
                    frequency:(AKParameter *)frequency
                       cutoff:(AKParameter *)cutoff
                     feedback:(AKParameter *)feedback
{
    self = [super initWithString:[self operationName]];
    if (self) {
        _input = input;
        _frequency = frequency;
        _cutoff = cutoff;
        _feedback = feedback;
        [self setUpConnections];
}
    return self;
}

- (instancetype)initWithInput:(AKParameter *)input
{
    self = [super initWithString:[self operationName]];
    if (self) {
        _input = input;
        // Default Values
        _frequency = akp(440);
        _cutoff = akp(3000);
        _feedback = akp(0.8);
        [self setUpConnections];
    }
    return self;
}

+ (instancetype)modelWithInput:(AKParameter *)input
{
    return [[AKSimpleWaveGuideModel alloc] initWithInput:input];
}

- (void)setFrequency:(AKParameter *)frequency {
    _frequency = frequency;
    [self setUpConnections];
}

- (void)setOptionalFrequency:(AKParameter *)frequency {
    [self setFrequency:frequency];
}

- (void)setCutoff:(AKParameter *)cutoff {
    _cutoff = cutoff;
    [self setUpConnections];
}

- (void)setOptionalCutoff:(AKParameter *)cutoff {
    [self setCutoff:cutoff];
}

- (void)setFeedback:(AKParameter *)feedback {
    _feedback = feedback;
    [self setUpConnections];
}

- (void)setOptionalFeedback:(AKParameter *)feedback {
    [self setFeedback:feedback];
}


- (void)setUpConnections
{
    self.state = @"connectable";
    self.dependencies = @[_input, _frequency, _cutoff, _feedback];
}

- (NSString *)inlineStringForCSD
{
    NSMutableString *inlineCSDString = [[NSMutableString alloc] init];

    [inlineCSDString appendString:@"wguide1("];
    [inlineCSDString appendString:[self inputsString]];
    [inlineCSDString appendString:@")"];

    return inlineCSDString;
}


- (NSString *)stringForCSD
{
    NSMutableString *csdString = [[NSMutableString alloc] init];

    [csdString appendFormat:@"%@ wguide1 ", self];
    [csdString appendString:[self inputsString]];
    return csdString;
}

- (NSString *)inputsString {
    NSMutableString *inputsString = [[NSMutableString alloc] init];

    
    if ([_input class] == [AKAudio class]) {
        [inputsString appendFormat:@"%@, ", _input];
    } else {
        [inputsString appendFormat:@"AKAudio(%@), ", _input];
    }

    [inputsString appendFormat:@"%@, ", _frequency];
    
    if ([_cutoff class] == [AKControl class]) {
        [inputsString appendFormat:@"%@, ", _cutoff];
    } else {
        [inputsString appendFormat:@"AKControl(%@), ", _cutoff];
    }

    if ([_feedback class] == [AKControl class]) {
        [inputsString appendFormat:@"%@", _feedback];
    } else {
        [inputsString appendFormat:@"AKControl(%@)", _feedback];
    }
return inputsString;
}

@end
