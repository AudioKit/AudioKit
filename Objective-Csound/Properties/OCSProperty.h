//
//  OCSProperty.h
//  Objective-Csound
//
//  Created by Adam Boulanger on 6/15/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//

#import "OCSConstant.h"
#import "BaseValueCacheable.h"
/** Properties allow data to be transferred to and from Csound.
 
 */
@interface OCSProperty : BaseValueCacheable

/// Current value of the property.
@property (nonatomic, readwrite) Float32 value;

/// Maximum Value allowed.
@property (nonatomic, assign) Float32 maximumValue;

/// Minimum Value allowed.
@property (nonatomic, assign) Float32 minimumValue;

/// Initial value assigned.
@property (nonatomic, assign) Float32 initValue;

/// Audio (a-rate) output, theoretically.
@property (nonatomic, strong) OCSParameter *audio;

/// Control-rate (k-rate) output.
@property (nonatomic, strong) OCSControl *control;

/// Event-rate (i-rate) output.
@property (nonatomic, strong) OCSConstant *constant;

/// Catch-all output, necessary for parameterization.
@property (nonatomic, strong) OCSParameter *output;

/// isMidiEnabled
@property (readwrite) BOOL isMidiEnabled;

/// Midi Controller Number (0-127).
@property (readwrite) int midiController;

/// Initialize the property with bounds.
/// @param minValue Minimum value.
/// @param maxValue Maximum value.
- (id)initWithMinValue:(float)minValue 
              maxValue:(float)maxValue;

/// Initialize the property with an initial value and bounds.
/// @param initialValue Initial value.
/// @param minValue Minimum value.
/// @param maxValue Maximum value.
- (id)initWithValue:(float)initialValue 
           minValue:(float)minValue 
           maxValue:(float)maxValue;

/// String with the appropriate chnget statement for the CSD File
- (NSString *)stringForCSDGetValue;

/// String with the appropriate chnset statement for the CSD File
- (NSString *)stringForCSDSetValue;

/// Enable midi for this property.
/// @param Midi channel number (0-127).
-(void)enableMidiForControllerNumber:(int)controllerNumber;

@end
