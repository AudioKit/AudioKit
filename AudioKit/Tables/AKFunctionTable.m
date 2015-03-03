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
    int igen;
    AKConstant *output;
    int _myFunctionNumber;
}

static int currentID = 1000;
+ (void)resetID { currentID = 1000; }

- (int)number {
    return _myFunctionNumber;
}
- (instancetype)initWithType:(int)functionTableType
                        size:(int)tableSize
                  parameters:(NSArray *)parameters
{
    self = [super init];
    if (self) {
         _myFunctionNumber = currentID++;
        output = [AKConstant globalParameterWithString:[self functionName]];
        _size = tableSize;
        igen = functionTableType;
        _parameters = parameters;
        _isNormalized = NO;
    }
    return self;
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
        text = [NSString stringWithFormat:@"%@ ftgen %d, 0, %i, %@",
                output, [self number], _size, akpi(igen)];
    } else {
        text = [NSString stringWithFormat:@"%@ ftgen %d, 0, %i, %@, %@",
                output, [self number], _size, akpi(igen), [_parameters componentsJoinedByString:@", "]];
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
