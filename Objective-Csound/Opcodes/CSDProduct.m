//
//  CSDProduct.m
//  ExampleProject
//
//  Created by Aurelius Prochazka on 6/9/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//

#import "CSDProduct.h"

@implementation CSDProduct
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
            @"%@ product %@\n",
            [output parameterString],
            inputsCombined];
}
@end
