//
//  AKExponentialCurvesVariableGrowth.m
//  EasyExponentialCurves
//
//  Created by Adam Boulanger on 1/20/15.
//  Copyright (c) 2015 Adam Boulanger. All rights reserved.
//

#import "AKExponentialCurvesVariableGrowth.h"

@interface AKExponentialCurvesVariableGrowth ()
{
    NSMutableArray *points;
    NSNumber *initialValue;
}
@end

@implementation AKExponentialCurvesVariableGrowth

-(instancetype)initWithValue:(float)value
{
    self = [super initWithType:AKFunctionTableTypeExponentialCurvesVariableGrowth];
    if(self) {
        points = [[NSMutableArray alloc] init];
        initialValue = [NSNumber numberWithFloat:value];
        self.size = 4096;
    }
    return self;
}

- (void)addValue:(float)value atIndex:(int)index concavity:(int)concavity
{
    [points addObject:@[[NSNumber numberWithInt:index],
                        [NSNumber numberWithInt:concavity],
                        [NSNumber numberWithFloat:value]]];
}

//Csound Prototype: ifno ftgen ip1, ip2dummy, isize, igen, iarga, iargb, ...
- (NSString *)stringForCSD
{
    
    int maximumIndex = 0;
    for (NSArray *point in points) {
        int index = (int)[point objectAtIndex:0];
        maximumIndex = maximumIndex + index;
    }
    
    float scalingFactor = (float)self.size/(float)maximumIndex;
    
    NSMutableArray *scaledPoints = [[NSMutableArray alloc] init];
    for (NSArray *point in points) {
        int index = (int)[point objectAtIndex:0];
        int newIndex = (int)((float)index * scalingFactor);
        [scaledPoints addObject:@[[NSNumber numberWithInt:newIndex],
                                  [point objectAtIndex:1],
                                  [point objectAtIndex:2]]];
    }
    
    NSMutableArray *flattenedPoints = [[NSMutableArray alloc] init];
    for (NSArray *point in scaledPoints) {
        [flattenedPoints addObject:[point componentsJoinedByString:@", "]];
    }
    
    return [NSString stringWithFormat:@"%@ ftgen 0, 0, %d, -%lu, %@, %@",
            self,
            self.size,
            (unsigned long)AKFunctionTableTypeExponentialCurvesVariableGrowth,
            initialValue,
            [flattenedPoints componentsJoinedByString:@", "]];
}

@end
