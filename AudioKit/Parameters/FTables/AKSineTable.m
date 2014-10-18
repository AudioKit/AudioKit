//
//  AKSineTable.m
//  AudioKit
//
//  Created by Aurelius Prochazka on 6/6/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//

#import "AKSineTable.h"

@implementation AKSineTable

- (instancetype)init;
{
    AKArray *params = [AKArray arrayFromConstants: akpi(1), nil];
    return [self initWithType:kFTSines size:4096 parameters:params];
}

- (instancetype)initWithSize:(int)size
            partialStrengths:(AKArray *)partialStrengthsArray
{
    return [self initWithType:kFTSines
                         size:size
                   parameters:partialStrengthsArray];
}

@end
