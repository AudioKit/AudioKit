//
//  AKLineSegments.m
//  AudioKit
//
//  Created by Aurelius Prochazka on 12/26/14.
//  Copyright (c) 2014 Aurelius Prochazka. All rights reserved.
//

#import "AKLineSegments.h"

@implementation AKLineSegments

- (instancetype)initWithInitialValue:(float)value
{
    return [self initWithType:AKFunctionTableTypeStraightLines
                         size:tableSize
                   parameters:valueLengthPairs];
}

- (void)addValue:(float)value atIndex:(int)index
{
    
}

- (void)appendValue:(float)value afterNumberOfElements:(int)index
{
    
}

@end
