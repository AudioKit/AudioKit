//
//  AKFTable.m
//  AudioKit
//
//  Created by Aurelius Prochazka on 4/12/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//

#import "AKFTable.h"

@implementation AKFTable
{
    AKFTableType igen;
    AKConstant *output;
}

- (instancetype)initWithType:(AKFTableType)fTableType
                        size:(int)tableSize
                  parameters:(AKArray *)parameters;
{
    self = [super init];
    if (self) {
        output = [AKConstant globalParameterWithString:[self functionName]];
        _size = tableSize;
        igen = fTableType;
        _parameters = parameters;
        _isNormalized = NO;
    }
    return self;
}

- (instancetype)initWithType:(AKFTableType)fTableType
                  parameters:(AKArray *)parameters;
{
    return [self initWithType:fTableType size:0 parameters:parameters];
}

- (NSString *)functionName
{
    NSString *functionName = [NSString stringWithFormat:@"%@", [self class]];
    functionName = [functionName stringByReplacingOccurrencesOfString:@"AK" withString:@""];
    return functionName;
}


// Csound Prototype: ifno ftgentmp ip1, ip2dummy, isize, igen, iarga, iargb, ...
- (NSString *)stringForCSD
{
    if (_isNormalized) {
        igen = abs(igen);
    } else {
        igen = -abs(igen);
    }
    NSString *text;
    if (_parameters == nil) {
        text = [NSString stringWithFormat:@"%@ ftgen 0, 0, %i, %i",
                output, _size, igen];
    } else {
        text = [NSString stringWithFormat:@"%@ ftgen 0, 0, %i, %i, %@",
                output, _size, igen, [_parameters parameterString]];
    }
    return text;
}

- (NSString *)fTableStringForCSD
{
    if (_isNormalized) {
        igen = abs(igen);
    } else {
        igen = -abs(igen);
    }
    NSString *text;
    if (_parameters == nil) {
        text = [NSString stringWithFormat:@"%@ ftgen 0, 0, %i, %i",
                output, _size, igen];
    } else {
        text = [NSString stringWithFormat:@"%@ ftgen 0, 0, %i, %i, %@",
                output, _size, igen, [_parameters parameterString]];
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
