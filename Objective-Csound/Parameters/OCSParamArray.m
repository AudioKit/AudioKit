//
//  OCSParamArray.m
//
//  Created by Aurelius Prochazka on 6/6/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//

#import "OCSParamArray.h"

@implementation OCSParamArray
@synthesize parameterString;
@synthesize count;

-(id)init 
{
    self = [super init];
    if (self) {
        params = [[NSMutableArray alloc] init];
    }
    return self;
    
}

+ (id)paramArrayFromFloats:(float *)numbers count:(NSUInteger)count {
    OCSParamArray *result = [NSAllocateObject([self class], count * sizeof(float), NULL) init];
    if (result) {
        result->count = count;
        memcpy(result->numbers, numbers, count * sizeof(float));
    }
    [result setParameterString:[NSString stringWithFormat:@"%0.6f", numbers[0]]];
    for (int i=1; i<count; i++) {
        [result setParameterString:[NSString stringWithFormat:@"%@, %0.6f", [result parameterString], numbers[i]]];
    }
    return result;
}

+(id)paramArrayFromParams:(OCSParamConstant *)firstParam,... {
    OCSParamArray * result = [[OCSParamArray alloc] init];

    OCSParam * eachParam;
    NSMutableArray * initParameters = [[NSMutableArray alloc] init];
    va_list argumentList;
    if (firstParam) { // The first argument isn't part of the varargs list, so we'll handle it separately.
        [initParameters addObject: firstParam];
        va_start(argumentList, firstParam); // Start scanning for arguments after firstObject.
        while ((eachParam = va_arg(argumentList, id))) // As many times as we can get an argument of type "id"
            [initParameters addObject: eachParam]; // that isn't nil, add it to self's contents.
        va_end(argumentList);
    }
    [result setParameterString:[[initParameters valueForKey:@"parameterString"] componentsJoinedByString:@", "]];
    
    return result;
}



@end
