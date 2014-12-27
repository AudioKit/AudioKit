//
//  AKVariableDelay.m
//  AudioKit
//
//  Auto-generated on 12/27/14.
//  Copyright (c) 2014 Aurelius Prochazka. All rights reserved.
//
//  Implementation of Csound's vdelay3:
//  http://www.csounds.com/manual/html/vdelay3.html
//

#import "AKVariableDelay.h"
#import "AKManager.h"

@implementation AKVariableDelay
{
    AKParameter * _input;
    AKParameter * _delayTime;
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
                    delayTime:(AKParameter *)delayTime
{
    self = [super initWithString:[self operationName]];
    if (self) {
        _input = input;
        _delayTime = delayTime;
        // Default Values
        _maximumDelayTime = akp(50);
    }
    return self;
}

+ (instancetype)audioWithInput:(AKParameter *)input
                    delayTime:(AKParameter *)delayTime
{
    return [[AKVariableDelay alloc] initWithInput:input
                    delayTime:delayTime];
}

- (void)setOptionalMaximumDelayTime:(AKConstant *)maximumDelayTime {
    _maximumDelayTime = maximumDelayTime;
}

- (NSString *)stringForCSD {
    NSMutableString *csdString = [[NSMutableString alloc] init];

    [csdString appendFormat:@"%@ vdelay3 ", self];

    if ([_input isKindOfClass:[AKAudio class]] ) {
        [csdString appendFormat:@"%@, ", _input];
    } else {
        [csdString appendFormat:@"AKAudio(%@), ", _input];
    }

    if ([_delayTime isKindOfClass:[AKAudio class]] ) {
        [csdString appendFormat:@"%@, ", _delayTime];
    } else {
        [csdString appendFormat:@"AKAudio(%@), ", _delayTime];
    }

    [csdString appendFormat:@"%@", _maximumDelayTime];
    return csdString;
}

@end
