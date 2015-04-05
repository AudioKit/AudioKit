//
//  AKExponentialTableGenerator.m
//  AudioKit
//
//  Created by Aurelius Prochazka on 3/2/15.
//  Copyright (c) 2015 Aurelius Prochazka. All rights reserved.
//

#import "AKExponentialTableGenerator.h"

@implementation AKExponentialTableGenerator {
    NSMutableArray *points;
}

- (int)generationRoutineNumber {
    return -25;
}

- (instancetype)initWithValue:(float)value
{
    self = [super init];
    if (self) {
        points = [[NSMutableArray alloc] init];
        [points addObject:@[@0, [NSNumber numberWithFloat:value]]];
    }
    return self;
}

- (void)addValue:(float)value atIndex:(int)index
{
    [points addObject:@[[NSNumber numberWithInt:index],
                        [NSNumber numberWithFloat:value]]];
}

- (void)appendValue:(float)value afterNumberOfElements:(int)numberOfElements
{
    NSArray *lastPoint = [points lastObject];
    int lastIndex = [[lastPoint objectAtIndex:0] intValue];
    int index = lastIndex + numberOfElements;
    [self addValue:value atIndex:index];
}

- (NSArray *)parametersWithSize:(int)size
{
    [points sortUsingComparator:^NSComparisonResult(NSArray *obj1, NSArray *obj2) {
        return [obj1[0] compare: obj2[0]];
    }];
    
    int maximumIndex = (int)[[points lastObject] objectAtIndex:0];
    float scalingFactor = (float)size/(float)maximumIndex;
    
    NSMutableArray *scaledPoints = [[NSMutableArray alloc] init];
    for (NSArray *point in points) {
        int index = (int)[point objectAtIndex:0];
        int newIndex = (int) ((float)index * scalingFactor);
        [scaledPoints addObject:@[[NSNumber numberWithInt:newIndex],
                                  [point objectAtIndex:1]]];
    }
    
    NSMutableArray *flattenedPoints = [[NSMutableArray alloc] init];
    for (NSArray *point in scaledPoints) {
        [flattenedPoints addObject:[point componentsJoinedByString:@", "]];
    }
    return [flattenedPoints copy];
}

@end
