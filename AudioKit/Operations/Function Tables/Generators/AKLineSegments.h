//
//  AKLineSegments.h
//  AudioKit
//
//  Created by Aurelius Prochazka on 12/26/14.
//  Copyright (c) 2014 Aurelius Prochazka. All rights reserved.
//

#import "AKFunctionTable.h"

/**
*/
@interface AKLineSegments : AKFunctionTable

/// Start the line segments at a specific value
/// @param value Initial value of the the first line segment
- (instancetype)initWithInitialValue:(float)value;

/// Add a junction point
/// @param value The value at the given index
/// @param index The index at which the value will be set
- (void)addValue:(float)value atIndex:(int)index;

/// Add a junction point
/// @param value The value at the given index
/// @param index The index at which the value will be set
- (void)appendValue:(float)value afterNumberOfElements:(int)index;

@end
