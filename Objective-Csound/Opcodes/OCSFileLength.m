//
//  OCSFileLength.m
//  ExampleProject
//
//  Created by Adam Boulanger on 6/21/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//

#import "OCSFileLength.h"

@implementation OCSFileLength

@synthesize output;  

- (id)initWithInput:(OCSFunctionTable *)in {
    self = [super init];
    
    if (self) {
        output = [OCSParamConstant paramWithString:[self opcodeName]];
        input = in;
    }
    return self; 
}

- (NSString *)stringForCSD
{
    return [NSString stringWithFormat:@"%@ = ftlen(%@)\n", output, input];
}

- (NSString *)description {
    return [output parameterString];
}


@end
