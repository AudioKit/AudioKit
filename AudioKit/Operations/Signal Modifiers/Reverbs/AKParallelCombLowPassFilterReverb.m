//
//  AKParallelCombLowPassFilterReverb.m
//  AudioKit
//
//  Auto-generated on 1/3/15.
//  Copyright (c) 2015 Aurelius Prochazka. All rights reserved.
//
//  Implementation of Csound's nreverb:
//  http://www.csounds.com/manual/html/nreverb.html
//

#import "AKParallelCombLowPassFilterReverb.h"
#import "AKManager.h"

@implementation AKParallelCombLowPassFilterReverb
{
    AKParameter * _input;
}

- (instancetype)initWithInput:(AKParameter *)input
                     duration:(AKParameter *)duration
     highFrequencyDiffusivity:(AKParameter *)highFrequencyDiffusivity
{
    self = [super initWithString:[self operationName]];
    if (self) {
        _input = input;
        _duration = duration;
        _highFrequencyDiffusivity = highFrequencyDiffusivity;
    }
    return self;
}

- (instancetype)initWithInput:(AKParameter *)input
{
    self = [super initWithString:[self operationName]];
    if (self) {
        _input = input;
        // Default Values
        _duration = akp(1);
        _highFrequencyDiffusivity = akp(0.5);
    }
    return self;
}

+ (instancetype)reverbWithInput:(AKParameter *)input
{
    return [[AKParallelCombLowPassFilterReverb alloc] initWithInput:input];
}

- (void)setOptionalDuration:(AKParameter *)duration {
    _duration = duration;
}
- (void)setOptionalHighFrequencyDiffusivity:(AKParameter *)highFrequencyDiffusivity {
    _highFrequencyDiffusivity = highFrequencyDiffusivity;
}

- (NSString *)stringForCSD {
    NSMutableString *csdString = [[NSMutableString alloc] init];

    [csdString appendFormat:@"%@ nreverb ", self];

    if ([_input class] == [AKAudio class]) {
        [csdString appendFormat:@"%@, ", _input];
    } else {
        [csdString appendFormat:@"AKAudio(%@), ", _input];
    }

    if ([_duration class] == [AKControl class]) {
        [csdString appendFormat:@"%@, ", _duration];
    } else {
        [csdString appendFormat:@"AKControl(%@), ", _duration];
    }

    if ([_highFrequencyDiffusivity class] == [AKControl class]) {
        [csdString appendFormat:@"%@", _highFrequencyDiffusivity];
    } else {
        [csdString appendFormat:@"AKControl(%@)", _highFrequencyDiffusivity];
    }
return csdString;
}

@end
