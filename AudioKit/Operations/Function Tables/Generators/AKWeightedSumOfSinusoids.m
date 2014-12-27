//
//  AKWeightedSumOfSinusoids.m
//  AudioKit
//
//  Created by Aurelius Prochazka on 6/6/12.
//  Copyright (c) 2012 Aurelius Prochazka. All rights reserved.
//

#import "AKWeightedSumOfSinusoids.h"

@implementation AKWeightedSumOfSinusoids

- (instancetype)init;
{
    AKArray *params = [AKArray arrayFromConstants: akpi(1), nil];
    return [self initWithType:AKFunctionTableTypeWeightedSumOfSinusoids
                         size:4096
                   parameters:params];
}

+ (instancetype)pureSineWave
{
    return [[self alloc] init];
}

- (instancetype)initWithSize:(int)size
            partialStrengths:(AKArray *)partialStrengthsArray
{
    return [self initWithType:AKFunctionTableTypeWeightedSumOfSinusoids
                         size:size
                   parameters:partialStrengthsArray];
}

@end
