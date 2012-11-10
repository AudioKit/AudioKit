//
//  OCSCompositeWaveformsFromSines.m
//  Objective-C Sound
//
//  Created by Adam Boulanger on 10/11/12.
//  Copyright (c) 2012 Adam Boulanger. All rights reserved.
//

#import "OCSCompositeWaveformsFromSines.h"

@implementation OCSCompositeWaveformsFromSines

-(id)initWithTableSize:(int)tableSize
        partialNumbers:(OCSParameterArray *)partialNumbers
      partialStrengths:(OCSParameterArray *)partialStrengths
partialStrengthOffsets:(OCSParameterArray *)partialOffsets
         partialPhases:(OCSParameterArray *)partialPhases
{
    self = [super init];
    
    OCSParameterArray *parameters = [[OCSParameterArray alloc] init];
    if (self) {
        NSAssert([partialNumbers count] == [partialStrengths count] &&
                 [partialStrengths count] == [partialOffsets count] &&
                 [partialOffsets count] == [partialPhases count], @"Array must be equal in size");

        NSMutableArray *temp = [[NSMutableArray alloc] init];
        for (int i=0; i<[partialNumbers count]; i++){
            [temp addObject:[[partialNumbers params] objectAtIndex:i]];
            [temp addObject:[[partialStrengths params] objectAtIndex:i]];
            [temp addObject:[[partialPhases params] objectAtIndex:i]];
            [temp addObject:[[partialOffsets params] objectAtIndex:i]];
        }
        [parameters setParams:temp];
    }
    return [self initWithType:kFTCompositeWaveformsFromSines
                         size:tableSize
                   parameters:parameters];
}


@end
