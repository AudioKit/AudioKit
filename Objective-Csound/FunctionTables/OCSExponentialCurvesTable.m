//
//  OCSExponentialCurvesTable.m
//  Objective-C Sound
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
    return [self initWithSize:tableSize valueLengthPairs:[values pairWith:lengths]];
}

#pragma mark Exponential Curves From Breakpoints

- (id)initWithSize:(int)tableSize 
       breakpoints:(OCSParameterArray *)breakpoints;
{
    return [self initWithType:kFTExponentialCurvesFromBreakpoints
                         size:tableSize 
                   parameters:breakpoints];
}

- (id)initWithSize:(int)tableSize 
 breakpointXValues:(OCSParameterArray *)xValues
 breakpointYValues:(OCSParameterArray *)yValues;
{
    return [self initWithSize:tableSize breakpoints:[xValues pairWith:yValues]];
}


@end
