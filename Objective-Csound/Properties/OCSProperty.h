//
//  OCSProperty.h
//
//  Created by Adam Boulanger on 6/15/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//

#import "OCSParamConstant.h"
#import "BaseValueCacheable.h"
/** Properties allow data to be transferred to and from Csound.
 
 */
@interface OCSProperty : BaseValueCacheable

/// Current value of the property.
@property (nonatomic, readwrite) Float32 value;

/// Maximum Value allowed... although no checking is currently in place.
@property (nonatomic, assign) Float32 maximumValue;

/// Minimum Value allowed... although no checking is currently in place.
@property (nonatomic, assign) Float32 minimumValue;

/// Initial value assigned.
@property (nonatomic, assign) Float32 initValue;

/// Control-rate (k-rate) output.
@property (nonatomic, strong) OCSParamControl *control;

/// Event-rate (i-rate) output.
@property (nonatomic, strong) OCSParamConstant *constant;

/// Audio (a-rate) output, theoretically.
@property (nonatomic, strong) OCSParam *output;

/// Initialize the property with an initial value
/// @param initialValue Initial value.
- (id)initWithValue:(float)initialValue;

/// Initialize the property with an initial value and bounds.
/// @param initialValue Initial value.
/// @param min Minimum value.
/// @param max Maximum value.
- (id)initWithValue:(float)initialValue Min:(float)min Max:(float)max;

/// String with the appropriate chnget statement for the CSD File
- (NSString *)stringForCSDGetValue;

/// String with the appropriate chnset statement for the CSD File
- (NSString *)stringForCSDSetValue;

@end
