//
//  AKOscillator.m
//  AudioKit
//
//  Auto-generated on 2/18/15.
//  Copyright (c) 2015 Aurelius Prochazka. All rights reserved.
//
//  Implementation of Csound's oscili:
//  http://www.csounds.com/manual/html/oscili.html
//

#import "AKOscillator.h"
#import "AKManager.h"

@implementation AKOscillator

- (instancetype)initWithFunctionTable:(AKFunctionTable *)functionTable
                            frequency:(AKParameter *)frequency
                            amplitude:(AKParameter *)amplitude
{
    self = [super initWithString:[self operationName]];
    if (self) {
        _functionTable = functionTable;
        _frequency = frequency;
        _amplitude = amplitude;
        [self setUpConnections];
}
    return self;
}

- (instancetype)init
{
    self = [super initWithString:[self operationName]];
    if (self) {
        // Default Values
        _functionTable = [AKManager standardSineWave];
    
        _frequency = akp(440);
        _amplitude = akp(1);
        [self setUpConnections];
    }
    return self;
}

+ (instancetype)oscillator
{
    return [[AKOscillator alloc] init];
}

- (void)setFunctionTable:(AKFunctionTable *)functionTable {
    _functionTable = functionTable;
    [self setUpConnections];
}

- (void)setOptionalFunctionTable:(AKFunctionTable *)functionTable {
    [self setFunctionTable:functionTable];
}

- (void)setFrequency:(AKParameter *)frequency {
    _frequency = frequency;
    [self setUpConnections];
}

- (void)setOptionalFrequency:(AKParameter *)frequency {
    [self setFrequency:frequency];
}

- (void)setAmplitude:(AKParameter *)amplitude {
    _amplitude = amplitude;
    [self setUpConnections];
}

- (void)setOptionalAmplitude:(AKParameter *)amplitude {
    [self setAmplitude:amplitude];
}


- (void)setUpConnections
{
    self.state = @"connectable";
    self.dependencies = @[_functionTable, _frequency, _amplitude];
}

- (NSString *)inlineStringForCSD
{
    NSMutableString *inlineCSDString = [[NSMutableString alloc] init];

    [inlineCSDString appendString:@"oscili("];
    [inlineCSDString appendString:[self inputsString]];
    [inlineCSDString appendString:@")"];

    return inlineCSDString;
}


- (NSString *)stringForCSD
{
    NSMutableString *csdString = [[NSMutableString alloc] init];

    [csdString appendFormat:@"%@ oscili ", self];
    [csdString appendString:[self inputsString]];
    return csdString;
}

- (NSString *)inputsString {
    NSMutableString *inputsString = [[NSMutableString alloc] init];

    // Constant Values  
    AKConstant *_phase = akp(-1);        
    
    [inputsString appendFormat:@"%@, ", _amplitude];
    
    [inputsString appendFormat:@"%@, ", _frequency];
    
    [inputsString appendFormat:@"%@, ", _functionTable];
    
    [inputsString appendFormat:@"%@", _phase];
    return inputsString;
}

@end
