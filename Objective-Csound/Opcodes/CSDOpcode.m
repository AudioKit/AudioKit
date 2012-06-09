//
//  CSDOpcode.m
//
//  Created by Aurelius Prochazka on 4/11/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//

#import "CSDOpcode.h"

@implementation CSDOpcode

@synthesize opcode;

-(NSString *) uniqueName {
    return [NSString stringWithFormat:@"%@%p", [self class], self];
}

-(NSString *) convertToCsd
{
    //Override in subclass
    return @"Undefined";
}

@end
