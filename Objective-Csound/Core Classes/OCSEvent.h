//
//  OCSEvent.h
//  Objective-Csound
//
//  Created by Aurelius Prochazka on 7/1/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//

#import "OCSInstrument.h"

/** Analogous to a MIDI event, an OCS Event can be a note on or off command
 or a control property change.
 */

@interface OCSEvent : NSObject

/// The maximum duration of the event.
@property (readonly) float duration;

/// Create an event with a fixed duration on the specified instrument.
/// @param instrument Activated instrument.
/// @param duration   Length of event in seconds.
- (id)initWithInstrument:(OCSInstrument *)instrument
                duration:(float)duration;

/// Create an event that sets a property to a value
/// @param property The property to be set.
/// @param value    The new value of the property.
- (id)initWithProperty:(OCSProperty *)property
                 value:(float)value;

/// Add a property setting to an event.
/// @param property The property to be set.
/// @param value    The new value of the property.
- (void)setProperty:(OCSProperty *)property 
            toValue:(float)value; 


/// Helper method to play the event.
- (void)play;

/// Iterates through all properties and trigger their value changes.
- (void)setProperties;

/// Provides the scoreline to the CSD File.
- (NSString *)stringForCSD;

@end
