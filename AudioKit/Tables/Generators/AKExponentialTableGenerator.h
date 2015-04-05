//
//  AKExponentialTableGenerator.h
//  AudioKit
//
//  Created by Aurelius Prochazka on 3/2/15.
//  Copyright (c) 2015 Aurelius Prochazka. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AKTableGenerator.h"

/// A table generator that creates a series of exponential curve segments
@interface AKExponentialTableGenerator : AKTableGenerator

/// Start the exponential curves at a specific value
/// @param value Initial value of the the first line segment
- (instancetype)initWithValue:(float)value;

/// Add a junction point
/// @param value The value at the given index
/// @param index The index at which the value will be set
- (void)addValue:(float)value atIndex:(int)index;

/// Add a junction point
/// @param value The value at the given index
/// @param numberOfElements The index at which the value will be set
- (void)appendValue:(float)value afterNumberOfElements:(int)numberOfElements;

@end
