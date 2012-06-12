//
//  CSDAssignment.m
//
//  Created by Aurelius Prochazka on 6/12/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//

#import "CSDAssignment.h"

@implementation CSDAssignment
@synthesize output;  

-(id) initWithInput:(CSDParam *)in {
    self = [super init];
    
    if (self) {
        output = [CSDParam paramWithString:[self uniqueName]];
        input = in;
    }
    return self; 
}

-(NSString *)convertToCsd
{
    return [NSString stringWithFormat:@"%@ = %@\n", output, input];
}

-(NSString *) description {
    return [output parameterString];
}

@end
