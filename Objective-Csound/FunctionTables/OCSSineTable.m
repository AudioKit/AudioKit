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
    return [self initWithType:kFTSines size:4096 parameters:@"1"];
}

- (id)initWithSize:(int)size PartialStrengths:(OCSParamArray *)partialStrengthsArray
{
    return [self initWithType:kFTSines 
                         size:size 
                   parameters:[partialStrengthsArray parameterString]];
}

@end
