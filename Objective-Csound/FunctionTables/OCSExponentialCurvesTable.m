//
//  OCSExponentialCurvesTable.m
//  ExampleProject
//
//  Created by Adam Boulanger on 6/21/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//

#import "OCSExponentialCurvesTable.h"

@implementation OCSExponentialCurvesTable


#pragma mark Exponential Curves Values and Lengths

- (id)initWithSize:(int)tableSize 
  valueLengthPairs:(OCSParameterArray *)valueLengthPairs
{
    return [self initWithType:kFTExponentialCurves 
                         size:tableSize 
                   parameters:valueLengthPairs];
}

- (id)initWithSize:(int)tableSize 
            values:(OCSParameterArray *)values
           lengths:(OCSParameterArray *)lengths;
{
    NSMutableArray *temp = [[NSMutableArray alloc] init];
    for (int i=0; i<[[values params] count]; i++) {
        [temp addObject:[[values params]  objectAtIndex:i]];
        [temp addObject:[[lengths params] objectAtIndex:i]];
    }
    
    OCSParameterArray *valueLengthPairs;
    [valueLengthPairs setParams:temp];
    return [self initWithSize:tableSize valueLengthPairs:valueLengthPairs];
}

#pragma mark Exponential Curves From Breakpoints

- (id)initWithSize:(int)tableSize 
           xyPairs:(OCSParameterArray *)xyPairs;
{
    return [self initWithType:kFTExponentialCurvesFromBreakpoints
                         size:tableSize 
                   parameters:xyPairs];
}

- (id)initWithSize:(int)tableSize 
           xValues:(OCSParameterArray *)xValues
           yValues:(OCSParameterArray *)yValues;
{
    
    NSMutableArray *temp = [[NSMutableArray alloc] init];
    for (int i=0; i<[[xValues params] count]; i++) {
        [temp addObject:[[xValues params]  objectAtIndex:i]];
        [temp addObject:[[yValues params] objectAtIndex:i]];
    }
    
    OCSParameterArray *xyPairs;
    [xyPairs setParams:temp];
    return [self initWithSize:tableSize xyPairs:xyPairs];
}


@end
