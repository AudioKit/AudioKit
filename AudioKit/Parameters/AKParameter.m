//
//  AKParameter.m
//  AudioKit
//
//  Created by Aurelius Prochazka on 6/5/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//

#import "AKParameter.h"

@implementation AKParameter

static int currentID = 1;

+(void) resetID {
    currentID = 1;
}

- (instancetype)init
{
    self = [super init];
    _myID = currentID++;
    return self;
}

- (instancetype)initWithString:(NSString *)name
{
    self = [super init];
    if (self) {
        _myID = currentID++;
        _parameterString = [NSString stringWithFormat:@"a%@%i", name, _myID];
    }
    return self;
}

- (instancetype)initGlobalWithString:(NSString *)name
{
    self = [super init];
    if (self) {
        _myID = currentID++;
        _parameterString = [NSString stringWithFormat:@"ga%@%i", name, _myID];
    }
    return self;
}

- (instancetype)initWithExpression:(NSString *)expression
{
    self = [super init];
    if (self) {
        _parameterString = [NSString stringWithString:expression];
    }
    return self;
}

+ (instancetype)parameterWithString:(NSString *)name
{
    return [[self alloc] initWithString:name];
}

+ (instancetype)globalParameter
{
    return [[self alloc] initGlobalWithString:@"Global"];
}

+ (instancetype)globalParameterWithString:(NSString *)name
{
    return [[self alloc] initGlobalWithString:name];
}

- (NSString *)description {
    return _parameterString;
}

- (instancetype)plus:(AKParameter *)additionalParameter
{
    AKParameter *new = [[AKParameter alloc] init];
    [new setParameterString:[NSString stringWithFormat:@"((%@) + (%@))", self, additionalParameter]];
    return new;
}

- (instancetype)scaledBy:(AKParameter *)scalingFactor
{
    AKParameter *new = [[AKParameter alloc] init];
    [new setParameterString:[NSString stringWithFormat:@"((%@) * (%@))", self, scalingFactor]];
    return new;
}

- (instancetype)dividedBy:(AKParameter *)divisor
{
    AKParameter *new = [[AKParameter alloc] init];
    [new setParameterString:[NSString stringWithFormat:@"((%@) / (%@))", self, divisor]];
    return new;
}

- (instancetype)inverse
{
    AKParameter *new = [[AKParameter alloc] init];
    [new setParameterString:[NSString stringWithFormat:@"(1/(%@))", self]];
    return new;
}

- (instancetype)amplitudeFromFullScaleDecibel;
{
    AKParameter *new = [[AKParameter alloc] init];
    [new setParameterString:[NSString stringWithFormat:@"ampdbfs(%@)", _parameterString]];
    return new;
}

@end
