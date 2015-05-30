//
//  AKTrackedAmplitude.m
//  AudioKit
//
//  Auto-generated on 1/3/15.
//  Customized by Aurelius Prochazka on 5/29/15 to scale the amplitude by sqrt 2.
//  Copyright (c) 2015 Aurelius Prochazka. All rights reserved.
//
//  Implementation of Csound's rms:
//  http://www.csounds.com/manual/html/rms.html
//

#import "AKTrackedAmplitude.h"
#import "AKManager.h"

@implementation AKTrackedAmplitude
{
    AKParameter * _input;
}

- (instancetype)initWithInput:(AKParameter *)input
               halfPowerPoint:(AKConstant *)halfPowerPoint
{
    self = [super initWithString:[self operationName]];
    if (self) {
        _input = input;
        _halfPowerPoint = halfPowerPoint;
        self.state = @"connectable";
        self.dependencies = @[input];
    }
    return self;
}

- (instancetype)initWithInput:(AKParameter *)input
{
    self = [super initWithString:[self operationName]];
    if (self) {
        _input = input;
        // Default Values
        _halfPowerPoint = akp(10);
        self.state = @"connectable";
        self.dependencies = @[input];
    }
    return self;
}

+ (instancetype)amplitudeWithInput:(AKParameter *)input
{
    return [[AKTrackedAmplitude alloc] initWithInput:input];
}

- (void)setOptionalHalfPowerPoint:(AKConstant *)halfPowerPoint {
    _halfPowerPoint = halfPowerPoint;
}

- (NSString *)stringForCSD {
    NSMutableString *csdString = [[NSMutableString alloc] init];
    
    [csdString appendFormat:@"%@ rms ", self];
    
    if ([_input class] == [AKAudio class]) {
        [csdString appendFormat:@"%@*1.414, ", _input];
    } else {
        [csdString appendFormat:@"AKAudio(%@*1.414), ", _input];
    }
    
    [csdString appendFormat:@"%@", _halfPowerPoint];
    return csdString;
}

@end
