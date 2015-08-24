//
//  AKSekere.m
//  AudioKit
//
//  Auto-generated on 2/19/15.
//  Copyright (c) 2015 Aurelius Prochazka. All rights reserved.
//
//  Implementation of Csound's sekere:
//  http://www.csounds.com/manual/html/sekere.html
//

#import "AKSekere.h"
#import "AKManager.h"

@implementation AKSekere

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
        _count = akp(64);
        _dampingFactor = akp(0.1);
        _amplitude = akp(0.5);
        [self setUpConnections];
    }
    return self;
}

+ (instancetype)sekere
{
    return [[AKSekere alloc] init];
}

+ (instancetype)presetDefaultSekere
{
    return [[AKSekere alloc] init];
}

- (instancetype)initWithPresetManyBeadsSekere
{
    self = [super initWithString:[self operationName]];
    if (self) {
        // Default Values
        _count = akp(10000);
        _dampingFactor = akp(0.09);
        _amplitude = akp(0.5);
        [self setUpConnections];
    }
    return self;
}

+ (instancetype)presetManyBeadsSekere
{
    return [[AKSekere alloc] initWithPresetManyBeadsSekere];
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

    [inlineCSDString appendString:@"sekere("];
    [inlineCSDString appendString:[self inputsString]];
    [inlineCSDString appendString:@")"];

    return inlineCSDString;
}


- (NSString *)stringForCSD
{
    NSMutableString *csdString = [[NSMutableString alloc] init];

    [csdString appendFormat:@"%@ sekere ", self];
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
    
    [inputsString appendFormat:@"%@, ", _count];
    
    [inputsString appendFormat:@"(1 - %@), ", _dampingFactor];
    
    [inputsString appendFormat:@"%@", _energyReturn];
    return inputsString;
}

@end
