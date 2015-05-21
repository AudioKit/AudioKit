//
//  AKTambourine.m
//  AudioKit
//
//  Auto-generated on 2/19/15.
//  Copyright (c) 2015 Aurelius Prochazka. All rights reserved.
//
//  Implementation of Csound's tambourine:
//  http://www.csounds.com/manual/html/tambourine.html
//

#import "AKTambourine.h"
#import "AKManager.h"

@implementation AKTambourine

- (instancetype)initWithIntensity:(AKConstant *)intensity
                    dampingFactor:(AKConstant *)dampingFactor
            mainResonantFrequency:(AKConstant *)mainResonantFrequency
           firstResonantFrequency:(AKConstant *)firstResonantFrequency
          secondResonantFrequency:(AKConstant *)secondResonantFrequency
                        amplitude:(AKConstant *)amplitude
{
    self = [super initWithString:[self operationName]];
    if (self) {
        _intensity = intensity;
        _dampingFactor = dampingFactor;
        _mainResonantFrequency = mainResonantFrequency;
        _firstResonantFrequency = firstResonantFrequency;
        _secondResonantFrequency = secondResonantFrequency;
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
        _intensity = akp(1000);
        _dampingFactor = akp(0.1);
        _mainResonantFrequency = akp(2300);
        _firstResonantFrequency = akp(5600);
        _secondResonantFrequency = akp(8100);
        _amplitude = akp(0.5);
        [self setUpConnections];
    }
    return self;
}

+ (instancetype)tambourine
{
    return [[AKTambourine alloc] init];
}

+ (instancetype)presetDefaultTambourine
{
    return [[AKTambourine alloc] init];
}

- (instancetype)initWithPresetOpenTambourine
{
    self = [super initWithString:[self operationName]];
    if (self) {
        // Default Values
        _intensity = akp(400);
        _dampingFactor = akp(0.01);
        _mainResonantFrequency = akp(3000);
        _firstResonantFrequency = akp(5600);
        _secondResonantFrequency = akp(8100);
        _amplitude = akp(0.5);
        [self setUpConnections];
    }
    return self;
}

+ (instancetype)presetOpenTambourine
{
    return [[AKTambourine alloc] initWithPresetOpenTambourine];
}

- (instancetype)initWithPresetClosedTambourine
{
    self = [super initWithString:[self operationName]];
    if (self) {
        // Default Values
        _intensity = akp(875);
        _dampingFactor = akp(0.55);
        _mainResonantFrequency = akp(2500);
        _firstResonantFrequency = akp(5600);
        _secondResonantFrequency = akp(8100);
        _amplitude = akp(0.5);
        [self setUpConnections];
    }
    return self;
}

+ (instancetype)presetClosedTambourine
{
    return [[AKTambourine alloc] initWithPresetClosedTambourine];
}

- (void)setIntensity:(AKConstant *)intensity {
    _intensity = intensity;
    [self setUpConnections];
}

- (void)setOptionalIntensity:(AKConstant *)intensity {
    [self setIntensity:intensity];
}

- (void)setDampingFactor:(AKConstant *)dampingFactor {
    _dampingFactor = dampingFactor;
    [self setUpConnections];
}

- (void)setOptionalDampingFactor:(AKConstant *)dampingFactor {
    [self setDampingFactor:dampingFactor];
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

- (void)setSecondResonantFrequency:(AKConstant *)secondResonantFrequency {
    _secondResonantFrequency = secondResonantFrequency;
    [self setUpConnections];
}

- (void)setOptionalSecondResonantFrequency:(AKConstant *)secondResonantFrequency {
    [self setSecondResonantFrequency:secondResonantFrequency];
}

- (void)setAmplitude:(AKConstant *)amplitude {
    _amplitude = amplitude;
    [self setUpConnections];
}

- (void)setOptionalAmplitude:(AKConstant *)amplitude {
    [self setAmplitude:amplitude];
}


- (void)setUpConnections
{
    self.state = @"connectable";
    self.dependencies = @[_intensity, _dampingFactor, _mainResonantFrequency, _firstResonantFrequency, _secondResonantFrequency, _amplitude];
}

- (NSString *)inlineStringForCSD
{
    NSMutableString *inlineCSDString = [[NSMutableString alloc] init];

    [inlineCSDString appendString:@"tambourine("];
    [inlineCSDString appendString:[self inputsString]];
    [inlineCSDString appendString:@")"];

    return inlineCSDString;
}


- (NSString *)stringForCSD
{
    NSMutableString *csdString = [[NSMutableString alloc] init];

    [csdString appendFormat:@"%@ tambourine ", self];
    [csdString appendString:[self inputsString]];
    return csdString;
}

- (NSString *)inputsString {
    NSMutableString *inputsString = [[NSMutableString alloc] init];

    // Constant Values  
    AKConstant *_energyReturn = akp(0);        
    AKConstant *_maximumDuration = akp(1);        
    
    [inputsString appendFormat:@"%@, ", _amplitude];
    
    [inputsString appendFormat:@"%@, ", _maximumDuration];
    
    [inputsString appendFormat:@"%@, ", _intensity];
    
    [inputsString appendFormat:@"(1 - %@) * 0.7, ", _dampingFactor];
    
    [inputsString appendFormat:@"%@, ", _energyReturn];
    
    [inputsString appendFormat:@"%@, ", _mainResonantFrequency];
    
    [inputsString appendFormat:@"%@, ", _firstResonantFrequency];
    
    [inputsString appendFormat:@"%@", _secondResonantFrequency];
    return inputsString;
}

@end
