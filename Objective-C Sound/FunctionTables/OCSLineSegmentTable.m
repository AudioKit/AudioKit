//
//  OCSLineSegmentTable.m
//  Objective-C Sound
//
//  Created by Adam Boulanger on 10/9/12.
//  Copyright (c) 2012 Adam Boulanger. All rights reserved.
//

#import "OCSLineSegmentTable.h"

@implementation OCSLineSegmentTable

#pragma mark Straight lines Values and Lengths

- (id)initWithSize:(int)tableSize
  valueLengthPairs:(OCSArray *)valueLengthPairs
{
    return [self initWithType:kFTStraightLines
                         size:tableSize
                   parameters:valueLengthPairs];
}

- (id)initWithSize:(int)tableSize
            values:(OCSArray *)values
           lengths:(OCSArray *)lengths;
{
    return [self initWithSize:tableSize valueLengthPairs:[values pairWith:lengths]];
}

#pragma mark Straight lines From Breakpoints

- (id)initWithSize:(int)tableSize
       breakpoints:(OCSArray *)breakpoints;
{
    return [self initWithType:kFTStraightLinesFromBreakpoints
                         size:tableSize
                   parameters:breakpoints];
}

- (id)initWithSize:(int)tableSize
 breakpointXValues:(OCSArray *)xValues
 breakpointYValues:(OCSArray *)yValues;
{
    return [self initWithSize:tableSize breakpoints:[xValues pairWith:yValues]];
}

@end
