//
//  OCSAssignment.m
//
//  Created by Aurelius Prochazka on 6/12/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//

#import "OCSAssignment.h"

@implementation OCSAssignment
@synthesize output;  

-(id) initWithInput:(OCSParam *)in {
    self = [super init];
    
    if (self) {
        output = [OCSParam paramWithString:[self uniqueName]];
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
