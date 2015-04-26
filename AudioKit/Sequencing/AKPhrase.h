//
//  AKPhrase.h
//  ContinuousControl
//
//  Created by Aurelius Prochazka on 12/12/14.
//  Copyright (c) 2014 Aurelius Prochazka. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AKCompatibility.h"

@class AKNote;
@class AKInstrument;
@class AKNoteProperty;

/** A collection of notes and start times that can be played by an instrument.
 */
NS_ASSUME_NONNULL_BEGIN
@interface AKPhrase : NSObject

/// Number of notes in the phrase
@property (nonatomic, readonly) NSUInteger count;

/// Length of the phrase in seconds
@property (nonatomic, readonly) float duration;

/// Class-level initializer for empty phrase
+ (AKPhrase *)phrase;

/// Remove all notes
- (void)reset;

/// Add a note to the beginning of the phrase
/// @param note Note to be added at time zero
- (void)addNote:(AKNote *)note;

/// Add a note to the phrase at a specific time
/// @param note Note to be added
/// @param time Time the note will be played
- (void)addNote:(AKNote *)note atTime:(float)time;

/// Add a note to the phrase at a specific time
/// @param note Note to be added
/// @param time Time the note will be played
- (void)startNote:(AKNote *)note atTime:(float)time;

/// Stop a note in the phrase at a specific time
/// @param note Note to be stopped
/// @param time Time the note will be stopped
- (void)stopNote:(AKNote *)note atTime:(float)time;


/// Update a note property with a specific value at a specific time
/// @param noteProperty Note property to change the value of
/// @param value Value of the note property
/// @param time Time the note will be stopped
- (void)updateNoteProperty:(AKNoteProperty *)noteProperty
                 withValue:(float)value
                    atTime:(float)time;

/// Play the phrase
/// @param instrument Instrument that will play the notes in the phrase
- (void)playUsingInstrument:(AKInstrument *)instrument;

@end
NS_ASSUME_NONNULL_END
