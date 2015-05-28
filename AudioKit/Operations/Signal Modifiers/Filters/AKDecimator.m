//
//  AKDecimator.m
//  AudioKit
//
//  Auto-generated on 2/18/15.
//  Copyright (c) 2015 Aurelius Prochazka. All rights reserved.
//
//  Implementation of Csound's decimator:
//  http://www.csounds.com/manual/html/decimator.html
//

#import "AKDecimator.h"
#import "AKManager.h"

@implementation AKDecimator
{
    AKParameter * _input;
}

- (instancetype)initWithInput:(AKParameter *)input
                     bitDepth:(AKParameter *)bitDepth
                   sampleRate:(AKParameter *)sampleRate
{
    self = [super initWithString:[self operationName]];
    if (self) {
        _input = input;
        _bitDepth = bitDepth;
        _sampleRate = sampleRate;
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
        _bitDepth = akp(24);
        _sampleRate = akp(44100);
        [self setUpConnections];
    }
    return self;
}

+ (instancetype)filterWithInput:(AKParameter *)input
{
    return [[AKDecimator alloc] initWithInput:input];
}

- (instancetype)initWithPresetDefaultDecimatorWithInput:(AKParameter *)input;
{
    return [self initWithInput:input];
}

+ (instancetype)presetDefaultDecimatorWithInput:(AKParameter *)input;
{
    return [[AKDecimator alloc] initWithInput:input];
}

- (instancetype)initWithPresetCrunchyDecimatorWithInput:(AKParameter *)input;
{
    self = [super initWithString:[self operationName]];
    if (self) {
        _input = input;
        // Default Values
        _bitDepth = akp(20);
        _sampleRate = akp(44100);
        [self setUpConnections];
    }
    return self;
}

+ (instancetype)presetCrunchyDecimatorWithInput:(AKParameter *)input;
{
    return [[AKDecimator alloc] initWithPresetCrunchyDecimatorWithInput:input];
}

- (instancetype)initWithPresetVideogameDecimatorWithInput:(AKParameter *)input;
{
    self = [super initWithString:[self operationName]];
    if (self) {
        _input = input;
        // Default Values
        _bitDepth = akp(20);
        _sampleRate = akp(2400);
        [self setUpConnections];
    }
    return self;
}

+ (instancetype)presetVideogameDecimatorWithInput:(AKParameter *)input;
{
    return [[AKDecimator alloc] initWithPresetVideogameDecimatorWithInput:input];
}

- (instancetype)initWithPresetRobotDecimatorWithInput:(AKParameter *)input;
{
    self = [super initWithString:[self operationName]];
    if (self) {
        _input = input;
        // Default Values
        _bitDepth = akp(20);
        _sampleRate = akp(1200);
        [self setUpConnections];
    }
    return self;
}

+ (instancetype)presetRobotDecimatorWithInput:(AKParameter *)input;
{
    return [[AKDecimator alloc] initWithPresetRobotDecimatorWithInput:input];
}


- (void)setBitDepth:(AKParameter *)bitDepth {
    _bitDepth = bitDepth;
    [self setUpConnections];
}

- (void)setOptionalBitDepth:(AKParameter *)bitDepth {
    [self setBitDepth:bitDepth];
}

- (void)setSampleRate:(AKParameter *)sampleRate {
    _sampleRate = sampleRate;
    [self setUpConnections];
}

- (void)setOptionalSampleRate:(AKParameter *)sampleRate {
    [self setSampleRate:sampleRate];
}


- (void)setUpConnections
{
    self.state = @"connectable";
    self.dependencies = @[_input, _bitDepth, _sampleRate];
}

- (NSString *)inlineStringForCSD
{
    NSMutableString *inlineCSDString = [[NSMutableString alloc] init];

    [inlineCSDString appendString:@"decimator("];
    [inlineCSDString appendString:[self inputsString]];
    [inlineCSDString appendString:@")"];

    return inlineCSDString;
}


- (NSString *)stringForCSD
{
    NSMutableString *csdString = [[NSMutableString alloc] init];

    [csdString appendFormat:@"%@ decimator ", self];
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

    if ([_bitDepth class] == [AKControl class]) {
        [inputsString appendFormat:@"%@, ", _bitDepth];
    } else {
        [inputsString appendFormat:@"AKControl(%@), ", _bitDepth];
    }

    if ([_sampleRate class] == [AKControl class]) {
        [inputsString appendFormat:@"%@", _sampleRate];
    } else {
        [inputsString appendFormat:@"AKControl(%@)", _sampleRate];
    }
    return inputsString;
}

- (NSString *)udoString {
    return @"\n"
    "opcode  decimator, a, akk\n"
    "setksmps  1\n"
    "ain, kbit, ksrate   xin\n"
    "kbits    = 2^kbit     ; Bit depth (1 to 16)\n"
    "kfold    = (sr/ksrate)      ; Sample rate\n"
    "kin      downsamp  ain      ; Convert to kr\n"
    "kin      = (kin + 32768)    ; Add DC to avoid (-)\n"
    "kin      = kin*(kbits / 65536)    ; Divide signal level\n"
    "kin      = int(kin)     ; Quantise\n"
    "aout     upsamp  kin      ; Convert to sr\n"
    "aout     = aout * (65536/kbits) - 32768 ; Scale and remove DC\n"
    "a0ut     fold  aout, kfold    ; Resample\n"
    "xout      a0ut\n"
    "endop\n";
}

@end
