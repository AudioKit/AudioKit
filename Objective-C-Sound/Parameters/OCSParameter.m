//
//  OCSParameter.m
//  Objective-C Sound
//
//  Created by Adam Boulanger on 6/5/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//

#import "OCSParameter.h"

@implementation OCSParameter
@synthesize parameterString;

static int currentID = 1;

+(void) resetID {
    currentID = 1;
}

- (id)init
{
    self = [super init];
    _myID = currentID++;
    return self;
}
- (id)initWithString:(NSString *)name
{
    self = [super init];
    if (self) {
        _myID = currentID++;
        parameterString = [NSString stringWithFormat:@"a%@%i", name, _myID];
    }
    return self;
}

- (id)initGlobalWithString:(NSString *)name
{
    self = [super init];
    if (self) {
        _myID = currentID++;
        parameterString = [NSString stringWithFormat:@"ga%@%i", name, _myID];
    }
    return self;
}

- (id)initWithExpression:(NSString *)expression
{
    self = [super init];
    if (self) {
        parameterString = [NSString stringWithString:expression];
    }
    return self;
}

+(id)parameterWithString:(NSString *)name
{
    return [[self alloc] initWithString:name];
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
    return parameterString;
}

- (id)scaledBy:(float)scalingFactor
{
    OCSParameter *new = [[OCSParameter alloc] init];
    [new setParameterString:[NSString stringWithFormat:@"((%@) * %g)", parameterString, scalingFactor]];
    return new;
}

- (id)amplitudeFromFullScaleDecibel;
{
    OCSParameter *new = [[OCSParameter alloc] init];
    [new setParameterString:[NSString stringWithFormat:@"ampdbfs(%@)", parameterString]];
    return new;
}


@end
