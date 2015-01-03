//
//  AKFlanger.m
//  AudioKit
//
//  Auto-generated on 1/3/15.
//  Copyright (c) 2015 Aurelius Prochazka. All rights reserved.
//
//  Implementation of Csound's flanger:
//  http://www.csounds.com/manual/html/flanger.html
//

#import "AKFlanger.h"
#import "AKManager.h"

@implementation AKFlanger
{
    AKParameter * _input;
    AKParameter * _delayTime;
}

- (instancetype)initWithInput:(AKParameter *)input
                    delayTime:(AKParameter *)delayTime
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
                    delayTime:(AKParameter *)delayTime
{
    self = [super initWithString:[self operationName]];
    if (self) {
        _input = input;
        _delayTime = delayTime;
        // Default Values
        _feedback = akp(0);
    }
    return self;
}

+ (instancetype)effectWithInput:(AKParameter *)input
                      delayTime:(AKParameter *)delayTime
{
    return [[AKFlanger alloc] initWithInput:input
                                  delayTime:delayTime];
}

- (void)setOptionalFeedback:(AKParameter *)feedback {
    _feedback = feedback;
}

- (NSString *)stringForCSD {
    NSMutableString *csdString = [[NSMutableString alloc] init];
    
    [csdString appendFormat:@"%@ flanger ", self];
    
    if ([_input class] == [AKAudio class]) {
        [csdString appendFormat:@"%@, ", _input];
    } else {
        [csdString appendFormat:@"AKAudio(%@), ", _input];
    }
    
    if ([_delayTime class] == [AKAudio class]) {
        [csdString appendFormat:@"%@, ", _delayTime];
    } else {
        [csdString appendFormat:@"AKAudio(%@), ", _delayTime];
    }
    
    if ([_feedback class] == [AKControl class]) {
        [csdString appendFormat:@"%@", _feedback];
    } else {
        [csdString appendFormat:@"AKControl(%@)", _feedback];
    }
    return csdString;
}

@end
