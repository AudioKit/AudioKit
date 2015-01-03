//
//  AKVariableDelay.m
//  AudioKit
//
//  Auto-generated on 1/3/15.
//  Copyright (c) 2015 Aurelius Prochazka. All rights reserved.
//
//  Implementation of Csound's vdelay3:
//  http://www.csounds.com/manual/html/vdelay3.html
//

#import "AKVariableDelay.h"
#import "AKManager.h"

@implementation AKVariableDelay
{
    AKParameter * _input;
}

- (instancetype)initWithInput:(AKParameter *)input
                    delayTime:(AKParameter *)delayTime
             maximumDelayTime:(AKConstant *)maximumDelayTime
{
    self = [super initWithString:[self operationName]];
    if (self) {
        _input = input;
        _delayTime = delayTime;
        _maximumDelayTime = maximumDelayTime;
    }
    return self;
}

- (instancetype)initWithInput:(AKParameter *)input
{
    self = [super initWithString:[self operationName]];
    if (self) {
        _input = input;
        // Default Values
        _delayTime = akp(0);
        _maximumDelayTime = akp(5);
    }
    return self;
}

+ (instancetype)delayWithInput:(AKParameter *)input
{
    return [[AKVariableDelay alloc] initWithInput:input];
}

- (void)setOptionalDelayTime:(AKParameter *)delayTime {
    _delayTime = delayTime;
}
- (void)setOptionalMaximumDelayTime:(AKConstant *)maximumDelayTime {
    _maximumDelayTime = maximumDelayTime;
}

- (NSString *)stringForCSD {
    NSMutableString *csdString = [[NSMutableString alloc] init];

    [csdString appendFormat:@"%@ vdelay3 ", self];

    if ([_input class] == [AKAudio class]) {
        [csdString appendFormat:@"%@, ", _input];
    } else {
        [csdString appendFormat:@"AKAudio(%@), ", _input];
    }

    if ([_delayTime class] == [AKAudio class]) {
        [csdString appendFormat:@"(1000 * %@), ", _delayTime];
    } else {
        [csdString appendFormat:@"AKAudio((1000 * %@)), ", _delayTime];
    }

    [csdString appendFormat:@"(1000 * %@)", _maximumDelayTime];
    return csdString;
}

@end
