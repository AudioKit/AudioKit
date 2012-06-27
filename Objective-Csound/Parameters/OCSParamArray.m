//
//  OCSParamArray.m
//
//  Created by Aurelius Prochazka on 6/6/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//

#import "OCSParamArray.h"

@interface OCSParamArray () {
    NSMutableArray *params;
    NSString *parameterString;
    NSUInteger count;
    float      numbers[0];
}
@end

@implementation OCSParamArray
@synthesize parameterString;

- (id)init 
{
    self = [super init];
    if (self) {
        params = [[NSMutableArray alloc] init];
    }
    return self;
    
}

+(id)paramArrayFromParams:(OCSParamConstant *)firstParam,... {
    OCSParamArray *result = [[OCSParamArray alloc] init];

    OCSParam *eachParam;
    NSMutableArray *initParameters = [[NSMutableArray alloc] init];
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
