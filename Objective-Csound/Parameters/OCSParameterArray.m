//
//  OCSParameterArray.m
//  Objective-C Sound
//
//  Created by Aurelius Prochazka on 6/6/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//

#import "OCSParameterArray.h"

@interface OCSParameterArray () {
    NSMutableArray *params;
    //NSString *parameterString;
    NSUInteger count;
    float      numbers[0];
}
@end

@implementation OCSParameterArray
@synthesize params;
//@synthesize parameterString;

- (id)init 
{
    self = [super init];
    if (self) {
        params = [[NSMutableArray alloc] init];
    }
    return self;
}

- (int)count 
{
    return (int) [params count];
}


- (OCSParameterArray *)pairWith:(OCSParameterArray *)pairingArray 
{
    NSAssert([self count] != [pairingArray count], @"Array must be equal in size");
        
    NSMutableArray *temp = [[NSMutableArray alloc] init];
    for (int i=0; i<[[self params] count]; i++) {
        [temp addObject:[[self params]  objectAtIndex:i]];
        [temp addObject:[[pairingArray params] objectAtIndex:i]];
    }
    OCSParameterArray *pairedArray = [[OCSParameterArray alloc] init];
    [pairedArray setParams:temp];
    return pairedArray;
}

- (id)parameterString {
    NSMutableArray *s = [[NSMutableArray alloc] init];
    for (OCSConstant *value in params) {
        [s addObject:[value parameterString]];
    }
    return [s componentsJoinedByString:@", "]; 
}

- (id)fTableString {
    NSMutableArray *s = [[NSMutableArray alloc] init];
    for (OCSConstant *value in params) {
        [s addObject:[value parameterString]];
    }
    return [s componentsJoinedByString:@" "]; 
}


+ (id)paramArrayFromParams:(OCSConstant *)firstParam,... {
    OCSParameterArray *result = [[OCSParameterArray alloc] init];
    
    OCSParameter *eachParam;
    NSMutableArray *initParameters = [[NSMutableArray alloc] init];
    va_list argumentList;
    if (firstParam) { // The first argument isn't part of the varargs list, so we'll handle it separately.
        [initParameters addObject: firstParam];
        va_start(argumentList, firstParam); // Start scanning for arguments after firstObject.
        while ((eachParam = va_arg(argumentList, id))) // As many times as we can get an argument of type "id"
            [initParameters addObject: eachParam]; // that isn't nil, add it to self's contents.
        va_end(argumentList);
    }
    
    [result setParams:initParameters];
    
    return result;
}

@end
