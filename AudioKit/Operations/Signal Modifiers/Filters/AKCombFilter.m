//
//  AKCombFilter.m
//  AudioKit
//
//  Auto-generated on 1/3/15.
//  Copyright (c) 2015 Aurelius Prochazka. All rights reserved.
//
//  Implementation of Csound's comb:
//  http://www.csounds.com/manual/html/comb.html
//

#import "AKCombFilter.h"
#import "AKManager.h"

@implementation AKCombFilter
{
    AKParameter * _input;
}

- (instancetype)initWithInput:(AKParameter *)input
               reverbDuration:(AKParameter *)reverbDuration
                 loopDuration:(AKConstant *)loopDuration
{
    self = [super initWithString:[self operationName]];
    if (self) {
        _input = input;
        _reverbDuration = reverbDuration;
        _loopDuration = loopDuration;
    }
    return self;
}

- (instancetype)initWithInput:(AKParameter *)input
{
    self = [super initWithString:[self operationName]];
    if (self) {
        _input = input;
        // Default Values
        _reverbDuration = akp(1);
        _loopDuration = akp(0.1);
    }
    return self;
}

+ (instancetype)filterWithInput:(AKParameter *)input
{
    return [[AKCombFilter alloc] initWithInput:input];
}

- (void)setOptionalReverbDuration:(AKParameter *)reverbDuration {
    _reverbDuration = reverbDuration;
}
- (void)setOptionalLoopDuration:(AKConstant *)loopDuration {
    _loopDuration = loopDuration;
}

- (NSString *)stringForCSD {
    NSMutableString *csdString = [[NSMutableString alloc] init];

    [csdString appendFormat:@"%@ comb ", self];

    if ([_input class] == [AKAudio class]) {
        [csdString appendFormat:@"%@, ", _input];
    } else {
        [csdString appendFormat:@"AKAudio(%@), ", _input];
    }

    if ([_reverbDuration class] == [AKControl class]) {
        [csdString appendFormat:@"%@, ", _reverbDuration];
    } else {
        [csdString appendFormat:@"AKControl(%@), ", _reverbDuration];
    }

    [csdString appendFormat:@"%@", _loopDuration];
    return csdString;
}

@end
