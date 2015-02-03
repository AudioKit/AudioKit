//
//  AKDecimator.m
//  AudioKit
//
//  Auto-generated on 2/2/15.
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
    }
    return self;
}

+ (instancetype)WithInput:(AKParameter *)input
{
    return [[AKDecimator alloc] initWithInput:input];
}

- (void)setOptionalBitDepth:(AKParameter *)bitDepth {
    _bitDepth = bitDepth;
}
- (void)setOptionalSampleRate:(AKParameter *)sampleRate {
    _sampleRate = sampleRate;
}

- (NSString *)stringForCSD {
    NSMutableString *csdString = [[NSMutableString alloc] init];

    [csdString appendFormat:@"%@ decimator ", self];

    if ([_input class] == [AKAudio class]) {
        [csdString appendFormat:@"%@, ", _input];
    } else {
        [csdString appendFormat:@"AKAudio(%@), ", _input];
    }

    if ([_bitDepth class] == [AKControl class]) {
        [csdString appendFormat:@"%@, ", _bitDepth];
    } else {
        [csdString appendFormat:@"AKControl(%@), ", _bitDepth];
    }

    if ([_sampleRate class] == [AKControl class]) {
        [csdString appendFormat:@"%@", _sampleRate];
    } else {
        [csdString appendFormat:@"AKControl(%@)", _sampleRate];
    }
return csdString;
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
