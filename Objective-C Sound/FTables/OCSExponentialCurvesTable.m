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

- (instancetype)initWithSize:(int)tableSize
            valueLengthPairs:(OCSArray *)valueLengthPairs
{
    return [self initWithType:kFTExponentialCurves
                         size:tableSize
                   parameters:valueLengthPairs];
}

- (instancetype)initWithSize:(int)tableSize
                      values:(OCSArray *)values
                     lengths:(OCSArray *)lengths;
{
    return [self initWithSize:tableSize valueLengthPairs:[values pairWith:lengths]];
}

#pragma mark Exponential Curves From Breakpoints

- (instancetype)initWithSize:(int)tableSize
                 breakpoints:(OCSArray *)breakpoints;
{
    return [self initWithType:kFTExponentialCurvesFromBreakpoints
                         size:tableSize
                   parameters:breakpoints];
}

- (instancetype)initWithSize:(int)tableSize
           breakpointXValues:(OCSArray *)xValues
           breakpointYValues:(OCSArray *)yValues;
{
    return [self initWithSize:tableSize breakpoints:[xValues pairWith:yValues]];
}


@end
