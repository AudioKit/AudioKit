//
//  OCSSineTable.m
//
//  Created by Aurelius Prochazka on 6/6/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//

#import "OCSSineTable.h"

@implementation OCSSineTable

- (id)init;
{
    return [self initWithSize:4096 GenRoutine:kGenSines Parameters:@"1"];
}

- (id)initWithSize:(int)size PartialStrengths:(OCSParamArray *)partialStrengthsArray
{
    return [self initWithSize:size 
                   GenRoutine:kGenSines 
                   Parameters:[partialStrengthsArray parameterString]];
}

@end
