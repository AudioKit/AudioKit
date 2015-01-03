//
//  AKDelay.m
//  AudioKit
//
//  Auto-generated on 12/27/14.
//  Customized by Aurelius Prochazka on 12/27/14.
//  Copyright (c) 2014 Aurelius Prochazka. All rights reserved.
//
//  Implementation of Csound's delay:
//  http://www.csounds.com/manual/html/delay.html
//

#import "AKDelay.h"
#import "AKManager.h"

@implementation AKDelay
{
    AKParameter * _input;
    AKConstant * _delayTime;
}

- (instancetype)initWithInput:(AKParameter *)input
                    delayTime:(AKConstant *)delayTime
                     feedback:(AKParameter *)feedback
{
    self = [super initWithString:[self operationName]];
    if (self) {
        _input = input;
        _delayTime = delayTime;
        _feedback = feedback;
    }
    return self;
}

- (instancetype)initWithInput:(AKParameter *)input
                    delayTime:(AKConstant *)delayTime
{
    self = [super initWithString:[self operationName]];
    if (self) {
        _input = input;
        _delayTime = delayTime;
        // Default Values
        _feedback = akp(0.0);
    }
    return self;
}

+ (instancetype)delayWithInput:(AKParameter *)input
                    delayTime:(AKConstant *)delayTime
{
    return [[AKDelay alloc] initWithInput:input
                    delayTime:delayTime];
}

- (void)setOptionalFeedback:(AKParameter *)feedback {
    _feedback = feedback;
}

- (NSString *)stringForCSD {
    NSMutableString *csdString = [[NSMutableString alloc] init];

    [csdString appendFormat:@"%@ init 0\n", self];
    
    [csdString appendFormat:@"%@ delay ", self];

    if ([_feedback class] == [AKAudio class]) {
        [csdString appendFormat:@"%@ + (%@*%@), ", _input, self, _feedback];
    } else {
        [csdString appendFormat:@"AKAudio(%@ + (%@*%@)), ", _input, self, _feedback];
    }

    [csdString appendFormat:@"%@", _delayTime];
    return csdString;
}

@end
