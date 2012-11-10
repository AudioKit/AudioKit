//
//  OCSAdditiveCosineTable.m
//  Objective-C Sound
//
//  Created by Adam Boulanger on 10/9/12.
//  Copyright (c) 2012 Adam Boulanger. All rights reserved.
//

#import "OCSAdditiveCosineTable.h"

@implementation OCSAdditiveCosineTable

- (id)init
{
    return [self initWithSize:8192 numberOfHarmonics:1];
}

- (id)initWithSize:(int)tableSize
 numberOfHarmonics:(int)numberOfHarmonics
{
    return [self initWithType:kFTAdditiveCosines size:tableSize parameters:[OCSParameterArray paramArrayFromParams:ocspi(numberOfHarmonics), nil]];
}

- (id)initWithSize:(int)tableSize
 numberOfHarmonics:(int)numberOfHarmonics
    lowestHarmonic:(int)lowestHarmonic
{
    return [self initWithType:kFTAdditiveCosines
                         size:tableSize
                   parameters:[OCSParameterArray
                               paramArrayFromParams:ocspi(numberOfHarmonics),
                                                    ocspi(lowestHarmonic), nil]];
}

- (id)initWithSize:(int)tableSize
 numberOfHarmonics:(int)numberOfHarmonics
    lowestHarmonic:(int)lowestHarmonic
 partialMultiplier:(int)partialMultiplier
{
    return [self initWithType:kFTAdditiveCosines
                         size:tableSize
                   parameters:[OCSParameterArray
                               paramArrayFromParams:ocspi(numberOfHarmonics),
                                                    ocspi(lowestHarmonic),
                                                    ocspi(partialMultiplier), nil]];
}

@end
