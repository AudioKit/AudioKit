//
//  AKBambooSticks.m
//  AudioKit
//
//  Auto-generated on 2/18/15.
//  Copyright (c) 2015 Aurelius Prochazka. All rights reserved.
//
//  Implementation of Csound's bamboo:
//  http://www.csounds.com/manual/html/bamboo.html
//

#import "AKBambooSticks.h"
#import "AKManager.h"

@implementation AKBambooSticks

- (instancetype)initWithCount:(AKConstant *)count
        mainResonantFrequency:(AKConstant *)mainResonantFrequency
       firstResonantFrequency:(AKConstant *)firstResonantFrequency
      secondResonantFrequency:(AKConstant *)secondResonantFrequency
                    amplitude:(AKConstant *)amplitude
{
    self = [super initWithString:[self operationName]];
    if (self) {
        _count = count;
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
        _count = akp(2);
        _mainResonantFrequency = akp(2800);
        _firstResonantFrequency = akp(2240);
        _secondResonantFrequency = akp(3360);
        _amplitude = akp(0.5);
        [self setUpConnections];
    }
    return self;
}

+ (instancetype)sticks
{
    return [[AKBambooSticks alloc] init];
}

+ (instancetype)presetDefaultSticks
{
    return [[AKBambooSticks alloc] init];
}

- (instancetype)initWithPresetManySticks
{
    self = [super initWithString:[self operationName]];
    if (self) {
        // Default Values
        _count = akp(10);
        _mainResonantFrequency = akp(2800);
        _firstResonantFrequency = akp(2240);
        _secondResonantFrequency = akp(3360);
        _amplitude = akp(0.5);
        [self setUpConnections];
    }
    return self;
}

+ (instancetype)presetManySticks
{
    return [[AKBambooSticks alloc] initWithPresetManySticks];
}


- (instancetype)initWithPresetFewSticks
{
    self = [super initWithString:[self operationName]];
    if (self) {
        // Default Values
        _count = akp(0.1);
        _mainResonantFrequency = akp(2800);
        _firstResonantFrequency = akp(2240);
        _secondResonantFrequency = akp(3360);
        _amplitude = akp(0.5);
        [self setUpConnections];
    }
    return self;
}

+ (instancetype)presetFewSticks
{
    return [[AKBambooSticks alloc] initWithPresetFewSticks];
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
    self.dependencies = @[_count, _mainResonantFrequency, _firstResonantFrequency, _secondResonantFrequency, _amplitude];
}

- (NSString *)inlineStringForCSD
{
    NSMutableString *inlineCSDString = [[NSMutableString alloc] init];

    [inlineCSDString appendString:@"bamboo("];
    [inlineCSDString appendString:[self inputsString]];
    [inlineCSDString appendString:@")"];

    return inlineCSDString;
}


- (NSString *)stringForCSD
{
    NSMutableString *csdString = [[NSMutableString alloc] init];

    [csdString appendFormat:@"%@ bamboo ", self];
    [csdString appendString:[self inputsString]];
    return csdString;
}

- (NSString *)inputsString {
    NSMutableString *inputsString = [[NSMutableString alloc] init];

    // Constant Values  
    AKConstant *_maximumDuration = akp(1);        
    AKConstant *_energyReturn = akp(0);        
    AKConstant *_dampingFactor = akp(0);        
    
    [inputsString appendFormat:@"%@, ", _amplitude];
    
    [inputsString appendFormat:@"%@, ", _maximumDuration];
    
    [inputsString appendFormat:@"%@, ", _count];
    
    [inputsString appendFormat:@"%@, ", _dampingFactor];
    
    [inputsString appendFormat:@"%@, ", _energyReturn];
    
    [inputsString appendFormat:@"%@, ", _mainResonantFrequency];
    
    [inputsString appendFormat:@"%@, ", _firstResonantFrequency];
    
    [inputsString appendFormat:@"%@", _secondResonantFrequency];
    return inputsString;
}

@end
