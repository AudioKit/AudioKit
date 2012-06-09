//
//  CSDOpcode.m
//  CsdReinvention
//
//  Created by Aurelius Prochazka on 4/11/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//

#import "CSDOpcode.h"

@implementation CSDOpcode

@synthesize output;
@synthesize opcode;

-(id) initWithType:(NSString *)t {
    
    self = [super init];
    if (self) {
        //Default output is unique, can override if you want pretty CSD output
        type = t;
        output = [CSDParam 
                  paramWithString:[NSString stringWithFormat:@"%@%@%p", 
                                   type, [self class], self]];
    }
    return self; 
}

-(NSString *) convertToCsd
{
    //Override in subclass
    return @"Undefined";
}

@end
