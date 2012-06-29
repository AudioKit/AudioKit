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
    OCSParamArray * params = [OCSParamArray paramArrayFromParams: ocspi(1), nil]; 
    return [self initWithType:kFTSines size:4096 parameters:params];
}

- (id)initWithSize:(int)size partialStrengths:(OCSParamArray *)partialStrengthsArray
{
    return [self initWithType:kFTSines 
                         size:size 
                   parameters:partialStrengthsArray];
}

@end
