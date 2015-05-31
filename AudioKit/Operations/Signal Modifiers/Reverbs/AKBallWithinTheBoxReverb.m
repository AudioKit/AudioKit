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
        [self setUpConnections];
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
        _diffusion = akp(0.9);
        [self setUpConnections];
    }
    return self;
}

- (instancetype)initWithPresetDefaultReverbWithInput:(AKParameter *)input
{
    return [self initWithInput:input];
}

+ (instancetype)presetDefaultReverbWithInput:(AKParameter *)input
{
    return [[AKBallWithinTheBoxReverb alloc] initWithInput:input];
}

- (instancetype)initWithPresetStutteringReverbWithInput:(AKParameter *)input;
{
    self = [super initWithString:[self operationName]];
    if (self) {
        _input = input;
        // Default Values
        _lengthOfXAxisEdge = akp(80);
        _lengthOfYAxisEdge = akp(80);
        _lengthOfZAxisEdge = akp(80);
        _xLocation = akp(20);
        _yLocation = akp(20);
        _zLocation = akp(20);
        _diffusion = akp(0.9);
        [self setUpConnections];
    }
    return self;
}

+ (instancetype)presetStutteringReverbWithInput:(AKParameter *)input;
{
    return [[AKBallWithinTheBoxReverb alloc] initWithPresetStutteringReverbWithInput:input];
}

- (instancetype)initWithPresetPloddingReverbWithInput:(AKParameter *)input;
{
    self = [super initWithString:[self operationName]];
    if (self) {
        _input = input;
        // Default Values
        _lengthOfXAxisEdge = akp(30);
        _lengthOfYAxisEdge = akp(40);
        _lengthOfZAxisEdge = akp(20);
        _xLocation = akp(6);
        _yLocation = akp(4);
        _zLocation = akp(3);
        _diffusion = akp(0.9);
        [self setUpConnections];
    }
    return self;
}

+ (instancetype)presetPloddingReverbWithInput:(AKParameter *)input;
{
    return [[AKBallWithinTheBoxReverb alloc] initWithPresetPloddingReverbWithInput:input];
}


+ (instancetype)reverbWithInput:(AKParameter *)input
{
    return [[AKBallWithinTheBoxReverb alloc] initWithInput:input];
}

- (void)setLengthOfXAxisEdge:(AKConstant *)lengthOfXAxisEdge {
    _lengthOfXAxisEdge = lengthOfXAxisEdge;
    [self setUpConnections];
}

- (void)setOptionalLengthOfXAxisEdge:(AKConstant *)lengthOfXAxisEdge {
    [self setLengthOfXAxisEdge:lengthOfXAxisEdge];
}

- (void)setLengthOfYAxisEdge:(AKConstant *)lengthOfYAxisEdge {
    _lengthOfYAxisEdge = lengthOfYAxisEdge;
    [self setUpConnections];
}

- (void)setOptionalLengthOfYAxisEdge:(AKConstant *)lengthOfYAxisEdge {
    [self setLengthOfYAxisEdge:lengthOfYAxisEdge];
}

- (void)setLengthOfZAxisEdge:(AKConstant *)lengthOfZAxisEdge {
    _lengthOfZAxisEdge = lengthOfZAxisEdge;
    [self setUpConnections];
}

- (void)setOptionalLengthOfZAxisEdge:(AKConstant *)lengthOfZAxisEdge {
    [self setLengthOfZAxisEdge:lengthOfZAxisEdge];
}

- (void)setXLocation:(AKParameter *)xLocation {
    _xLocation = xLocation;
    [self setUpConnections];
}

- (void)setOptionalXLocation:(AKParameter *)xLocation {
    [self setXLocation:xLocation];
}

- (void)setYLocation:(AKParameter *)yLocation {
    _yLocation = yLocation;
    [self setUpConnections];
}

- (void)setOptionalYLocation:(AKParameter *)yLocation {
    [self setYLocation:yLocation];
}

- (void)setZLocation:(AKParameter *)zLocation {
    _zLocation = zLocation;
    [self setUpConnections];
}

- (void)setOptionalZLocation:(AKParameter *)zLocation {
    [self setZLocation:zLocation];
}

- (void)setDiffusion:(AKConstant *)diffusion {
    _diffusion = diffusion;
    [self setUpConnections];
}

- (void)setOptionalDiffusion:(AKConstant *)diffusion {
    [self setDiffusion:diffusion];
}


- (void)setUpConnections
{
    self.state = @"connectable";
    self.dependencies = @[_input, _lengthOfXAxisEdge, _lengthOfYAxisEdge, _lengthOfZAxisEdge, _xLocation, _yLocation, _zLocation, _diffusion];
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
