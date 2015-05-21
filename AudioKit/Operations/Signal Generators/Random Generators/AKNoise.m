//
//  AKNoise.m
//  AudioKit
//
//  Auto-generated on 2/19/15.
//  Copyright (c) 2015 Aurelius Prochazka. All rights reserved.
//
//  Implementation of Csound's noisepinky:
//  http://www.csounds.com/manual/html/noisepinky.html
//

#import "AKNoise.h"
#import "AKManager.h"

@implementation AKNoise

- (instancetype)initWithAmplitude:(AKParameter *)amplitude
                      pinkBalance:(AKParameter *)pinkBalance
                             beta:(AKParameter *)beta
{
    self = [super initWithString:[self operationName]];
    if (self) {
        _amplitude = amplitude;
        _pinkBalance = pinkBalance;
        _beta = beta;
        [self setUpConnections];
}
    return self;
}

- (instancetype)init
{
    self = [super initWithString:[self operationName]];
    if (self) {
        // Default Values
        _amplitude = akp(0.5);
        _pinkBalance = akp(0);
        _beta = akp(0);
        [self setUpConnections];
    }
    return self;
}

+ (instancetype)noise
{
    return [[AKNoise alloc] init];
}

- (void)setAmplitude:(AKParameter *)amplitude {
    _amplitude = amplitude;
    [self setUpConnections];
}

- (void)setOptionalAmplitude:(AKParameter *)amplitude {
    [self setAmplitude:amplitude];
}

- (void)setPinkBalance:(AKParameter *)pinkBalance {
    _pinkBalance = pinkBalance;
    [self setUpConnections];
}

- (void)setOptionalPinkBalance:(AKParameter *)pinkBalance {
    [self setPinkBalance:pinkBalance];
}

- (void)setBeta:(AKParameter *)beta {
    _beta = beta;
    [self setUpConnections];
}

- (void)setOptionalBeta:(AKParameter *)beta {
    [self setBeta:beta];
}


- (void)setUpConnections
{
    self.state = @"connectable";
    self.dependencies = @[_amplitude, _pinkBalance, _beta];
}

- (NSString *)inlineStringForCSD
{
    NSMutableString *inlineCSDString = [[NSMutableString alloc] init];

    [inlineCSDString appendString:@"noisepinky("];
    [inlineCSDString appendString:[self inputsString]];
    [inlineCSDString appendString:@")"];

    return inlineCSDString;
}


- (NSString *)stringForCSD
{
    NSMutableString *csdString = [[NSMutableString alloc] init];

    [csdString appendFormat:@"%@ noisepinky ", self];
    [csdString appendString:[self inputsString]];
    return csdString;
}

- (NSString *)inputsString {
    NSMutableString *inputsString = [[NSMutableString alloc] init];

    
    if ([_amplitude class] == [AKAudio class]) {
        [inputsString appendFormat:@"%@, ", _amplitude];
    } else {
        [inputsString appendFormat:@"AKAudio(%@), ", _amplitude];
    }

    if ([_beta class] == [AKControl class]) {
        [inputsString appendFormat:@"%@, ", _beta];
    } else {
        [inputsString appendFormat:@"AKControl(%@), ", _beta];
    }

    if ([_pinkBalance class] == [AKAudio class]) {
        [inputsString appendFormat:@"%@", _pinkBalance];
    } else {
        [inputsString appendFormat:@"AKAudio(%@)", _pinkBalance];
    }
return inputsString;
}

- (NSString *)udoString {
    return @"\n"
    "opcode  noisepinky, a, aka\n"
    "aOut init 0\n"
    "aAmplitude, kBeta, aPink xin\n"
    "aWhiteNoise noise aAmplitude, kBeta\n"
    "aPinkish pinkish aWhiteNoise\n"
    "aOut = (1-aPink) * aWhiteNoise + aPink*aPinkish\n"
    "xout aOut\n"
    "endop\n";
}


@end
