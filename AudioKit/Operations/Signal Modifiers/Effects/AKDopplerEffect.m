//
//  AKDopplerEffect.m
//  AudioKit
//
//  Auto-generated on 12/25/14.
//  Copyright (c) 2014 Aurelius Prochazka. All rights reserved.
//
//  Implementation of Csound's doppler:
//  http://www.csounds.com/manual/html/doppler.html
//

#import "AKDopplerEffect.h"
#import "AKManager.h"

@implementation AKDopplerEffect
{
    AKParameter * _input;
    AKParameter * _sourcePosition;
}

- (instancetype)initWithInput:(AKParameter *)input
               sourcePosition:(AKParameter *)sourcePosition
                  micPosition:(AKParameter *)micPosition
    smoothingFilterUpdateRate:(AKConstant *)smoothingFilterUpdateRate
{
    self = [super initWithString:[self operationName]];
    if (self) {
        _input = input;
        _sourcePosition = sourcePosition;
        _micPosition = micPosition;
        _smoothingFilterUpdateRate = smoothingFilterUpdateRate;
    }
    return self;
}

- (instancetype)initWithInput:(AKParameter *)input
               sourcePosition:(AKParameter *)sourcePosition
{
    self = [super initWithString:[self operationName]];
    if (self) {
        _input = input;
        _sourcePosition = sourcePosition;
        // Default Values
        _micPosition = akp(0);
        _smoothingFilterUpdateRate = akp(6);
    }
    return self;
}

+ (instancetype)audioWithInput:(AKParameter *)input
               sourcePosition:(AKParameter *)sourcePosition
{
    return [[AKDopplerEffect alloc] initWithInput:input
               sourcePosition:sourcePosition];
}

- (void)setOptionalMicPosition:(AKParameter *)micPosition {
    _micPosition = micPosition;
}
- (void)setOptionalSmoothingFilterUpdateRate:(AKConstant *)smoothingFilterUpdateRate {
    _smoothingFilterUpdateRate = smoothingFilterUpdateRate;
}

- (NSString *)stringForCSD {
    NSMutableString *csdString = [[NSMutableString alloc] init];

    // Constant Values  
    AKConstant *_soundSpeed = akp(340.29);        
    [csdString appendFormat:@"%@ doppler ", self];

    if ([_input isKindOfClass:[AKAudio class]] ) {
        [csdString appendFormat:@"%@, ", _input];
    } else {
        [csdString appendFormat:@"AKAudio(%@), ", _input];
    }

    if ([_sourcePosition isKindOfClass:[AKControl class]] ) {
        [csdString appendFormat:@"%@, ", _sourcePosition];
    } else {
        [csdString appendFormat:@"AKControl(%@), ", _sourcePosition];
    }

    if ([_micPosition isKindOfClass:[AKControl class]] ) {
        [csdString appendFormat:@"%@, ", _micPosition];
    } else {
        [csdString appendFormat:@"AKControl(%@), ", _micPosition];
    }

    [csdString appendFormat:@"%@, ", _soundSpeed];
    
    [csdString appendFormat:@"%@", _smoothingFilterUpdateRate];
    return csdString;
}

@end
