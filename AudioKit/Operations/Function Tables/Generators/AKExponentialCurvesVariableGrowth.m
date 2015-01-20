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
}
@end

@implementation AKExponentialCurvesVariableGrowth

-(instancetype)initWithValue:(float)value
{
    self = [super initWithType:AKFunctionTableTypeExponentialCurvesVariableGrowth];
    if(self) {
        points = [[NSMutableArray alloc] init];
        [points addObject:@[@0, [NSNumber numberWithFloat:value]]];
        self.size = 4096;
    }
    return self;
}

- (void)addValue:(float)value atIndex:(int)index growthFactor:(int)growthFactor
{
    [points addObject:@[[NSNumber numberWithInt:index],
                        [NSNumber numberWithInt:growthFactor],
                        [NSNumber numberWithFloat:value]]];
}

-(void)appendValue:(float)value
    afterNumberOfElements:(int)numberOfElements
             growthFactor:(int)growthFactor
{
    NSArray *lastPoint = [points lastObject];
    int lastIndex = [[lastPoint objectAtIndex:0] intValue];
    int index = lastIndex + numberOfElements;
    [self addValue:value atIndex:index growthFactor:growthFactor];
}

//Csound Prototype: ifno ftgen ip1, ip2dummy, isize, igen, iarga, iargb, ...
- (NSString *)stringForCSD
{
    int maximumIndex = (int)[[points lastObject] objectAtIndex:0];
    float scalingFactor = (float)self.size/(float)maximumIndex;
    
    NSMutableArray *scaledPoints = [[NSMutableArray alloc] init];
    for (NSArray *point in points) {
        int index = (int)[point objectAtIndex:0];
        int newIndex = (int)((float)index * scalingFactor);
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
            (unsigned long)AKFunctionTableTypeExponentialCurvesVariableGrowth,
            [flattenedPoints componentsJoinedByString:@", "]];
}

@end
