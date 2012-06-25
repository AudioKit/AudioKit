//
//  OCSFileLength.m
//  ExampleProject
//
//  Created by Adam Boulanger on 6/21/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//

#import "OCSFileLength.h"

@interface OCSFileLength () {
    OCSFunctionTable *input;
    OCSParam *output;
}
@end

@implementation OCSFileLength

@synthesize output;  

- (id)initWithFunctionTable:(OCSFunctionTable *)functionTable {
    self = [super init];
    
    if (self) {
        output = [OCSParamConstant paramWithString:[self opcodeName]];
        input = functionTable;
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
