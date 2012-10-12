//
//  OCSInstrumentProperty.h
//  Objective-C Sound
//
//  Created by Aurelius Prochazka on 7/18/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//

#import "OCSControl.h"
#import "CsoundObj.h"
#import "CsoundValueCacheable.h"


/** Instrument properties are properties of an instrument that are shared 
 amongst all the notes that are created on that instrument. 
 */
@interface OCSInstrumentProperty : OCSControl <CsoundValueCacheable> {
    BOOL mCacheDirty;
    
    //channelName
    MYFLT *channelPtr;

    Float32 maximumValue;
    Float32 minimumValue;
    Float32 currentValue;
}

/// Current value of the property.
@property (nonatomic, assign) Float32 value;

/// Minimum Value allowed.
@property (nonatomic, assign) Float32 minimumValue;

/// Maximum Value allowed.
@property (nonatomic, assign) Float32 maximumValue;

/// Optional pretty name for properties useful for debugging.
@property (nonatomic, strong) NSString *name;


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

/// Randomize the current value between the minimum and maximum values
- (void)randomize;

@end
