//
//  AKControl.h
//  AudioKit
//
//  Created by Aurelius Prochazka on 6/9/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//

#import "AKParameter.h"

/** These are parameters that can change at control rate
 */
@interface AKControl : AKParameter

/// Current value of the parameter.
@property (nonatomic, assign) float value;

/// Start value for initialization.
@property (nonatomic, assign) float initialValue;

/// Minimum Value allowed.
@property (nonatomic, assign) float minimum;

/// Maximum Value allowed.
@property (nonatomic, assign) float maximum;

/// Initialize the control with bounds.
/// @param minimum Minimum value.
/// @param maximum Maximum value.
- (instancetype)initWithMinimum:(float)minimum
                        maximum:(float)maximum;

/// Initialize the control with an initial value and bounds.
/// @param initialValue Initial value.
/// @param minimum Minimum value.
/// @param maximum Maximum value.
- (instancetype)initWithValue:(float)initialValue
                      minimum:(float)minimum
                      maximum:(float)maximum;

/// Sets the current value to the initial value.
- (void)reset;

/// Randomize the current value between the minimum and maximum values
- (void)randomize;

/// Converts pitch to frequency
- (instancetype)toCPS;

@end
