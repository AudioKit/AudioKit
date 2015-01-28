//
//  AKWeightedSumOfSinusoids.m
//  AudioKit
//
//  Created by Aurelius Prochazka on 6/6/12.
//  Copyright (c) 2012 Aurelius Prochazka. All rights reserved.
//

#import "AKWeightedSumOfSinusoids.h"

@interface AKWeightedSumOfSinusoids ()
{
    NSMutableArray *sinusoids;
}
@end


@implementation AKWeightedSumOfSinusoids

- (instancetype)init;
{
    self = [super initWithType:AKFunctionTableTypeWeightedSumOfSinusoids];
    if (self) {
        sinusoids = [[NSMutableArray alloc] init];
        self.size = 4096;
    }
    return self;
}

- (instancetype)initStandardSineWave
{
    self = [self init];
    if (self) {
        [self addSinusoidWithPartialNumber:1 strength:1];
    }
    return self;
}


+ (instancetype)pureSineWave
{
    return [[self alloc] initStandardSineWave];
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

// Csound Prototype: ifno ftgen ip1, ip2dummy, isize, igen, iarga, iargb, ...
- (NSString *)stringForCSD
{
    if (sinusoids.count == 0) {
        [self addSinusoidWithPartialNumber:1 strength:1];
    }
    NSMutableArray *flattenedSinusoids = [[NSMutableArray alloc] init];
    for (NSArray *sinusoid in sinusoids) {
        [flattenedSinusoids addObject:[sinusoid componentsJoinedByString:@", "]];
    }
    return [NSString stringWithFormat:@"%@ ftgen 0, 0, %d, -%lu, %@",
            self,
            self.size,
            (unsigned long)AKFunctionTableTypeWeightedSumOfSinusoids,
            [flattenedSinusoids componentsJoinedByString:@", "]];
}

@end
