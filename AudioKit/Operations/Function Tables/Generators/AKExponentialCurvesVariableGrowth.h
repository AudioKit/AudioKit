//
//  AKExponentialCurvesVariableGrowth.h
//  EasyExponentialCurves
//
//  Created by Adam Boulanger on 1/20/15.
//  Copyright (c) 2015 Adam Boulanger. All rights reserved.
//

#import "AKFunctionTable.h"

/** Constructs concatenated power functions with control over second order derivative.
 Positive growth factor yields a positive second order derivative (concave up) curve.  Negative growth factor will yield a negative second order derivative (concave down) curve.
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
/// @param growthFactor The growth factor, positive or negative concave within range [-10,10] 0 being a straight line
- (void)addValue:(float)value atIndex:(int)index growthFactor:(int)growthFactor;

/// Add a junction point
/// @param value The value at the given index
/// @param growthFactor the amount of positive or negative concave within range [-10,10] 0 being a straight line
/// @param numberOfElements The index at which the value will be set
-(void)appendValue:(float)value
afterNumberOfElements:(int)numberOfElements
      growthFactor:(int)growthFactor;

@end
