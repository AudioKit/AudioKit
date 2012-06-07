//
//  CSDParamArray.m
//  ExampleProject
//
//  Created by Aurelius Prochazka on 6/6/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//

#import "CSDParamArray.h"

@implementation CSDParamArray
@synthesize parameterString;

+ (id)paramFromFloats:(float *)numbers count:(NSUInteger)count {
    CSDParamArray *result = [NSAllocateObject([self class], count * sizeof(float), NULL) init];
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


@end
