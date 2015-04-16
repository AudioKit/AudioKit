//
//  AKFourierSeriesTableGenerator.m
//  AudioKit
//
//  Created by Aurelius Prochazka on 6/6/12.
//  Copyright (c) 2012 Aurelius Prochazka. All rights reserved.
//

#import "AKFourierSeriesTableGenerator.h"

@implementation AKFourierSeriesTableGenerator {
    NSMutableArray *sinusoids;
}

- (int)generationRoutineNumber {
    return -19;
}

- (instancetype)init;
{
    self = [super init];
    if (self) {
        sinusoids = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void)addSinusoidWithPartialNumber:(float)partialNumber
                            strength:(float)strength
{
    [self addSinusoidWithPartialNumber:partialNumber strength:strength phase:0 dcOffset:0];
}


- (void)addSinusoidWithPartialNumber:(int)partialNumber
                            strength:(float)strength
                               phase:(float)phase
                            dcOffset:(float)dcOffset
{
    [sinusoids addObject:@[[NSNumber numberWithFloat:partialNumber],
                           [NSNumber numberWithFloat:strength],
                           [NSNumber numberWithFloat:phase],
                           [NSNumber numberWithFloat:dcOffset]]];
    
}

- (NSArray *)parametersWithSize:(NSUInteger)size
{
    if (sinusoids.count == 0) {
        [self addSinusoidWithPartialNumber:1 strength:1];
    }
    NSMutableArray *flattenedSinusoids = [[NSMutableArray alloc] init];
    for (NSArray *sinusoid in sinusoids) {
        [flattenedSinusoids addObject:[sinusoid componentsJoinedByString:@", "]];
    }
    return [flattenedSinusoids copy];
}

@end
