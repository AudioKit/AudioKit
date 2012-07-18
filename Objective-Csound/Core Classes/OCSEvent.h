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
@property (nonatomic, strong) OCSInstrument *instrument;
@property (nonatomic, strong) NSMutableArray *notePropertyValues;
@property (nonatomic, strong) NSMutableArray *properties;

/// Create an event with a fixed duration on the specified instrument.
/// @param instrument Activated instrument.
/// @param duration   Length of event in seconds.
- (id)initWithInstrument:(OCSInstrument *)instrument;

- (id)initWithEvent:(OCSEvent *)event;

- (id)initDeactivation:(OCSEvent *)event
         afterDuration:(float)delay;

/// Create an event that sets a property to a value
/// @param property The property to be set.
/// @param value    The new value of the property.
- (id)initWithInstrumentProperty:(OCSProperty *)property
                           value:(float)value;

/// Add a property setting to an event.
/// @param property The property to be set.
/// @param value    The new value of the property.
- (void)setInstrumentProperty:(OCSProperty *)property 
            toValue:(float)value; 

- (void)setNoteProperty:(OCSProperty *)property 
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
