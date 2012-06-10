//
//  CSDSum.m
//  ExampleProject
//
//  Created by Aurelius Prochazka on 6/9/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//

#import "CSDSum.h"

@implementation CSDSum
@synthesize output;

-(id) initWithInputs:(CSDParam *)firstInput,... {
    self = [super init];
    
    if (self) {
        output = [CSDParam paramWithString:[self uniqueName]];
    }
    return self; 
}

-(NSString *)convertToCsd
{
    NSString * inputsCombined = @"";
    
    return [NSString stringWithFormat:
            @"%@ sum %@\n",
            [output parameterString],
            inputsCombined];
}

@end
