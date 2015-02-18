//
//  AKFMOscillator.m
//  AudioKit
//
//  Auto-generated on 2/18/15.
//  Copyright (c) 2015 Aurelius Prochazka. All rights reserved.
//
//  Implementation of Csound's foscili:
//  http://www.csounds.com/manual/html/foscili.html
//

#import "AKFMOscillator.h"
#import "AKManager.h"

@implementation AKFMOscillator

- (instancetype)initWithFunctionTable:(AKFunctionTable *)functionTable
                        baseFrequency:(AKParameter *)baseFrequency
                    carrierMultiplier:(AKParameter *)carrierMultiplier
                 modulatingMultiplier:(AKParameter *)modulatingMultiplier
                      modulationIndex:(AKParameter *)modulationIndex
                            amplitude:(AKParameter *)amplitude
{
    self = [super initWithString:[self operationName]];
    if (self) {
        _functionTable = functionTable;
        _baseFrequency = baseFrequency;
        _carrierMultiplier = carrierMultiplier;
        _modulatingMultiplier = modulatingMultiplier;
        _modulationIndex = modulationIndex;
        _amplitude = amplitude;
    }
    return self;
}

- (instancetype)init
{
    self = [super initWithString:[self operationName]];
    if (self) {
        // Default Values
        _functionTable = [AKManager standardSineWave];
    
        _baseFrequency = akp(440);
        _carrierMultiplier = akp(1);
        _modulatingMultiplier = akp(1);
        _modulationIndex = akp(1);
        _amplitude = akp(0.5);
    }
    return self;
}

+ (instancetype)oscillator
{
    return [[AKFMOscillator alloc] init];
}

- (void)setOptionalFunctionTable:(AKFunctionTable *)functionTable {
    _functionTable = functionTable;
}
- (void)setOptionalBaseFrequency:(AKParameter *)baseFrequency {
    _baseFrequency = baseFrequency;
}
- (void)setOptionalCarrierMultiplier:(AKParameter *)carrierMultiplier {
    _carrierMultiplier = carrierMultiplier;
}
- (void)setOptionalModulatingMultiplier:(AKParameter *)modulatingMultiplier {
    _modulatingMultiplier = modulatingMultiplier;
}
- (void)setOptionalModulationIndex:(AKParameter *)modulationIndex {
    _modulationIndex = modulationIndex;
}
- (void)setOptionalAmplitude:(AKParameter *)amplitude {
    _amplitude = amplitude;
}

- (NSString *)inlineStringForCSD
{
    NSMutableString *inlineCSDString = [[NSMutableString alloc] init];

    [inlineCSDString appendString:@"foscili("];
    [inlineCSDString appendString:[self inputsString]];
    [inlineCSDString appendString:@")"];

    return inlineCSDString;
}


- (NSString *)stringForCSD
{
    NSMutableString *csdString = [[NSMutableString alloc] init];

    [csdString appendFormat:@"%@ foscili ", self];
    [csdString appendString:[self inputsString]];
    return csdString;
}

- (NSString *)inputsString {
    NSMutableString *inputsString = [[NSMutableString alloc] init];

    // Constant Values  
    AKConstant *_phase = akp(-1);        
    
    [inputsString appendFormat:@"%@, ", _amplitude];
    
    if ([_baseFrequency class] == [AKControl class]) {
        [inputsString appendFormat:@"%@, ", _baseFrequency];
    } else {
        [inputsString appendFormat:@"AKControl(%@), ", _baseFrequency];
    }

    [inputsString appendFormat:@"%@, ", _carrierMultiplier];
    
    [inputsString appendFormat:@"%@, ", _modulatingMultiplier];
    
    if ([_modulationIndex class] == [AKControl class]) {
        [inputsString appendFormat:@"%@, ", _modulationIndex];
    } else {
        [inputsString appendFormat:@"AKControl(%@), ", _modulationIndex];
    }

    [inputsString appendFormat:@"%@, ", _functionTable];
    
    [inputsString appendFormat:@"%@", _phase];
    return inputsString;
}

@end
