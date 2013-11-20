//
//  OCSArray.m
//  Objective-C Sound
//
//  Created by Aurelius Prochazka on 6/6/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//

#import "OCSArray.h"

@interface OCSArray () {
    NSUInteger count;
    float      numbers[0];
}
@end

@implementation OCSArray

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


- (OCSArray *)pairWith:(OCSArray *)pairingArray 
{
    NSAssert([self count] != [pairingArray count], @"Array must be equal in size");
        
    NSMutableArray *temp = [[NSMutableArray alloc] init];
    for (uint i=0; i<[[self constants] count]; i++) {
        [temp addObject:self.constants[i]];
        [temp addObject:pairingArray.constants[i]];
    }
    OCSArray *pairedArray = [[OCSArray alloc] init];
    [pairedArray setConstants:temp];
    return pairedArray;
}

- (id)parameterString {
    NSMutableArray *s = [[NSMutableArray alloc] init];
    for (OCSConstant *value in _constants) {
        [s addObject:[value parameterString]];
    }
    return [s componentsJoinedByString:@", "]; 
}

- (id)fTableString {
    NSMutableArray *s = [[NSMutableArray alloc] init];
    for (OCSConstant *value in _constants) {
        [s addObject:[value parameterString]];
    }
    return [s componentsJoinedByString:@" "]; 
}

- (void)addConstant:(OCSConstant *)constant
{
    [_constants addObject:constant];
}


+ (id)arrayFromConstants:(OCSConstant *)firstConstant,... {
    OCSArray *result = [[OCSArray alloc] init];
    
    // AOP Shouldn't this be OCSConstant?
    OCSParameter *eachParam;
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

+ (id)arrayFromNumbers:(NSNumber *)firstValue,... {
    OCSArray *result = [[OCSArray alloc] init];
    
    NSNumber *eachValue;
    NSMutableArray *initParameters = [[NSMutableArray alloc] init];
    va_list argumentList;
    if (firstValue) { // The first argument isn't part of the varargs list, so we'll handle it separately.
        [initParameters addObject:[OCSConstant constantWithNumber:firstValue]];
        va_start(argumentList, firstValue); // Start scanning for arguments after firstObject.
        while ((eachValue = va_arg(argumentList, id))) // As many times as we can get an argument of type "id"
            [initParameters addObject:[OCSConstant constantWithNumber:eachValue]]; // that isn't nil, add it to self's contents.
        va_end(argumentList);
    }
    
    [result setConstants:initParameters];
    
    return result;
}

@end
