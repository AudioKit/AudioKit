//
//  AKStick.m
//  AudioKit
//
//  Auto-generated on 2/19/15.
//  Copyright (c) 2015 Aurelius Prochazka. All rights reserved.
//
//  Implementation of Csound's stix:
//  http://www.csounds.com/manual/html/stix.html
//

#import "AKStick.h"
#import "AKManager.h"

@implementation AKStick

- (instancetype)initWithIntensity:(AKConstant *)intensity
                    dampingFactor:(AKConstant *)dampingFactor
                        amplitude:(AKConstant *)amplitude
{
    self = [super initWithString:[self operationName]];
    if (self) {
        _intensity = intensity;
        _dampingFactor = dampingFactor;
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
        _intensity = akp(30);
        _dampingFactor = akp(0.3);
        _amplitude = akp(0.5);
        [self setUpConnections];
    }
    return self;
}

+ (instancetype)stick
{
    return [[AKStick alloc] init];
}

+ (instancetype)presetDefaultStick
{
    return [[AKStick alloc] init];
}

- (instancetype)initWithPresetBundleOfSticks
{
    self = [super initWithString:[self operationName]];
    if (self) {
        // Default Values
        _intensity = akp(50);
        _dampingFactor = akp(0.09);
        _amplitude = akp(0.5);
        [self setUpConnections];
    }
    return self;
}

+ (instancetype)presetBundleOfSticks
{
    return [[AKStick alloc] initWithPresetBundleOfSticks];
}

- (instancetype)initWithPresetThickStick
{
    self = [super initWithString:[self operationName]];
    if (self) {
        // Default Values
        _intensity = akp(1000);
        _dampingFactor = akp(1);
        _amplitude = akp(0.5);
        [self setUpConnections];
    }
    return self;
}

+ (instancetype)presetThickStick
{
    return [[AKStick alloc] initWithPresetThickStick];
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
    self.dependencies = @[_intensity, _dampingFactor, _amplitude];
}

- (NSString *)inlineStringForCSD
{
    NSMutableString *inlineCSDString = [[NSMutableString alloc] init];

    [inlineCSDString appendString:@"stix("];
    [inlineCSDString appendString:[self inputsString]];
    [inlineCSDString appendString:@")"];

    return inlineCSDString;
}


- (NSString *)stringForCSD
{
    NSMutableString *csdString = [[NSMutableString alloc] init];

    [csdString appendFormat:@"%@ stix ", self];
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
    
    [inputsString appendFormat:@"(1 - %@), ", _dampingFactor];
    
    [inputsString appendFormat:@"%@", _energyReturn];
    return inputsString;
}

@end
