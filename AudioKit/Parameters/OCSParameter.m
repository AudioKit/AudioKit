//
//  OCSParameter.m
//  Objective-C Sound
//
//  Created by Aurelius Prochazka on 6/5/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//

#import "OCSParameter.h"

@implementation OCSParameter

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

- (id)plus:(OCSParameter *)additionalParameter
{
    OCSParameter *new = [[OCSParameter alloc] init];
    [new setParameterString:[NSString stringWithFormat:@"((%@) + (%@))", self, additionalParameter]];
    return new;
}

- (id)scaledBy:(OCSParameter *)scalingFactor
{
    OCSParameter *new = [[OCSParameter alloc] init];
    [new setParameterString:[NSString stringWithFormat:@"((%@) * (%@))", self, scalingFactor]];
    return new;
}

- (id)dividedBy:(OCSParameter *)divisor
{
    OCSParameter *new = [[OCSParameter alloc] init];
    [new setParameterString:[NSString stringWithFormat:@"((%@) / (%@))", self, divisor]];
    return new;
}

- (id)inverse
{
    OCSParameter *new = [[OCSParameter alloc] init];
    [new setParameterString:[NSString stringWithFormat:@"(1/(%@))", self]];
    return new;
}

- (id)amplitudeFromFullScaleDecibel;
{
    OCSParameter *new = [[OCSParameter alloc] init];
    [new setParameterString:[NSString stringWithFormat:@"ampdbfs(%@)", _parameterString]];
    return new;
}


@end
