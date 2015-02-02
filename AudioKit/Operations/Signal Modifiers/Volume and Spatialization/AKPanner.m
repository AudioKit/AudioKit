//
//  AKPanner.m
//  AudioKit
//
//  Auto-generated on 1/3/15.
//  Copyright (c) 2015 Aurelius Prochazka. All rights reserved.
//
//  Implementation of Csound's pan2:
//  http://www.csounds.com/manual/html/pan2.html
//

#import "AKPanner.h"
#import "AKManager.h"

@implementation AKPanner
{
    AKParameter * _input;
}

+ (AKConstant *)panMethodForEqualPower          { return akp(0); }
+ (AKConstant *)panMethodForSquareRoot          { return akp(1); }
+ (AKConstant *)panMethodForLinear              { return akp(2); }
+ (AKConstant *)panMethodForEqualPowerAlternate { return akp(3); }

- (instancetype)initWithInput:(AKParameter *)input
                          pan:(AKParameter *)pan
                    panMethod:(AKConstant *)panMethod
{
    self = [super initWithString:[self operationName]];
    if (self) {
        _input = input;
        _pan = pan;
        _panMethod = panMethod;
    }
    return self;
}

- (instancetype)initWithInput:(AKParameter *)input
{
    self = [super initWithString:[self operationName]];
    if (self) {
        _input = input;
        // Default Values
        _pan = akp(0);
        _panMethod = [AKPanner panMethodForEqualPower];
    }
    return self;
}

+ (instancetype)pannerWithInput:(AKParameter *)input
{
    return [[AKPanner alloc] initWithInput:input];
}

- (void)setOptionalPan:(AKParameter *)pan {
    _pan = pan;
}
- (void)setOptionalPanMethod:(AKConstant *)panMethod {
    _panMethod = panMethod;
}

- (NSString *)stringForCSD {
    NSMutableString *csdString = [[NSMutableString alloc] init];

    [csdString appendFormat:@"%@ pan2 ", self];

    if ([_input class] == [AKAudio class]) {
        [csdString appendFormat:@"%@, ", _input];
    } else {
        [csdString appendFormat:@"AKAudio(%@), ", _input];
    }

    [csdString appendFormat:@"0.5 * (%@+1), ", _pan];
    
    [csdString appendFormat:@"%@", _panMethod];
    return csdString;
}

@end
