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

- (instancetype)initWithPresetDefaultReverbWithInput:(AKParameter *)input;
{
    return [self initWithInput:input];
}

+ (instancetype)presetDefaultReverbWithInput:(AKParameter *)input
{
    return [[AKReverb alloc] initWithInput:input];
}

- (instancetype)initWithPresetSmallHallReverbWithInput:(AKParameter *)input;
{
    self = [super initWithString:[self operationName]];
    if (self) {
        _leftInput = input;
        _rightInput = input;
        // 'Small Hall' Values
        _feedback = akp(0.8);
        _cutoffFrequency = akp(4000);
        [self setUpConnections];
    }
    return self;
}

+ (instancetype)presetSmallHallReverbWithInput:(AKParameter *)input
{
    return [[AKReverb alloc] initWithPresetSmallHallReverbWithInput:input];
}

- (instancetype)initWithPresetLargeHallReverbWithInput:(AKParameter *)input;
{
    self = [super initWithString:[self operationName]];
    if (self) {
        _leftInput = input;
        _rightInput = input;
        // 'Large Hall' Values
        _feedback = akp(0.9);
        _cutoffFrequency = akp(4000);
        [self setUpConnections];
    }
    return self;
}

+ (instancetype)presetLargeHallReverbWithInput:(AKParameter *)input
{
    return [[AKReverb alloc] initWithPresetLargeHallReverbWithInput:input];
}

- (instancetype)initWithPresetMuffledCanReverbWithInput:(AKParameter *)input;
{
    self = [super initWithString:[self operationName]];
    if (self) {
        _leftInput = input;
        _rightInput = input;
        // 'Muffled Can' Values
        _feedback = akp(0.8);
        _cutoffFrequency = akp(1200);
        [self setUpConnections];
    }
    return self;
}

+ (instancetype)presetMuffledCanReverbWithInput:(AKParameter *)input;
{
    return [[AKReverb alloc] initWithPresetMuffledCanReverbWithInput:input];
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

- (instancetype)initWithPresetDefaultReverbWithStereoInput:(AKStereoAudio *)input;
{
    return [self initWithStereoInput:input];
}

+ (instancetype)presetDefaultReverbWithStereoInput:(AKStereoAudio *)input
{
    return [[AKReverb alloc] initWithStereoInput:input];
}

- (instancetype)initWithPresetSmallHallReverbWithStereoInput:(AKStereoAudio *)input;
{
    self = [super initWithString:[self operationName]];
    if (self) {
        _leftInput = input.leftOutput;
        _rightInput = input.rightOutput;
        // 'Small Hall' Values
        _feedback = akp(0.8);
        _cutoffFrequency = akp(4000);
        [self setUpConnections];
    }
    return self;
}

+ (instancetype)presetSmallHallReverbWithStereoInput:(AKStereoAudio *)input;
{
    return [[AKReverb alloc] initWithPresetSmallHallReverbWithStereoInput:input];
}

- (instancetype)initWithPresetLargeHallReverbWithStereoInput:(AKStereoAudio *)input;
{
    self = [super initWithString:[self operationName]];
    if (self) {
        _leftInput = input.leftOutput;
        _rightInput = input.rightOutput;
        // 'Large Hall' Values
        _feedback = akp(0.9);
        _cutoffFrequency = akp(4000);
        [self setUpConnections];
    }
    return self;
}

+ (instancetype)presetLargeHallReverbWithStereoInput:(AKStereoAudio *)input;
{
    return [[AKReverb alloc] initWithPresetLargeHallReverbWithStereoInput:input];
}

- (instancetype)initWithPresetMuffledCanReverbWithStereoInput:(AKStereoAudio *)input;
{
    self = [super initWithString:[self operationName]];
    if (self) {
        _leftInput = input.leftOutput;
        _rightInput = input.rightOutput;
        // 'Muffled Can' Values
        _feedback = akp(0.8);
        _cutoffFrequency = akp(1200);
        [self setUpConnections];
    }
    return self;
}

+ (instancetype)presetMuffledCanReverbWithStereoInput:(AKStereoAudio *)input;
{
    return [[AKReverb alloc] initWithPresetMuffledCanReverbWithStereoInput:input];
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
