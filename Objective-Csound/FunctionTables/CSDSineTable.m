//
//  CSDSineTable.m
//  ExampleProject
//
//  Created by Aurelius Prochazka on 6/6/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//

#import "CSDSineTable.h"

@implementation CSDSineTable

//TODO: Should make the partial sizes an array of floats
-(id) initWithOutput:(NSString *)output TableSize:(int) tableSize PartialStrengths:(NSString *)parameters
{
    return [self initWithOutput:output TableSize:tableSize GenRouting:kGenRoutineSines AndParameters:parameters];
}


@end
