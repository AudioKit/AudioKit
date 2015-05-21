//
//  AKSandPaper.m
//  AudioKit
//
//  Auto-generated on 2/19/15.
//  Copyright (c) 2015 Aurelius Prochazka. All rights reserved.
//
//  Implementation of Csound's sandpaper:
//  http://www.csounds.com/manual/html/sandpaper.html
//

#import "AKSandPaper.h"
#import "AKManager.h"

@implementation AKSandPaper

- (instancetype)initWithIntensity:(AKConstant *)intensity
                    dampingFactor:(AKConstant *)dampingFactor
{
    self = [super initWithString:[self operationName]];
    if (self) {
        _intensity = intensity;
        _dampingFactor = dampingFactor;
        [self setUpConnections];
}
    return self;
}

- (instancetype)init
{
    self = [super initWithString:[self operationName]];
    if (self) {
        // Default Values
        _intensity = akp(128);
        _dampingFactor = akp(0.1);
        [self setUpConnections];
    }
    return self;
}

+ (instancetype)sandPaper
{
    return [[AKSandPaper alloc] init];
}

+ (instancetype)presetDefaultSandPaper
{
    return [[AKSandPaper alloc] init];
}

- (instancetype)initWithPresetMuffledSandPaper
{
    self = [super initWithString:[self operationName]];
    if (self) {
        // Default Values
        _intensity = akp(100000);
        _dampingFactor = akp(.5);
        [self setUpConnections];
    }
    return self;
}

+ (instancetype)presetMuffledSandPaper
{
    return [[AKSandPaper alloc] initWithPresetMuffledSandPaper];
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


- (void)setUpConnections
{
    self.state = @"connectable";
    self.dependencies = @[_intensity, _dampingFactor];
}

- (NSString *)inlineStringForCSD
{
    NSMutableString *inlineCSDString = [[NSMutableString alloc] init];

    [inlineCSDString appendString:@"sandpaper("];
    [inlineCSDString appendString:[self inputsString]];
    [inlineCSDString appendString:@")"];

    return inlineCSDString;
}


- (NSString *)stringForCSD
{
    NSMutableString *csdString = [[NSMutableString alloc] init];

    [csdString appendFormat:@"%@ sandpaper ", self];
    [csdString appendString:[self inputsString]];
    return csdString;
}

- (NSString *)inputsString {
    NSMutableString *inputsString = [[NSMutableString alloc] init];

    // Constant Values  
    AKConstant *_amplitude = akp(0.5);        
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
