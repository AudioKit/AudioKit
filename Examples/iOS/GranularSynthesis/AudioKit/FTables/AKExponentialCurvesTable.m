//
//  AKExponentialCurvesTable.m
//  AudioKit
//
//  Created by Adam Boulanger on 6/21/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//

#import "AKExponentialCurvesTable.h"

@implementation AKExponentialCurvesTable


#pragma mark - Exponential Curves Values and Lengths

- (instancetype)initWithSize:(int)tableSize
            valueLengthPairs:(AKArray *)valueLengthPairs
{
    return [self initWithType:kFTExponentialCurves
                         size:tableSize
                   parameters:valueLengthPairs];
}

- (instancetype)initWithSize:(int)tableSize
                      values:(AKArray *)values
                     lengths:(AKArray *)lengths;
{
    return [self initWithSize:tableSize valueLengthPairs:[values pairWith:lengths]];
}

#pragma mark - Exponential Curves From Breakpoints

- (instancetype)initWithSize:(int)tableSize
                 breakpoints:(AKArray *)breakpoints;
{
    return [self initWithType:kFTExponentialCurvesFromBreakpoints
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
