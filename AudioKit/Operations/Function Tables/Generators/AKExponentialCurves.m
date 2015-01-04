//
//  AKExponentialCurves.m
//  AudioKit
//
//  Created by Aurelius Prochazka on 12/26/14.
//  Copyright (c) 2014 Aurelius Prochazka. All rights reserved.
//

#import "AKExponentialCurves.h"

@interface AKExponentialCurves ()
{
    NSMutableArray *points;
}
@end

@implementation AKExponentialCurves

- (instancetype)initWithValue:(float)value
{
    self = [super initWithType:AKFunctionTableTypeExponentialCurves];
    if (self) {
        points = [[NSMutableArray alloc] init];
        [points addObject:@[@0, [NSNumber numberWithFloat:value]]];
        self.size = 4096;
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

// Csound Prototype: ifno ftgen ip1, ip2dummy, isize, igen, iarga, iargb, ...
- (NSString *)stringForCSD
{
    int maximumIndex = (int)[[points lastObject] objectAtIndex:0];
    float scalingFactor = (float)self.size/(float)maximumIndex;
    
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
    return [NSString stringWithFormat:@"%@ ftgen 0, 0, %d, -%lu, %@",
            self,
            self.size,
            (unsigned long)AKFunctionTableTypeExponentialCurves,
            [flattenedPoints componentsJoinedByString:@", "]];
}

@end
