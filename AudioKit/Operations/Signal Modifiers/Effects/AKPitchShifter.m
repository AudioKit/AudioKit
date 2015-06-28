//
//  AKPitchShifter.m
//  AudioKit
//
//  Auto-generated on 6/26/15.
//  Copyright (c) 2015 Aurelius Prochazka. All rights reserved.
//
//  Implementation of Csound's PitchShifter:
//  http://www.csounds.com/manual/html/PitchShifter.html
//

#import "AKPitchShifter.h"
#import "AKManager.h"

@implementation AKPitchShifter
{
    AKParameter * _input;
}

+ (AKConstant *)noFormantRetainMethod               { return akp(0);  }
+ (AKConstant *)lifteredCepstrumFormantRetainMethod { return akp(1);  }
+ (AKConstant *)trueEnvelopeFormantRetainMethod     { return akp(2);  }

- (instancetype)initWithInput:(AKParameter *)input
               frequencyRatio:(AKParameter *)frequencyRatio
          formantRetainMethod:(AKParameter *)formantRetainMethod
                      fftSize:(AKConstant *)fftSize
{
    self = [super initWithString:[self operationName]];
    if (self) {
        _input = input;
        _frequencyRatio = frequencyRatio;
        _formantRetainMethod = formantRetainMethod;
        _fftSize = fftSize;
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
        _frequencyRatio = akp(1);
        _formantRetainMethod = akp(0);
        _fftSize = akp(1024);
        [self setUpConnections];
    }
    return self;
}

+ (instancetype)pitchShifterWithInput:(AKParameter *)input
{
    return [[AKPitchShifter alloc] initWithInput:input];
}

- (void)setFrequencyRatio:(AKParameter *)frequencyRatio {
    _frequencyRatio = frequencyRatio;
    [self setUpConnections];
}

- (void)setOptionalFrequencyRatio:(AKParameter *)frequencyRatio {
    [self setFrequencyRatio:frequencyRatio];
}

- (void)setFormantRetainMethod:(AKParameter *)formantRetainMethod {
    _formantRetainMethod = formantRetainMethod;
    [self setUpConnections];
}

- (void)setOptionalFormantRetainMethod:(AKParameter *)formantRetainMethod {
    [self setFormantRetainMethod:formantRetainMethod];
}

- (void)setFftSize:(AKConstant *)fftSize {
    _fftSize = fftSize;
    [self setUpConnections];
}

- (void)setOptionalFftSize:(AKConstant *)fftSize {
    [self setFftSize:fftSize];
}


- (void)setUpConnections
{
    self.state = @"connectable";
    self.dependencies = @[_input, _frequencyRatio, _formantRetainMethod, _fftSize];
}

- (NSString *)inlineStringForCSD
{
    NSMutableString *inlineCSDString = [[NSMutableString alloc] init];

    [inlineCSDString appendString:@"PitchShifter("];
    [inlineCSDString appendString:[self inputsString]];
    [inlineCSDString appendString:@")"];

    return inlineCSDString;
}


- (NSString *)stringForCSD
{
    NSMutableString *csdString = [[NSMutableString alloc] init];

    [csdString appendFormat:@"%@ PitchShifter ", self];
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

    if ([_frequencyRatio class] == [AKControl class]) {
        [inputsString appendFormat:@"%@, ", _frequencyRatio];
    } else {
        [inputsString appendFormat:@"AKControl(%@), ", _frequencyRatio];
    }

    if ([_formantRetainMethod class] == [AKControl class]) {
        [inputsString appendFormat:@"%@, ", _formantRetainMethod];
    } else {
        [inputsString appendFormat:@"AKControl(%@), ", _formantRetainMethod];
    }

    [inputsString appendFormat:@"%@", _fftSize];
    return inputsString;
}

- (NSString *)udoString {
    return @"\n"
    "opcode  PitchShifter, a, akki\n"
    "asig,kpitch,kfor, iff  xin\n"
    "fsig pvsanal asig, iff,iff/8,iff,1\n"
    "fsig2 pvscale fsig, kpitch, kfor\n"
    "aout pvsynth fsig2\n"
    "xout  aout\n"
    "endop\n";
}

@end
