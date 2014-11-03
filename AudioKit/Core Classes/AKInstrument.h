//
//  AKInstrument.h
//  AudioKit
//
//  Created by Aurelius Prochazka on 4/11/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AKOrchestra.h"
#import "AKParameter+Operation.h"
#import "AKAudio.h"
#import "AKNote.h"
#import "AKNoteProperty.h"
#import "AKInstrumentProperty.h"
@class AKEvent;

/** Manages functions that most AK instruments need to have.*/

@interface AKInstrument : NSObject 

// -----------------------------------------------------------------------------
#  pragma mark - Initialization
// -----------------------------------------------------------------------------

/// Unique instrument number
- (int)instrumentNumber;

/// A string uniquely defined by the instrument class name and a unique integer.
- (NSString *)uniqueName;

/// Allows the unique identifying integer to be reset so that the numbers don't increment indefinitely.
+ (void)resetID;

// -----------------------------------------------------------------------------
#  pragma mark - Properties
// -----------------------------------------------------------------------------

/// Array of instrument properties available for the instrument.
@property (nonatomic, strong) NSMutableArray *properties;


/// Array of note properties available to events.
@property (nonatomic, strong) NSMutableArray *noteProperties;

/// After an AKProperty is created, it must be added to the instrument.
/// @param newProperty New property to add to the instrument.
- (void) addProperty:(AKInstrumentProperty *)newProperty;
- (void) addProperty:(AKInstrumentProperty *)newProperty
            withName:(NSString *)name;

/// After an AKNoteProperty is created, it must be added to the instrument.
/// @param newNoteProperty New note property instrument needs to be aware of.
- (void)addNoteProperty:(AKNoteProperty *)newNoteProperty;


// -----------------------------------------------------------------------------
#  pragma mark - F Tables
// -----------------------------------------------------------------------------

/** All FTables that are required by the instrument are stored here and declared
 once in the F-Statement section. */
@property (nonatomic, strong) NSMutableSet *fTables;

/// Adds the function table to the Orchestra, so it is only processed once.
/// @param newFTable New function table to add to the instrument.
- (void)addFTable:(AKFTable *)newFTable;

/// Adds the function table to the AKInstrument dynamically, processed for each note.
/// @param newFTable New function table to add to the instrument.
- (void)addDynamicFTable:(AKFTable *)newFTable;

// -----------------------------------------------------------------------------
#  pragma mark - Operations
// -----------------------------------------------------------------------------

/** All UDOs that are required by the instrument are stored here and declared before any
 instrument blocks. */
@property (nonatomic, strong) NSMutableSet *userDefinedOperations;

/// Adds the operation to the AKInstrument.
/// @param newOperation New operation to add to the instrument.
- (void)connect:(AKParameter *)newOperation;

/// Adds the User-Defined Operation to the instrument (and the opcode defintion .udo file)
/// @param newUserDefinedOperation New UDO to add to the instrument.
- (void)addUDO:(AKParameter *)newUserDefinedOperation;

/// Adds any string to the output file, useful for testing and commenting.
/// @param newString New string to add to the instrument definition.
- (void)addString:(NSString *)newString;

/// Shortcut for the AKAssignment operation for setting a parameter equal to another.
/// @param output Parameter being set.
/// @param input  Parameter being read.
- (void)assignOutput:(AKParameter *)output to:(AKParameter *)input;

/// Shortcut for setting a parameter's value to zero.
/// @param parameterToReset Parameter whose value will be reset to zero.
- (void)resetParameter:(AKParameter *)parameterToReset;

// -----------------------------------------------------------------------------
#  pragma mark - Csound Implementation
// -----------------------------------------------------------------------------

/// Sets the orchestra as internal variable so that when the instrument is asked to play,
/// it sends the event to the appropriate orchestra.
/// @param orchestraToJoin Orchestra to which the instrument belongs.
- (void)joinOrchestra:(AKOrchestra *)orchestraToJoin;

// The textual respresentation of the instrument in CSD form.
- (NSString *)stringForCSD;

// The CSD line that deactivates all notes created by the instrument
- (NSString *)stopStringForCSD;

/// Play an instrument that contains no note properties ie. uses a generic
/// AKNote to begin playback for a specific amount of time.
/// @param playDuration Length of time in seconds to play the instrument.
- (void)playForDuration:(float)playDuration;

/// For instruments that do not create note instances, play the instrument with infinite duration.
- (void)play;

/// Play the given note
/// @param note The note that will be played.
- (void)playNote:(AKNote *)note;

/// Stop all notes created by the instrument
- (void)stop;


@end
