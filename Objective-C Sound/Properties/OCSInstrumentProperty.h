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
    float currentValue;
}

/// Current value of the property.
@property (nonatomic, assign) float value;

/// Minimum Value allowed.
@property (nonatomic, assign) float minimumValue;

/// Maximum Value allowed.
@property (nonatomic, assign) float maximumValue;

/// Optional pretty name for properties useful for debugging.
@property (nonatomic, strong) NSString *name;


/// Initialize the property with bounds.
/// @param minimumValue Minimum value.
/// @param maximumValue Maximum value.
- (instancetype)initWithMinimumValue:(float)minimumValue
                        maximumValue:(float)maximumValue;

/// Initialize the property with an initial value and bounds.
/// @param initialValue Initial value.
/// @param minimumValue Minimum value.
/// @param maximumValue Maximum value.
- (instancetype)initWithValue:(float)initialValue
                 minimumValue:(float)minimumValue
                 maximumValue:(float)maximumValue;



/// String with the appropriate chnget statement for the CSD File
- (NSString *)stringForCSDGetValue;

/// String with the appropriate chnset statement for the CSD File
- (NSString *)stringForCSDSetValue;

/// Randomize the current value between the minimum and maximum values
- (void)randomize;

@end
