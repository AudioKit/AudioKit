//
//  AKBallWithinTheBoxReverb.m
//  AudioKit
//
//  Auto-generated on 2/18/15.
//  Copyright (c) 2015 Aurelius Prochazka. All rights reserved.
//
//  Implementation of Csound's babo:
//  http://www.csounds.com/manual/html/babo.html
//

#import "AKBallWithinTheBoxReverb.h"
#import "AKManager.h"

@implementation AKBallWithinTheBoxReverb
{
    AKParameter * _input;
}

- (instancetype)initWithInput:(AKParameter *)input
            lengthOfXAxisEdge:(AKConstant *)lengthOfXAxisEdge
            lengthOfYAxisEdge:(AKConstant *)lengthOfYAxisEdge
            lengthOfZAxisEdge:(AKConstant *)lengthOfZAxisEdge
                    xLocation:(AKParameter *)xLocation
                    yLocation:(AKParameter *)yLocation
                    zLocation:(AKParameter *)zLocation
                    diffusion:(AKConstant *)diffusion
{
    self = [super initWithString:[self operationName]];
    if (self) {
        _input = input;
        _lengthOfXAxisEdge = lengthOfXAxisEdge;
        _lengthOfYAxisEdge = lengthOfYAxisEdge;
        _lengthOfZAxisEdge = lengthOfZAxisEdge;
        _xLocation = xLocation;
        _yLocation = yLocation;
        _zLocation = zLocation;
        _diffusion = diffusion;
    }
    return self;
}

- (instancetype)initWithInput:(AKParameter *)input
{
    self = [super initWithString:[self operationName]];
    if (self) {
        _input = input;
        // Default Values
        _lengthOfXAxisEdge = akp(14.39);
        _lengthOfYAxisEdge = akp(11.86);
        _lengthOfZAxisEdge = akp(10);
        _xLocation = akp(6);
        _yLocation = akp(4);
        _zLocation = akp(3);
        _diffusion = akp(1);
    }
    return self;
}

+ (instancetype)reverbWithInput:(AKParameter *)input
{
    return [[AKBallWithinTheBoxReverb alloc] initWithInput:input];
}

- (void)setOptionalLengthOfXAxisEdge:(AKConstant *)lengthOfXAxisEdge {
    _lengthOfXAxisEdge = lengthOfXAxisEdge;
}
- (void)setOptionalLengthOfYAxisEdge:(AKConstant *)lengthOfYAxisEdge {
    _lengthOfYAxisEdge = lengthOfYAxisEdge;
}
- (void)setOptionalLengthOfZAxisEdge:(AKConstant *)lengthOfZAxisEdge {
    _lengthOfZAxisEdge = lengthOfZAxisEdge;
}
- (void)setOptionalXLocation:(AKParameter *)xLocation {
    _xLocation = xLocation;
}
- (void)setOptionalYLocation:(AKParameter *)yLocation {
    _yLocation = yLocation;
}
- (void)setOptionalZLocation:(AKParameter *)zLocation {
    _zLocation = zLocation;
}
- (void)setOptionalDiffusion:(AKConstant *)diffusion {
    _diffusion = diffusion;
}

- (NSString *)inlineStringForCSD
{
    NSMutableString *inlineCSDString = [[NSMutableString alloc] init];

    [inlineCSDString appendString:@"babo("];
    [inlineCSDString appendString:[self inputsString]];
    [inlineCSDString appendString:@")"];

    return inlineCSDString;
}


- (NSString *)stringForCSD
{
    NSMutableString *csdString = [[NSMutableString alloc] init];

    [csdString appendFormat:@"%@ babo ", self];
    [csdString appendString:[self inputsString]];
    return csdString;
}

- (NSString *)inputsString {
    NSMutableString *inputsString = [[NSMutableString alloc] init];

    
    if ([_input class] == [AKAudio class]) {
        [inputsString appendFormat:@"%@, ", _input];
    } else {
        [inputsString appendFormat:@"AKAudio(%@), ", _input];
    }

    if ([_xLocation class] == [AKControl class]) {
        [inputsString appendFormat:@"%@, ", _xLocation];
    } else {
        [inputsString appendFormat:@"AKControl(%@), ", _xLocation];
    }

    if ([_yLocation class] == [AKControl class]) {
        [inputsString appendFormat:@"%@, ", _yLocation];
    } else {
        [inputsString appendFormat:@"AKControl(%@), ", _yLocation];
    }

    if ([_zLocation class] == [AKControl class]) {
        [inputsString appendFormat:@"%@, ", _zLocation];
    } else {
        [inputsString appendFormat:@"AKControl(%@), ", _zLocation];
    }

    [inputsString appendFormat:@"%@, ", _lengthOfXAxisEdge];
    
    [inputsString appendFormat:@"%@, ", _lengthOfYAxisEdge];
    
    [inputsString appendFormat:@"%@, ", _lengthOfZAxisEdge];
    
    [inputsString appendFormat:@"%@", _diffusion];
    return inputsString;
}

@end
