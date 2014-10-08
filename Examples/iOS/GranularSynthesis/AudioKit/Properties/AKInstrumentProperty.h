//
//  AKInstrumentProperty.h
//  AudioKit
//
//  Created by Aurelius Prochazka on 7/18/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//

#import "AKControl.h"

/** Instrument properties are properties of an instrument that are shared
 amongst all the notes that are created on that instrument.
 */
@interface AKInstrumentProperty : AKControl

/// Current value of the property.
@property (nonatomic, assign) float value;

/// Start value for initialization.
@property (nonatomic, assign) float initialValue;

/// Minimum Value allowed.
@property (nonatomic, assign) float minimum;

/// Maximum Value allowed.
@property (nonatomic, assign) float maximum;

/// Optional pretty name for properties useful for debugging.
@property (nonatomic, strong) NSString *name;

/// Initialize the property with bounds.
/// @param minimum Minimum value.
/// @param maximum Maximum value.
- (instancetype)initWithMinimum:(float)minimum
                        maximum:(float)maximum;

/// Initialize the property with an initial value and bounds.
/// @param initialValue Initial value.
/// @param minimum Minimum value.
/// @param maximum Maximum value.
- (instancetype)initWithValue:(float)initialValue
                      minimum:(float)minimum
                      maximum:(float)maximum;

// String with the appropriate chnget statement for the CSD File
- (NSString *)stringForCSDGetValue;

// String with the appropriate chnset statement for the CSD File
- (NSString *)stringForCSDSetValue;

/// Sets the current value to the initial value.
- (void)reset;

/// Randomize the current value between the minimum and maximum values
- (void)randomize;

/// Scale the property in its own range given another range and value
/// @param value   Source value.
/// @param minimum Minimum value in source range.
/// @param maximum Maximum value in source range.
- (void)scaleWithValue:(float)value
               minimum:(float)minimum
               maximum:(float)maximum;

@end
