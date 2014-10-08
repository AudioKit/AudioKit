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

+(id)parameterWithString:(NSString *)name
{
    return [[self alloc] initWithString:name];
}

+(id)globalParameter
{
    return [[self alloc] initGlobalWithString:@"Global"];
}

+(id)globalParameterWithString:(NSString *)name
{
    return [[self alloc] initGlobalWithString:name];
}

+(id)parameterWithFormat:(NSString *)format, ... {
    va_list argumentList;
    va_start(argumentList, format);
    return [[self alloc] initWithExpression:[[NSString alloc] initWithFormat:format arguments:argumentList]];
    va_end(argumentList);
}
 
- (NSString *)description {
    return _parameterString;
}

- (id)plus:(AKParameter *)additionalParameter
{
    AKParameter *new = [[AKParameter alloc] init];
    [new setParameterString:[NSString stringWithFormat:@"((%@) + (%@))", self, additionalParameter]];
    return new;
}

- (id)scaledBy:(AKParameter *)scalingFactor
{
    AKParameter *new = [[AKParameter alloc] init];
    [new setParameterString:[NSString stringWithFormat:@"((%@) * (%@))", self, scalingFactor]];
    return new;
}

- (id)dividedBy:(AKParameter *)divisor
{
    AKParameter *new = [[AKParameter alloc] init];
    [new setParameterString:[NSString stringWithFormat:@"((%@) / (%@))", self, divisor]];
    return new;
}

- (id)inverse
{
    AKParameter *new = [[AKParameter alloc] init];
    [new setParameterString:[NSString stringWithFormat:@"(1/(%@))", self]];
    return new;
}

- (id)amplitudeFromFullScaleDecibel;
{
    AKParameter *new = [[AKParameter alloc] init];
    [new setParameterString:[NSString stringWithFormat:@"ampdbfs(%@)", _parameterString]];
    return new;
}


@end
