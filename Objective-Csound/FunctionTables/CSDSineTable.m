//
//  CSDSineTable.m
//
//  Created by Aurelius Prochazka on 6/6/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//

#import "CSDSineTable.h"

@implementation CSDSineTable

//TODO: Should make the partial sizes an array of floats
-(id) initWithSize:(int)tableSize PartialStrengths:(CSDParamArray *)partials
{
    return [self initWithSize:tableSize 
                   GenRoutine:kGenRoutineSines 
                   Parameters:[partials parameterString]];
}

-(id) init;
{
    return [self initWithSize:4096 
                   GenRoutine:kGenRoutineSines 
                   Parameters:@"1"];
}


@end
