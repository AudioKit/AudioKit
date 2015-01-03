//
//  AKDCBlock.m
//  AudioKit
//
//  Auto-generated on 1/3/15.
//  Copyright (c) 2015 Aurelius Prochazka. All rights reserved.
//
//  Implementation of Csound's dcblock:
//  http://www.csounds.com/manual/html/dcblock.html
//

#import "AKDCBlock.h"
#import "AKManager.h"

@implementation AKDCBlock
{
    AKParameter * _input;
}

- (instancetype)initWithInput:(AKParameter *)input
                         gain:(AKConstant *)gain
{
    self = [super initWithString:[self operationName]];
    if (self) {
        _input = input;
        _gain = gain;
    }
    return self;
}

- (instancetype)initWithInput:(AKParameter *)input
{
    self = [super initWithString:[self operationName]];
    if (self) {
        _input = input;
        // Default Values
        _gain = akp(0.99);
    }
    return self;
}

+ (instancetype)filterWithInput:(AKParameter *)input
{
    return [[AKDCBlock alloc] initWithInput:input];
}

- (void)setOptionalGain:(AKConstant *)gain {
    _gain = gain;
}

- (NSString *)stringForCSD {
    NSMutableString *csdString = [[NSMutableString alloc] init];

    [csdString appendFormat:@"%@ dcblock ", self];

    if ([_input class] == [AKAudio class]) {
        [csdString appendFormat:@"%@, ", _input];
    } else {
        [csdString appendFormat:@"AKAudio(%@), ", _input];
    }

    [csdString appendFormat:@"%@", _gain];
    return csdString;
}

@end
