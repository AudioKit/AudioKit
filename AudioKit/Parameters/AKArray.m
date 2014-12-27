//
//  AKArray.m
//  AudioKit
//
//  Created by Aurelius Prochazka on 6/6/12.
//  Copyright (c) 2012 Aurelius Prochazka. All rights reserved.
//

#import "AKArray.h"

@implementation AKArray
{
    NSUInteger count;
    float      numbers[0];
}

- (instancetype)init 
{
    self = [super init];
    if (self) {
        _constants = [[NSMutableArray alloc] init];
    }
    return self;
}

- (int)count {
    return (int) [_constants count];
}


- (AKArray *)pairWith:(AKArray *)pairingArray 
{
    NSAssert([self count] != [pairingArray count], @"Array must be equal in size");
        
    NSMutableArray *temp = [[NSMutableArray alloc] init];
    for (uint i=0; i<[[self constants] count]; i++) {
        [temp addObject:self.constants[i]];
        [temp addObject:pairingArray.constants[i]];
    }
    AKArray *pairedArray = [[AKArray alloc] init];
    [pairedArray setConstants:temp];
    return pairedArray;
}

- (id)parameterString
{
    NSMutableArray *s = [[NSMutableArray alloc] init];
    for (AKConstant *value in _constants) {
        [s addObject:[value parameterString]];
    }
    return [s componentsJoinedByString:@", "]; 
}

- (void)addConstant:(AKConstant *)constant
{
    [_constants addObject:constant];
}


+ (id)arrayFromConstants:(AKConstant *)firstConstant,...
{
    AKArray *result = [[AKArray alloc] init];
    
    AKConstant *eachParam;
    NSMutableArray *initParameters = [[NSMutableArray alloc] init];
    va_list argumentList;
    if (firstConstant) { // The first argument isn't part of the varargs list, so we'll handle it separately.
        [initParameters addObject: firstConstant];
        va_start(argumentList, firstConstant); // Start scanning for arguments after firstObject.
        while ((eachParam = va_arg(argumentList, id))) // As many times as we can get an argument of type "id"
            [initParameters addObject: eachParam]; // that isn't nil, add it to self's contents.
        va_end(argumentList);
    }
    
    [result setConstants:initParameters];
    
    return result;
}

+ (id)arrayFromNumbers:(NSNumber *)firstValue,...
{
    AKArray *result = [[AKArray alloc] init];
    
    NSNumber *eachValue;
    NSMutableArray *initParameters = [[NSMutableArray alloc] init];
    va_list argumentList;
    if (firstValue) { // The first argument isn't part of the varargs list, so we'll handle it separately.
        [initParameters addObject:[AKConstant constantWithNumber:firstValue]];
        va_start(argumentList, firstValue); // Start scanning for arguments after firstObject.
        while ((eachValue = va_arg(argumentList, id))) // As many times as we can get an argument of type "id"
            [initParameters addObject:[AKConstant constantWithNumber:eachValue]]; // that isn't nil, add it to self's contents.
        va_end(argumentList);
    }
    
    [result setConstants:initParameters];
    
    return result;
}

@end
