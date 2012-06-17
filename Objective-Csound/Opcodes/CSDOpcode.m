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

+(void) resetID {
    currentID = 1;
}

-(NSString *) uniqueName {
    NSString * basename = [NSString stringWithFormat:@"%@%i", [self class], _myID];
    basename = [basename stringByReplacingOccurrencesOfString:@"CSD" withString:@""];
    return basename;
}

-(NSString *) convertToCsd
{
    //Override in subclass
    return @"Undefined";
}

@end
