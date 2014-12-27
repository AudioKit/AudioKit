//
//  AKFunctionTable.m
//  AudioKit
//
//  Created by Aurelius Prochazka on 4/12/12.
//  Copyright (c) 2012 Aurelius Prochazka. All rights reserved.
//

#import "AKFunctionTable.h"

@implementation AKFunctionTable
{
    AKFunctionTableType igen;
    AKConstant *output;
}

- (instancetype)initWithType:(AKFunctionTableType)functionTableType
                        size:(int)tableSize
                  parameters:(AKArray *)parameters
{
    self = [super init];
    if (self) {
        output = [AKConstant globalParameterWithString:[self functionName]];
        _size = tableSize;
        igen = functionTableType;
        _parameters = parameters;
        _isNormalized = NO;
    }
    return self;
}

- (instancetype)initWithType:(AKFunctionTableType)functionTableType
                  parameters:(AKArray *)parameters
{
    return [self initWithType:functionTableType size:0 parameters:parameters];
}

- (instancetype)initWithType:(AKFunctionTableType)functionTableType
{
    AKArray *parameters = [[AKArray alloc] init];
    return [self initWithType:functionTableType size:0 parameters:parameters];
}

- (NSString *)functionName
{
    NSString *functionName = [NSString stringWithFormat:@"%@", [self class]];
    functionName = [functionName stringByReplacingOccurrencesOfString:@"AK" withString:@""];
    return functionName;
}

// Csound Prototype: ifno ftgen ip1, ip2dummy, isize, igen, iarga, iargb, ...
- (NSString *)stringForCSD
{
    if (_isNormalized) {
        igen = abs(igen);
    } else {
        igen = -abs(igen);
    }
    NSString *text;
    if (_parameters == nil) {
        text = [NSString stringWithFormat:@"%@ ftgen 0, 0, %i, %@",
                output, _size, akpi(igen)];
    } else {
        text = [NSString stringWithFormat:@"%@ ftgen 0, 0, %i, %@, %@",
                output, _size, akpi(igen), [_parameters parameterString]];
    }
    return text;
}

- (NSString *)description
{
    return [output parameterString];
}

- (AKConstant *)length
{
    AKConstant *new = [[AKConstant alloc] init];
    [new setParameterString:[NSString stringWithFormat:@"ftlen(%@)", output]];
    return new;
}

@end
