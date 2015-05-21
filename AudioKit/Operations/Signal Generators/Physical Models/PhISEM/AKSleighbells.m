//
//  AKSleighbells.m
//  AudioKit
//
//  Auto-generated on 2/19/15.
//  Copyright (c) 2015 Aurelius Prochazka. All rights reserved.
//
//  Implementation of Csound's sleighbells:
//  http://www.csounds.com/manual/html/sleighbells.html
//

#import "AKSleighbells.h"
#import "AKManager.h"

@implementation AKSleighbells

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
        _intensity = akp(32);
        _dampingFactor = akp(0.2);
        _mainResonantFrequency = akp(2500);
        _firstResonantFrequency = akp(5300);
        _secondResonantFrequency = akp(6500);
        _amplitude = akp(0.5);
        [self setUpConnections];
    }
    return self;
}

+ (instancetype)sleighbells
{
    return [[AKSleighbells alloc] init];
}

+ (instancetype)presetDefaultSleighbells
{
    return [[AKSleighbells alloc] init];
}

- (instancetype)initWithPresetSoftBells
{
    self = [super initWithString:[self operationName]];
    if (self) {
        // Default Values
        _intensity = akp(15);
        _dampingFactor = akp(0.4);
        _mainResonantFrequency = akp(2500);
        _firstResonantFrequency = akp(5300);
        _secondResonantFrequency = akp(6500);
        _amplitude = akp(0.5);
        [self setUpConnections];
    }
    return self;
}

+ (instancetype)presetSoftBells
{
    return [[AKSleighbells alloc] initWithPresetSoftBells];
}

- (instancetype)initWithPresetOpenBells
{
    self = [super initWithString:[self operationName]];
    if (self) {
        // Default Values
        _intensity = akp(40);
        _dampingFactor = akp(0.001);
        _mainResonantFrequency = akp(2500);
        _firstResonantFrequency = akp(5300);
        _secondResonantFrequency = akp(6500);
        _amplitude = akp(0.5);
        [self setUpConnections];
    }
    return self;
}

+ (instancetype)presetOpenBells
{
    return [[AKSleighbells alloc] initWithPresetOpenBells];
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

    [inlineCSDString appendString:@"sleighbells("];
    [inlineCSDString appendString:[self inputsString]];
    [inlineCSDString appendString:@")"];

    return inlineCSDString;
}


- (NSString *)stringForCSD
{
    NSMutableString *csdString = [[NSMutableString alloc] init];

    [csdString appendFormat:@"%@ sleighbells ", self];
    [csdString appendString:[self inputsString]];
    return csdString;
}

- (NSString *)inputsString {
    NSMutableString *inputsString = [[NSMutableString alloc] init];

    // Constant Values  
    AKConstant *_maximumDuration = akp(1);        
    AKConstant *_energyReturn = akp(0);        
    
    [inputsString appendFormat:@"%@, ", _amplitude];
    
    [inputsString appendFormat:@"%@, ", _maximumDuration];
    
    [inputsString appendFormat:@"%@, ", _intensity];
    
    [inputsString appendFormat:@"(1 - %@) * 0.25, ", _dampingFactor];
    
    [inputsString appendFormat:@"%@, ", _energyReturn];
    
    [inputsString appendFormat:@"%@, ", _mainResonantFrequency];
    
    [inputsString appendFormat:@"%@, ", _firstResonantFrequency];
    
    [inputsString appendFormat:@"%@", _secondResonantFrequency];
    return inputsString;
}

@end
