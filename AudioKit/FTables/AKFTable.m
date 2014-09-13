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
    int isize;
    FTableType igen;
    AKConstant *output;
    AKArray *iargs;
}

- (instancetype)initWithType:(FTableType)fTableType
                        size:(int)tableSize
                  parameters:(AKArray *)parameters;
{
    self = [super init];
    if (self) {
        output = [AKConstant globalParameterWithString:[self functionName]];
        isize = tableSize;
        igen = fTableType;
        iargs = parameters;
        _isNormalized = NO;
    }
    return self;
}

- (instancetype)initWithType:(FTableType)fTableType
                  parameters:(AKArray *)parameters;
{
    return [self initWithType:fTableType size:0 parameters:parameters];
}

- (NSString *)functionName {
    NSString *functionName = [NSString stringWithFormat:@"%@", [self class]];
    functionName = [functionName stringByReplacingOccurrencesOfString:@"AK" withString:@""];
    return functionName;
}


// Csound Prototype: ifno ftgentmp ip1, ip2dummy, isize, igen, iarga, iargb, ...
- (NSString *)stringForCSD {
    if (_isNormalized) {
        igen = abs(igen);
    } else {
        igen = -abs(igen);
    }
    NSString *text;
    if (iargs == nil) {
        text = [NSString stringWithFormat:@"%@ ftgen 0, 0, %i, %i",
                output, isize, igen];
    } else {
        text = [NSString stringWithFormat:@"%@ ftgen 0, 0, %i, %i, %@",
                output, isize, igen, [iargs parameterString]];
    }
    return text;
}

- (NSString *)fTableStringForCSD {
    if (_isNormalized) {
        igen = abs(igen);
    } else {
        igen = -abs(igen);
    }
    NSString *text;
    if (iargs == nil) {
        text = [NSString stringWithFormat:@"%@ ftgen 0, 0, %i, %i",
                output, isize, igen];
    } else {
        text = [NSString stringWithFormat:@"%@ ftgen 0, 0, %i, %i, %@",
                output, isize, igen, [iargs parameterString]];
    }
    return text;
}

- (NSString *)description {
    return [output parameterString];
}

- (AKConstant *)length;
{
    AKConstant *new = [[AKConstant alloc] init];
    [new setParameterString:[NSString stringWithFormat:@"ftlen(%@)", output]];
    return new;
}

@end
