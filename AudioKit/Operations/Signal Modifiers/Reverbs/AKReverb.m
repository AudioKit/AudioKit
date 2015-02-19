//
//  AKReverb.m
//  AudioKit
//
//  Auto-generated on 2/19/15.
//  Copyright (c) 2015 Aurelius Prochazka. All rights reserved.
//
//  Implementation of Csound's reverbsc:
//  http://www.csounds.com/manual/html/reverbsc.html
//

#import "AKReverb.h"
#import "AKManager.h"

@implementation AKReverb
{
    AKParameter * _leftInput;
    AKParameter * _rightInput;
}

- (instancetype)initWithInput:(AKParameter *)input
                     feedback:(AKParameter *)feedback
              cutoffFrequency:(AKParameter *)cutoffFrequency
{
    self = [super initWithString:[self operationName]];
    if (self) {
        _leftInput = input;
        _rightInput = input;
        _feedback = feedback;
        _cutoffFrequency = cutoffFrequency;
        [self setUpConnections];
    }
    return self;
}

- (instancetype)initWithInput:(AKParameter *)input
{
    self = [super initWithString:[self operationName]];
    if (self) {
        _leftInput = input;
        _rightInput = input;
        // Default Values
        _feedback = akp(0.6);
        _cutoffFrequency = akp(4000);
        [self setUpConnections];
    }
    return self;
}

+ (instancetype)reverbWithInput:(AKParameter *)input
{
    return [[AKReverb alloc] initWithInput:input];
}


- (instancetype)initWithStereoInput:(AKStereoAudio *)input
                           feedback:(AKParameter *)feedback
                    cutoffFrequency:(AKParameter *)cutoffFrequency
{
    self = [super initWithString:[self operationName]];
    if (self) {
        _leftInput = input.leftOutput;
        _rightInput = input.rightOutput;
        _feedback = feedback;
        _cutoffFrequency = cutoffFrequency;
        [self setUpConnections];
    }
    return self;
}

- (instancetype)initWithStereoInput:(AKStereoAudio *)input
{
    self = [super initWithString:[self operationName]];
    if (self) {
        _leftInput = input.leftOutput;
        _rightInput = input.rightOutput;
        // Default Values
        _feedback = akp(0.6);
        _cutoffFrequency = akp(4000);
        [self setUpConnections];
    }
    return self;
}

+ (instancetype)reverbWithStereoInput:(AKStereoAudio *)input
{
    return [[AKReverb alloc] initWithStereoInput:input];
}
- (void)setFeedback:(AKParameter *)feedback {
    _feedback = feedback;
    [self setUpConnections];
}

- (void)setOptionalFeedback:(AKParameter *)feedback {
    [self setFeedback:feedback];
}

- (void)setCutoffFrequency:(AKParameter *)cutoffFrequency {
    _cutoffFrequency = cutoffFrequency;
    [self setUpConnections];
}

- (void)setOptionalCutoffFrequency:(AKParameter *)cutoffFrequency {
    [self setCutoffFrequency:cutoffFrequency];
}


- (void)setUpConnections
{
    self.state = @"connectable";
    self.dependencies = @[_leftInput, _rightInput, _feedback, _cutoffFrequency];
}

- (NSString *)inlineStringForCSD
{
    NSMutableString *inlineCSDString = [[NSMutableString alloc] init];

    [inlineCSDString appendString:@"reverbsc("];
    [inlineCSDString appendString:[self inputsString]];
    [inlineCSDString appendString:@")"];

    return inlineCSDString;
}


- (NSString *)stringForCSD
{
    NSMutableString *csdString = [[NSMutableString alloc] init];

    [csdString appendFormat:@"%@ reverbsc ", self];
    [csdString appendString:[self inputsString]];
    return csdString;
}

- (NSString *)inputsString {
    NSMutableString *inputsString = [[NSMutableString alloc] init];

    
    if ([_leftInput class] == [AKAudio class]) {
        [inputsString appendFormat:@"%@, ", _leftInput];
    } else {
        [inputsString appendFormat:@"AKAudio(%@), ", _leftInput];
    }

    if ([_rightInput class] == [AKAudio class]) {
        [inputsString appendFormat:@"%@, ", _rightInput];
    } else {
        [inputsString appendFormat:@"AKAudio(%@), ", _rightInput];
    }

    if ([_feedback class] == [AKControl class]) {
        [inputsString appendFormat:@"%@, ", _feedback];
    } else {
        [inputsString appendFormat:@"AKControl(%@), ", _feedback];
    }

    if ([_cutoffFrequency class] == [AKControl class]) {
        [inputsString appendFormat:@"%@", _cutoffFrequency];
    } else {
        [inputsString appendFormat:@"AKControl(%@)", _cutoffFrequency];
    }
    [inputsString appendString:@", 0, 0, tival()"];
    return inputsString;
}

@end
