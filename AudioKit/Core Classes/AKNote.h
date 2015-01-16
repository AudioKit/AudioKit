//
//  AKNote.h
//  AudioKit
//
//  Created by Aurelius Prochazka on 9/18/12.
//  Copyright (c) 2012 Aurelius Prochazka. All rights reserved.
//

#import "AKInstrument.h"
#import "AKNoteProperty.h"

/** AKNote is a representation of a sound object that is created by an
 AKInstrument and has at least one of the two following qualities:
 a) The note has a duration, it starts and some finite time later, it ends.
 b) The note is created concurrently with other notes created by the instrument
 */

@interface AKNote : NSObject

// -----------------------------------------------------------------------------
#  pragma mark - Initialization
// -----------------------------------------------------------------------------

/// Allows the unique identifying integer to be reset so that the numbers don't increment indefinitely.
+ (void)resetID;

/// Creates the note associated with the given instrument
/// @param anInstrument This note's instrument.
/// @param noteDuration Length of time to play the note in seconds
- (instancetype)initWithInstrument:(AKInstrument *)anInstrument
                       forDuration:(float)noteDuration;

/// Creates the note associated with the given instrument
/// @param anInstrument This note's instrument.
- (instancetype)initWithInstrument:(AKInstrument *)anInstrument;

// -----------------------------------------------------------------------------
#  pragma mark - Properties and Property Management
// -----------------------------------------------------------------------------

/// Instrument this note belongs to
@property (nonatomic, strong) AKInstrument *instrument;

/// Duration of this note (for finite notes with length defined)
@property (nonatomic, strong) AKNoteProperty *duration;

/// Set of properties of the note
@property (nonatomic, strong) NSMutableDictionary *properties;

/// Adds the property to the list of available properties of the note
/// @param newProperty New property to add to the note's set of properties
/// @param name        Human readable name for the of the property
- (void) addProperty:(AKNoteProperty *)newProperty
            withName:(NSString *)name;

/// Adds the property to the list of available properties of the note
/// @param newProperty New property to add to the note's set of properties
- (void) addProperty:(AKNoteProperty *)newProperty;

/// Refine playback of the note.
- (void)updateProperties;

/// Refine playback of the note at some point in the future.
- (void)updatePropertiesAfterDelay:(float)time;

// -----------------------------------------------------------------------------
#  pragma mark - Playback Controls
// -----------------------------------------------------------------------------

/// Begin playback of the note.
- (void)play;

/// Begin playback of the note after a delay.
/// @param delay Time to wait before beginning note playback.
- (void)playAfterDelay:(float)delay;

/// Stop playback of the note.
- (void)stop;

/// Stop playback of the note after a delay.
/// @param delay Time to wait before stopping note playback.
- (void)stopAfterDelay:(float)delay;

// Returns the playback scoreline to the CSD File.
- (NSString *)stringForCSD;

// Returns the stop scoreline to the CSD File.
- (NSString *)stopStringForCSD;

@end
