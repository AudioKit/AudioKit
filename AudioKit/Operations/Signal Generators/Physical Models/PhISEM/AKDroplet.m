//
//  AKDroplet.m
//  AudioKit
//
//  Auto-generated on 2/18/15.
//  Copyright (c) 2015 Aurelius Prochazka. All rights reserved.
//
//  Implementation of Csound's dripwater:
//  http://www.csounds.com/manual/html/dripwater.html
//

#import "AKDroplet.h"
#import "AKManager.h"

@implementation AKDroplet

- (instancetype)initWithIntensity:(AKConstant *)intensity
                    dampingFactor:(AKConstant *)dampingFactor
                     energyReturn:(AKConstant *)energyReturn
            mainResonantFrequency:(AKConstant *)mainResonantFrequency
           firstResonantFrequency:(AKConstant *)firstResonantFrequency
          secondResonantFrequency:(AKConstant *)secondResonantFrequency
                        amplitude:(AKParameter *)amplitude
{
    self = [super initWithString:[self operationName]];
    if (self) {
        _intensity = intensity;
        _dampingFactor = dampingFactor;
        _energyReturn = energyReturn;
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
        _intensity = akp(10);
        _dampingFactor = akp(0.1);
        _energyReturn = akp(0.5);
        _mainResonantFrequency = akp(450);
        _firstResonantFrequency = akp(600);
        _secondResonantFrequency = akp(750);
        _amplitude = akp(0.5);
        [self setUpConnections];
    }
    return self;
}

+ (instancetype)droplet
{
    return [[AKDroplet alloc] init];
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

- (void)setEnergyReturn:(AKConstant *)energyReturn {
    _energyReturn = energyReturn;
    [self setUpConnections];
}

- (void)setOptionalEnergyReturn:(AKConstant *)energyReturn {
    [self setEnergyReturn:energyReturn];
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
    self.dependencies = @[_intensity, _dampingFactor, _energyReturn, _mainResonantFrequency, _firstResonantFrequency, _secondResonantFrequency, _amplitude];
}

- (NSString *)inlineStringForCSD
{
    NSMutableString *inlineCSDString = [[NSMutableString alloc] init];

    [inlineCSDString appendString:@"dripwater("];
    [inlineCSDString appendString:[self inputsString]];
    [inlineCSDString appendString:@")"];

    return inlineCSDString;
}


- (NSString *)stringForCSD
{
    NSMutableString *csdString = [[NSMutableString alloc] init];

    [csdString appendFormat:@"%@ dripwater ", self];
    [csdString appendString:[self inputsString]];
    return csdString;
}

- (NSString *)inputsString {
    NSMutableString *inputsString = [[NSMutableString alloc] init];

    // Constant Values  
    AKConstant *_maximumDuration = akp(1);        
    
    if ([_amplitude class] == [AKControl class]) {
        [inputsString appendFormat:@"%@, ", _amplitude];
    } else {
        [inputsString appendFormat:@"AKControl(%@), ", _amplitude];
    }

    [inputsString appendFormat:@"%@, ", _maximumDuration];
    
    [inputsString appendFormat:@"%@, ", _intensity];
    
    [inputsString appendFormat:@"(1 - %@), ", _dampingFactor];
    
    [inputsString appendFormat:@"%@, ", _energyReturn];
    
    [inputsString appendFormat:@"%@, ", _mainResonantFrequency];
    
    [inputsString appendFormat:@"%@, ", _firstResonantFrequency];
    
    [inputsString appendFormat:@"%@", _secondResonantFrequency];
    return inputsString;
}

@end
