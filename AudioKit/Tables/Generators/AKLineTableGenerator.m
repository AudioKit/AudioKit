//
//  AKLineTableGenerator.m
//  AudioKit
//
//  Created by Aurelius Prochazka on 12/26/14.
//  Copyright (c) 2014 Aurelius Prochazka. All rights reserved.
//

#import "AKLineTableGenerator.h"

@implementation AKLineTableGenerator {
    NSMutableArray *points;
}

- (instancetype)initSquareWave {
    self = [self initWithValue:1];
    if (self) {
        [self addValue:1 atIndex:1];
        [self addValue:-1 atIndex:1];
        [self addValue:-1 atIndex:2];
    }
    return self;
}

+ (instancetype)squareWave {
    return [[self alloc] initSquareWave];
}

- (instancetype)initTriangleWave {
    self = [self initWithValue:0];
    if (self) {
        [self addValue:1 atIndex:1];
        [self addValue:-1 atIndex:3];
        [self addValue:0 atIndex:4];
    }
    return self;
}

+ (instancetype)triangleWave {
    return [[self alloc] initTriangleWave];
}

- (instancetype)initSawtoothWave {
    self = [self initWithValue:-1];
    if (self) {
        [self addValue:1 atIndex:1];
    }
    return self;
}

+ (instancetype)sawtoothWave {
    return [[self alloc] initSawtoothWave];
}

- (instancetype)initReverseSawtoothWave {
    self = [self initWithValue:1];
    if (self) {
        [self addValue:-1 atIndex:1];
    }
    return self;
}

+ (instancetype)reverseSawtoothWave {
    return [[self alloc] initReverseSawtoothWave];
}

- (int)generationRoutineNumber {
    return -27;
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
    int lastIndex = [lastPoint[0] intValue];
    int index = lastIndex + numberOfElements;
    [self addValue:value atIndex:index];
}

- (NSArray *)parametersWithSize:(NSUInteger)size
{
    [points sortUsingComparator:^NSComparisonResult(NSArray *obj1, NSArray *obj2) {
        return [obj1[0] compare: obj2[0]];
    }];
    int maximumIndex = [[points lastObject][0] intValue];
    float scalingFactor = (float)size/(float)maximumIndex;
    NSMutableArray *scaledPoints = [[NSMutableArray alloc] init];
    for (NSArray *point in points) {
        int index = [point[0] intValue];
        int newIndex = (int) ((float)index * scalingFactor);
        [scaledPoints addObject:@[@(newIndex), point[1]]];
    }
    
    NSMutableArray *flattenedPoints = [[NSMutableArray alloc] init];
    for (NSArray *point in scaledPoints) {
        [flattenedPoints addObject:[point componentsJoinedByString:@", "]];
    }
    return [flattenedPoints copy];
}

@end
