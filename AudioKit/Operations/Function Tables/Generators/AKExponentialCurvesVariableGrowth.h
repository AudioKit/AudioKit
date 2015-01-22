//
//  AKExponentialCurvesVariableGrowth.h
//  EasyExponentialCurves
//
//  Created by Adam Boulanger on 1/20/15.
//  Copyright (c) 2015 Adam Boulanger. All rights reserved.
//

#import "AKFunctionTable.h"

/** Constructs concatenated power functions with control over second order derivative.
 Positive concavity yields a negative second order derivative (concave down) curve.  Negative concavity will yield a positive second order derivative (concave down) curve.
 */
@interface AKExponentialCurvesVariableGrowth : AKFunctionTable

/// Size of the table (default 4096)
@property int size;

/// Start the power curves at a specific value
/// @param value Initial value of the first segment
-(instancetype)initWithValue:(float)value;

/// Add a junction point
/// @param value The value at the given index
/// @param index The index at which the value will be set
/// @param concavity Concave within a range [-10,10] 0 being a straight line, -10 being highly convex (concave up), +10 being highly concave (concave down).
- (void)addValue:(float)value atIndex:(int)index concavity:(int)concavity;

@end
