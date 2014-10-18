//
//  AKCompositeWaveformsFromSines.m
//  AudioKit
//
//  Created by Adam Boulanger on 10/11/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//

#import "AKCompositeWaveformsFromSines.h"

@implementation AKCompositeWaveformsFromSines

- (instancetype)initWithTableSize:(int)tableSize
                   partialNumbers:(AKArray *)partialNumbers
                 partialStrengths:(AKArray *)partialStrengths
           partialStrengthOffsets:(AKArray *)partialOffsets
                    partialPhases:(AKArray *)partialPhases
{
    self = [super init];
    
    AKArray *parameters = [[AKArray alloc] init];
    if (self) {
        NSAssert([partialNumbers   count] == [partialStrengths count] &&
                 [partialStrengths count] == [partialOffsets   count] &&
                 [partialOffsets   count] == [partialPhases    count],
                 @"Array must be equal in size");
        
        NSMutableArray *temp = [[NSMutableArray alloc] init];
        for (int i=0; i<[partialNumbers count]; i++){
            [temp addObject:partialNumbers.constants[i]];
            [temp addObject:partialStrengths.constants[i]];
            [temp addObject:partialPhases.constants[i]];
            [temp addObject:partialOffsets.constants[i]];
        }
        [parameters setConstants:temp];
    }
    return [self initWithType:kFTCompositeWaveformsFromSines
                         size:tableSize
                   parameters:parameters];
}


@end
