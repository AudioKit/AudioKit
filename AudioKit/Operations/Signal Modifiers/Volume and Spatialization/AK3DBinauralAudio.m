//
//  AK3DBinauralAudio.m
//  AudioKit
//
//  Auto-generated on 4/15/15.
//  Copyright (c) 2015 Aurelius Prochazka. All rights reserved.
//
//  Implementation of Csound's hrtfmove2:
//  http://www.csounds.com/manual/html/hrtfmove2.html
//

#import "AK3DBinauralAudio.h"
#import "AKManager.h"

@implementation AK3DBinauralAudio
{
    AKParameter * _input;
}

- (instancetype)initWithInput:(AKParameter *)input
                      azimuth:(AKParameter *)azimuth
                    elevation:(AKParameter *)elevation
{
    self = [super initWithString:[self operationName]];
    if (self) {
        _input = input;
        _azimuth = azimuth;
        _elevation = elevation;
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
        _azimuth = akp(0);
        _elevation = akp(0);
        [self setUpConnections];
    }
    return self;
}

+ (instancetype)WithInput:(AKParameter *)input
{
    return [[AK3DBinauralAudio alloc] initWithInput:input];
}

- (void)setAzimuth:(AKParameter *)azimuth {
    _azimuth = azimuth;
    [self setUpConnections];
}

- (void)setOptionalAzimuth:(AKParameter *)azimuth {
    [self setAzimuth:azimuth];
}

- (void)setElevation:(AKParameter *)elevation {
    _elevation = elevation;
    [self setUpConnections];
}

- (void)setOptionalElevation:(AKParameter *)elevation {
    [self setElevation:elevation];
}


- (void)setUpConnections
{
    self.state = @"connectable";
    self.dependencies = @[_input, _azimuth, _elevation];
}

- (NSString *)inlineStringForCSD
{
    NSMutableString *inlineCSDString = [[NSMutableString alloc] init];

    [inlineCSDString appendString:@"hrtfmove("];
    [inlineCSDString appendString:[self inputsString]];
    [inlineCSDString appendString:@")"];

    return inlineCSDString;
}


- (NSString *)stringForCSD
{
    NSMutableString *csdString = [[NSMutableString alloc] init];

    [csdString appendFormat:@"%@ hrtfmove ", self];
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

    if ([_azimuth class] == [AKControl class]) {
        [inputsString appendFormat:@"%@, ", _azimuth];
    } else {
        [inputsString appendFormat:@"AKControl(%@), ", _azimuth];
    }

    if ([_elevation class] == [AKControl class]) {
        [inputsString appendFormat:@"%@, ", _elevation];
    } else {
        [inputsString appendFormat:@"AKControl(%@), ", _elevation];
    }
    
    NSString *leftDat  = [AKManager pathToSoundFile:@"hrtf-44100-left"  ofType:@"dat"];
    NSString *rightDat = [AKManager pathToSoundFile:@"hrtf-44100-right" ofType:@"dat"];
    
    [inputsString appendFormat:@"\"%@\",\"%@\"", leftDat, rightDat];
    
    return inputsString;
}

@end
