//
//  OCSOpcode.m
//
//  Created by Aurelius Prochazka on 4/11/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//

#import "OCSOpcode.h"

@implementation OCSOpcode

@synthesize opcode;

-(NSString *) uniqueName {
    NSString * basename = [NSString stringWithFormat:@"%@", [self class]];
    basename = [basename stringByReplacingOccurrencesOfString:@"OCS" withString:@""];
    return basename;
}

-(NSString *) convertToCsd
{
    //Override in subclass
    return @"Undefined";
}

@end
