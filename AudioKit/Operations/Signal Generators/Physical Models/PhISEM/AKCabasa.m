//
//  AKCabasa.m
//  AudioKit
//
//  Auto-generated on 2/18/15.
//  Copyright (c) 2015 Aurelius Prochazka. All rights reserved.
//
//  Implementation of Csound's cabasa:
//  http://www.csounds.com/manual/html/cabasa.html
//

#import "AKCabasa.h"
#import "AKManager.h"

@implementation AKCabasa

- (instancetype)initWithCount:(AKConstant *)count
                dampingFactor:(AKConstant *)dampingFactor
                    amplitude:(AKConstant *)amplitude
{
    self = [super initWithString:[self operationName]];
    if (self) {
        _count = count;
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
        _count = akp(100);
        _dampingFactor = akp(0.14);
        _amplitude = akp(0.5);
        [self setUpConnections];
    }
    return self;
}

+ (instancetype)cabasa
{
    return [[AKCabasa alloc] init];
}

+ (instancetype)presetDefaultCabasa
{
    return [[AKCabasa alloc] init];
}

- (instancetype)initWithPresetMutedCabasa
{
    self = [super initWithString:[self operationName]];
    if (self) {
        // Default Values
        _count = akp(1000);
        _dampingFactor = akp(0.9);
        _amplitude = akp(0.5);
        [self setUpConnections];
    }
    return self;
}

+ (instancetype)presetMutedCabasa
{
    return [[AKCabasa alloc] initWithPresetMutedCabasa];
}

- (instancetype)initWithPresetLooseCabasa
{
    self = [super initWithString:[self operationName]];
    if (self) {
        // Default Values
        _count = akp(990);
        _dampingFactor = akp(0.2);
        _amplitude = akp(0.5);
        [self setUpConnections];
    }
    return self;
}

+ (instancetype)presetLooseCabasa
{
    return [[AKCabasa alloc] initWithPresetLooseCabasa];
}

- (void)setCount:(AKConstant *)count {
    _count = count;
    [self setUpConnections];
}

- (void)setOptionalCount:(AKConstant *)count {
    [self setCount:count];
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
    self.dependencies = @[_count, _dampingFactor, _amplitude];
}

- (NSString *)inlineStringForCSD
{
    NSMutableString *inlineCSDString = [[NSMutableString alloc] init];

    [inlineCSDString appendString:@"cabasa("];
    [inlineCSDString appendString:[self inputsString]];
    [inlineCSDString appendString:@")"];

    return inlineCSDString;
}


- (NSString *)stringForCSD
{
    NSMutableString *csdString = [[NSMutableString alloc] init];

    [csdString appendFormat:@"%@ cabasa ", self];
    [csdString appendString:[self inputsString]];
    return csdString;
}

- (NSString *)inputsString {
    NSMutableString *inputsString = [[NSMutableString alloc] init];

    // Constant Values  
    AKConstant *_maximumDuration = akp(1);        
    
    [inputsString appendFormat:@"%@, ", _amplitude];
    
    [inputsString appendFormat:@"%@, ", _maximumDuration];
    
    [inputsString appendFormat:@"%@, ", _count];
    
    [inputsString appendFormat:@"(1 - 0.5*%@)", _dampingFactor];
    return inputsString;
}

@end
