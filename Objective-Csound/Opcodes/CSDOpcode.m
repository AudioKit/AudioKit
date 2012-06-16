//
//  CSDOpcode.m
//
//  Created by Aurelius Prochazka on 4/11/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//

#import "CSDOpcode.h"

@implementation CSDOpcode

@synthesize opcode;

static int currentID = 1;

-(id) init {
    self = [super init];
    if (self) {
        _myID = currentID++;
    }
    return self; 
}


-(NSString *) uniqueName {
    return [NSString stringWithFormat:@"%@%i", [self class], _myID];
}

-(NSString *) convertToCsd
{
    //Override in subclass
    return @"Undefined";
}



@end
