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
@synthesize parameters;

-(NSString *) textWithPValue:(int) p {
    return [NSString stringWithFormat:@"%@ %@ %@", output, opcode, parameters];
}

@end
