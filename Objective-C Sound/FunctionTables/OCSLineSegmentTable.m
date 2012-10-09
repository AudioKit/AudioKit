//
//  OCSLineSegmentTable.m
//  Sonification
//
//  Created by Adam Boulanger on 10/9/12.
//  Copyright (c) 2012 Adam Boulanger. All rights reserved.
//

#import "OCSLineSegmentTable.h"

@implementation OCSLineSegmentTable

#pragma mark Straight lines Values and Lengths

- (id)initWithSize:(int)tableSize
  valueLengthPairs:(OCSParameterArray *)valueLengthPairs
{
    return [self initWithType:kFTStraightLines
                         size:tableSize
                   parameters:valueLengthPairs];
}

- (id)initWithSize:(int)tableSize
            values:(OCSParameterArray *)values
           lengths:(OCSParameterArray *)lengths;
{
    return [self initWithSize:tableSize valueLengthPairs:[values pairWith:lengths]];
}

#pragma mark Straight lines From Breakpoints

- (id)initWithSize:(int)tableSize
       breakpoints:(OCSParameterArray *)breakpoints;
{
    return [self initWithType:kFTStraightLinesFromBreakpoints
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
