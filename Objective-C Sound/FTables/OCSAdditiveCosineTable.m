//
//  OCSAdditiveCosineTable.m
//  Objective-C Sound
//
//  Created by Adam Boulanger on 10/9/12.
//  Copyright (c) 2012 Adam Boulanger. All rights reserved.
//

#import "OCSAdditiveCosineTable.h"

@implementation OCSAdditiveCosineTable

- (instancetype)init
{
    return [self initWithSize:8192 numberOfHarmonics:1];
}

- (instancetype)initWithSize:(int)tableSize
 numberOfHarmonics:(int)numberOfHarmonics
{
    return [self initWithType:kFTAdditiveCosines size:tableSize parameters:[OCSArray arrayFromConstants:ocspi(numberOfHarmonics), nil]];
}

- (instancetype)initWithSize:(int)tableSize
 numberOfHarmonics:(int)numberOfHarmonics
    lowestHarmonic:(int)lowestHarmonic
{
    return [self initWithType:kFTAdditiveCosines
                         size:tableSize
                   parameters:[OCSArray
                               arrayFromConstants:ocspi(numberOfHarmonics),
                                                    ocspi(lowestHarmonic), nil]];
}

- (instancetype)initWithSize:(int)tableSize
 numberOfHarmonics:(int)numberOfHarmonics
    lowestHarmonic:(int)lowestHarmonic
 partialMultiplier:(int)partialMultiplier
{
    return [self initWithType:kFTAdditiveCosines
                         size:tableSize
                   parameters:[OCSArray arrayFromConstants:
                               ocsp(numberOfHarmonics),
                               ocsp(lowestHarmonic),
                               ocsp(partialMultiplier), nil]];
}

@end
