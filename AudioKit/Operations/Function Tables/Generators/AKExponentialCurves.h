//
//  AKExponentialCurves.h
//  AudioKit
//
//  Created by Aurelius Prochazka on 12/26/14.
//  Copyright (c) 2014 Aurelius Prochazka. All rights reserved.
//

#import "AKFunctionTable.h"

/** Constructs functions from segments of exponential curves.
 
 Ordinate values, in odd-numbered parts of the array, must be nonzero and must be alike in sign.
 */
@interface AKExponentialCurves : AKFunctionTable

/// Size of the table (default 4096)
@property int size;

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
