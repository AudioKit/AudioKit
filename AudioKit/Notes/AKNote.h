//
//  AKNote.h
//  AudioKit
//
//  Created by Aurelius Prochazka on 9/18/12.
//  Copyright (c) 2012 Aurelius Prochazka. All rights reserved.
//

#import "AKCompatibility.h"
#import "AKInstrument.h"
#import "AKNoteProperty.h"

/** AKNote is a representation of a sound object that is created by an
 AKInstrument and has at least one of the two following qualities:
 a) The note has a duration, it starts and some finite time later, it ends.
 b) The note is created concurrently with other notes created by the instrument
 */

NS_ASSUME_NONNULL_BEGIN
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
                       forDuration:(NSTimeInterval)noteDuration;

/// Creates the note associated with the given instrument
/// @param anInstrument This note's instrument.
- (instancetype)initWithInstrument:(AKInstrument *)anInstrument;

// -----------------------------------------------------------------------------
#  pragma mark - Properties and Property Management
// -----------------------------------------------------------------------------

/// Instrument this note belongs to
@property (nonatomic) AKInstrument *instrument;

/// Duration of this note (for finite notes with length defined)
@property AKNoteProperty *duration;

/// Set of properties of the note
@property NSMutableDictionary<NSString *, AKNoteProperty *> *properties;

/// Adds the property to the list of available properties of the note
/// @param newProperty New property to add to the note's set of properties
- (void)addProperty:(AKNoteProperty *)newProperty;

/// Helper function to create a property with the usually values and add it to the note
/// @param value   Current value of the note property
/// @param minimum Minimum value
/// @param maximum Maximum value
- (AKNoteProperty *)createPropertyWithValue:(float)value
                                    minimum:(float)minimum
                                    maximum:(float)maximum;

/// Refine playback of the note.
- (void)updateProperties;

/// Refine playback of the note at some point in the future.
/// @param time Amount of time in seconds to wait before setting properties
- (void)updatePropertiesAfterDelay:(NSTimeInterval)time;

// -----------------------------------------------------------------------------
#  pragma mark - Playback Controls
// -----------------------------------------------------------------------------

/// Begin playback of the note.
- (void)play;

/// Begin playback of the note after a delay.
/// @param delay Time to wait in seconds before beginning note playback.
- (void)playAfterDelay:(NSTimeInterval)delay;

/// Stop playback of the note.
- (void)stop;

/// Stop playback of the note after a delay.
/// @param delay Time to wait in seconds before stopping note playback.
- (void)stopAfterDelay:(NSTimeInterval)delay;

// Returns the playback scoreline to the CSD File.
- (NSString *)stringForCSD;

// Returns the stop scoreline to the CSD File.
- (NSString *)stopStringForCSD;

@end
NS_ASSUME_NONNULL_END

