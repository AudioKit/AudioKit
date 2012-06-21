//
//  CSDFileLength.m
//  ExampleProject
//
//  Created by Adam Boulanger on 6/21/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//

#import "CSDFileLength.h"

@implementation CSDFileLength

@synthesize output;  

-(id) initWithInput:(CSDFunctionTable *)in {
    self = [super init];
    
    if (self) {
        output = [CSDParam paramWithString:[self uniqueName]];
        input = in;
    }
    return self; 
}

-(NSString *)convertToCsd
{
    return [NSString stringWithFormat:@"%@ = ftlen(%@)\n", output, input];
}

-(NSString *) description {
    return [output parameterString];
}

@end
