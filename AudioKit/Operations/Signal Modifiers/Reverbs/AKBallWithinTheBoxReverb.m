//
//  AKBallWithinTheBoxReverb.m
//  AudioKit
//
//  Auto-generated on 1/3/15.
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

- (NSString *)stringForCSD {
    NSMutableString *csdString = [[NSMutableString alloc] init];

    [csdString appendFormat:@"%@ babo ", self];

    if ([_input class] == [AKAudio class]) {
        [csdString appendFormat:@"%@, ", _input];
    } else {
        [csdString appendFormat:@"AKAudio(%@), ", _input];
    }

    if ([_xLocation class] == [AKControl class]) {
        [csdString appendFormat:@"%@, ", _xLocation];
    } else {
        [csdString appendFormat:@"AKControl(%@), ", _xLocation];
    }

    if ([_yLocation class] == [AKControl class]) {
        [csdString appendFormat:@"%@, ", _yLocation];
    } else {
        [csdString appendFormat:@"AKControl(%@), ", _yLocation];
    }

    if ([_zLocation class] == [AKControl class]) {
        [csdString appendFormat:@"%@, ", _zLocation];
    } else {
        [csdString appendFormat:@"AKControl(%@), ", _zLocation];
    }

    [csdString appendFormat:@"%@, ", _lengthOfXAxisEdge];
    
    [csdString appendFormat:@"%@, ", _lengthOfYAxisEdge];
    
    [csdString appendFormat:@"%@, ", _lengthOfZAxisEdge];
    
    [csdString appendFormat:@"%@", _diffusion];
    return csdString;
}

@end
