//
//  AKLineSegmentTable.m
//  AudioKit
//
//  Created by Adam Boulanger on 10/9/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//

#import "AKLineSegmentTable.h"

@implementation AKLineSegmentTable

#pragma mark - Straight lines Values and Lengths

- (instancetype)initWithSize:(int)tableSize
            valueLengthPairs:(AKArray *)valueLengthPairs
{
    return [self initWithType:kFTStraightLines
                         size:tableSize
                   parameters:valueLengthPairs];
}

- (instancetype)initWithSize:(int)tableSize
                      values:(AKArray *)values
                     lengths:(AKArray *)lengths;
{
    return [self initWithSize:tableSize valueLengthPairs:[values pairWith:lengths]];
}

#pragma mark - Straight lines From Breakpoints

- (instancetype)initWithSize:(int)tableSize
                 breakpoints:(AKArray *)breakpoints;
{
    return [self initWithType:kFTStraightLinesFromBreakpoints
                         size:tableSize
                   parameters:breakpoints];
}

- (instancetype)initWithSize:(int)tableSize
           breakpointXValues:(AKArray *)xValues
           breakpointYValues:(AKArray *)yValues;
{
    return [self initWithSize:tableSize breakpoints:[xValues pairWith:yValues]];
}

@end
