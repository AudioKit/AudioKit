//
//  AKGuiro.m
//  AudioKit
//
//  Auto-generated on 2/19/15.
//  Copyright (c) 2015 Aurelius Prochazka. All rights reserved.
//
//  Implementation of Csound's guiro:
//  http://www.csounds.com/manual/html/guiro.html
//

#import "AKGuiro.h"
#import "AKManager.h"

@implementation AKGuiro

- (instancetype)initWithCount:(AKConstant *)count
        mainResonantFrequency:(AKConstant *)mainResonantFrequency
       firstResonantFrequency:(AKConstant *)firstResonantFrequency
                    amplitude:(AKParameter *)amplitude
{
    self = [super initWithString:[self operationName]];
    if (self) {
        _count = count;
        _mainResonantFrequency = mainResonantFrequency;
        _firstResonantFrequency = firstResonantFrequency;
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
        _count = akp(128);
        _mainResonantFrequency = akp(2500);
        _firstResonantFrequency = akp(4000);
        _amplitude = akp(0.5);
        [self setUpConnections];
    }
    return self;
}

+ (instancetype)guiro
{
    return [[AKGuiro alloc] init];
}

+ (instancetype)presetDefaultGuiro
{
    return [[AKGuiro alloc] init];
}

- (instancetype)initWithPresetSmallGuiro
{
    self = [super initWithString:[self operationName]];
    if (self) {
        // Default Values
        _count = akp(800);
        _mainResonantFrequency = akp(9000);
        _firstResonantFrequency = akp(4000);
        _amplitude = akp(0.5);
        [self setUpConnections];
    }
    return self;
}

+ (instancetype)presetSmallGuiro
{
    return [[AKGuiro alloc] initWithPresetSmallGuiro];
}

- (void)setCount:(AKConstant *)count {
    _count = count;
    [self setUpConnections];
}

- (void)setOptionalCount:(AKConstant *)count {
    [self setCount:count];
}

- (void)setMainResonantFrequency:(AKConstant *)mainResonantFrequency {
    _mainResonantFrequency = mainResonantFrequency;
    [self setUpConnections];
}

- (void)setOptionalMainResonantFrequency:(AKConstant *)mainResonantFrequency {
    [self setMainResonantFrequency:mainResonantFrequency];
}

- (void)setFirstResonantFrequency:(AKConstant *)firstResonantFrequency {
    _firstResonantFrequency = firstResonantFrequency;
    [self setUpConnections];
}

- (void)setOptionalFirstResonantFrequency:(AKConstant *)firstResonantFrequency {
    [self setFirstResonantFrequency:firstResonantFrequency];
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
    self.dependencies = @[_count, _mainResonantFrequency, _firstResonantFrequency, _amplitude];
}

- (NSString *)inlineStringForCSD
{
    NSMutableString *inlineCSDString = [[NSMutableString alloc] init];

    [inlineCSDString appendString:@"guiro("];
    [inlineCSDString appendString:[self inputsString]];
    [inlineCSDString appendString:@")"];

    return inlineCSDString;
}


- (NSString *)stringForCSD
{
    NSMutableString *csdString = [[NSMutableString alloc] init];

    [csdString appendFormat:@"%@ guiro ", self];
    [csdString appendString:[self inputsString]];
    return csdString;
}

- (NSString *)inputsString {
    NSMutableString *inputsString = [[NSMutableString alloc] init];

    // Constant Values  
    AKConstant *_energyReturn = akp(0);        
    AKConstant *_maximumDuration = akp(1.0);        
    AKConstant *_dampingFactor = akp(0);        
    
    if ([_amplitude class] == [AKControl class]) {
        [inputsString appendFormat:@"%@, ", _amplitude];
    } else {
        [inputsString appendFormat:@"AKControl(%@), ", _amplitude];
    }

    [inputsString appendFormat:@"%@, ", _maximumDuration];
    
    [inputsString appendFormat:@"%@, ", _count];
    
    [inputsString appendFormat:@"%@, ", _dampingFactor];
    
    [inputsString appendFormat:@"%@, ", _energyReturn];
    
    [inputsString appendFormat:@"%@, ", _mainResonantFrequency];
    
    [inputsString appendFormat:@"%@", _firstResonantFrequency];
    return inputsString;
}

@end
