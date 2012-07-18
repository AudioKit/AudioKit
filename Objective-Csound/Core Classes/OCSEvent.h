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

/// Unique Identifier for the event
@property (readonly) float eventNumber;

/// The instrument the event is targeting.
@property (nonatomic, strong) OCSInstrument *instrument;

/// A list of all the note property values.
@property (nonatomic, strong) NSMutableArray *notePropertyValues;

/// A list (usually just one) of instrument level properties.
@property (nonatomic, strong) NSMutableArray *properties;

/// Create an event with a fixed duration on the specified instrument.
/// @param instrument Activated instrument.
- (id)initWithInstrument:(OCSInstrument *)instrument;

/// When creating a sequence of events that affect the same note, this function is useful.
/// @param event The event that you want to use as the basis for the next event.
- (id)initWithEvent:(OCSEvent *)event;


/// Send a note-off message to an event.
/// @param event The event to be turned off.
/// @param delay The time to wait before deactivation.
- (id)initDeactivation:(OCSEvent *)event
         afterDuration:(float)delay;

/// Create an event that sets a property to a value
/// @param property The property to be set.
/// @param value    The new value of the property.
- (id)initWithInstrumentProperty:(OCSInstrumentProperty *)property
                           value:(float)value;

/// Add a property setting to an event.
/// @param property The property to be set.
/// @param value    The new value of the property.
- (void)setInstrumentProperty:(OCSInstrumentProperty *)property 
            toValue:(float)value; 


/// Alter the value of a note's property.
/// @param property The note property that will be changed.
/// @param value    The new value of the note property.
- (void)setNoteProperty:(OCSNoteProperty *)property 
                 toValue:(float)value; 

/// Helper method to play the event.
- (void)trigger;

/// Iterates through all properties and trigger their value changes.
- (void)setNoteProperties;
- (void)setInstrumentProperties;

/// Provides the scoreline to the CSD File.
- (NSString *)stringForCSD;

/// Allows the unique identifying integer to be reset so that the numbers don't increment indefinitely.
+ (void)resetID;

@end
