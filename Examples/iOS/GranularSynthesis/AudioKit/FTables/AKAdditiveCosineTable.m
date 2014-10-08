//
//  AKAdditiveCosineTable.m
//  AudioKit
//
//  Created by Adam Boulanger on 10/9/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//

#import "AKAdditiveCosineTable.h"

@implementation AKAdditiveCosineTable

- (instancetype)init
{
    return [self initWithSize:8192 numberOfHarmonics:1];
}

- (instancetype)initWithSize:(int)tableSize
           numberOfHarmonics:(int)numberOfHarmonics
{
    return [self initWithType:kFTAdditiveCosines
                         size:tableSize
                   parameters:[AKArray arrayFromConstants:akpi(numberOfHarmonics), nil]];
}

- (instancetype)initWithSize:(int)tableSize
           numberOfHarmonics:(int)numberOfHarmonics
              lowestHarmonic:(int)lowestHarmonic
{
    return [self initWithType:kFTAdditiveCosines
                         size:tableSize
                   parameters:[AKArray arrayFromConstants:
                               akpi(numberOfHarmonics),
                               akpi(lowestHarmonic), nil]];
}

- (instancetype)initWithSize:(int)tableSize
           numberOfHarmonics:(int)numberOfHarmonics
              lowestHarmonic:(int)lowestHarmonic
           partialMultiplier:(int)partialMultiplier
{
    return [self initWithType:kFTAdditiveCosines
                         size:tableSize
                   parameters:[AKArray arrayFromConstants:
                               akp(numberOfHarmonics),
                               akp(lowestHarmonic),
                               akp(partialMultiplier), nil]];
}

@end
