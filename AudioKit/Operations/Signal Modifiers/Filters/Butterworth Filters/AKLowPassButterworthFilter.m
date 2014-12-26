//
//  AKLowPassButterworthFilter.m
//  AudioKit
//
//  Auto-generated on 12/25/14.
//  Copyright (c) 2014 Aurelius Prochazka. All rights reserved.
//
//  Implementation of Csound's butterlp:
//  http://www.csounds.com/manual/html/butterlp.html
//

#import "AKLowPassButterworthFilter.h"
#import "AKManager.h"

@implementation AKLowPassButterworthFilter
{
    AKParameter * _input;
}

- (instancetype)initWithInput:(AKParameter *)input
              cutoffFrequency:(AKParameter *)cutoffFrequency
{
    self = [super initWithString:[self operationName]];
    if (self) {
        _input = input;
        _cutoffFrequency = cutoffFrequency;
    }
    return self;
}

- (instancetype)initWithInput:(AKParameter *)input
{
    self = [super initWithString:[self operationName]];
    if (self) {
        _input = input;
        // Default Values
        _cutoffFrequency = akp(1000);
    }
    return self;
}

+ (instancetype)audioWithInput:(AKParameter *)input
{
    return [[AKLowPassButterworthFilter alloc] initWithInput:input];
}

- (void)setOptionalCutoffFrequency:(AKParameter *)cutoffFrequency {
    _cutoffFrequency = cutoffFrequency;
}

- (NSString *)stringForCSD {
    NSMutableString *csdString = [[NSMutableString alloc] init];

    [csdString appendFormat:@"%@ butterlp ", self];

    if ([_input isKindOfClass:[AKAudio class]] ) {
        [csdString appendFormat:@"%@, ", _input];
    } else {
        [csdString appendFormat:@"AKAudio(%@), ", _input];
    }

    if ([_cutoffFrequency isKindOfClass:[AKControl class]] ) {
        [csdString appendFormat:@"%@", _cutoffFrequency];
    } else {
        [csdString appendFormat:@"AKControl(%@)", _cutoffFrequency];
    }
return csdString;
}

@end
