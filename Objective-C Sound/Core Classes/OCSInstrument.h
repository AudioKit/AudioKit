//
//  OCSInstrument.h
//  Objective-C Sound
//
//  Created by Aurelius Prochazka on 4/11/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OCSOrchestra.h"
#import "OCSOperation.h"
#import "OCSUserDefinedOperation.h"
#import "OCSNoteProperty.h"
#import "OCSInstrumentProperty.h"
@class OCSEvent;

/** Manages functions that most OCS instruments need to have.*/

@interface OCSInstrument : NSObject 

/** This contains a list of the OCSProperty variables that are required for the instrument.
 Using this list the instrument is able to both write the get statements at the beginning 
 of the instrument block and set them at the end */

/// Array of instrument properties available for the instrument.
@property (nonatomic, strong) NSMutableArray *properties;

/// Array of note properties available to events.
@property (nonatomic, strong) NSMutableArray *noteProperties;

/** All UDOs that are required by the instrument are stored here and declared before any 
 instrument blocks in the CSD File. */
@property (nonatomic, strong) NSMutableSet *userDefinedOperations;

/** All FTables that are required by the instrument are stored here and declared 
 once in the F-Statement section of the CSD File. */
@property (nonatomic, strong) NSMutableSet *fTables;

/// Unique instrument number
- (int)instrumentNumber;

/// A string uniquely defined by the instrument class name and a unique integer.
- (NSString *)uniqueName;

/// After an OCSProperty is created, it must be added to the instrument.
/// @param newProperty New property to add to the instrument.
- (void)addProperty:(OCSProperty *)newProperty;

/// After an OCSNoteProperty is created, it must be added to the instrument.
/// @param newNoteProperty New note property to add to the instrument.
- (void)addNoteProperty:(OCSProperty *)newNoteProperty;

/// Adds the function table to the Orchestra, so it is only processed once.
/// @param newFTable New function table to add to the instrument.
- (void)addFTable:(OCSFTable *)newFTable;

/// Adds the function table to the OCSInstrument dynamically, processed for each note.
/// @param newFTable New function table to add to the instrument.
- (void)addDynamicFTable:(OCSFTable *)newFTable;

/// Adds the operation to the OCSInstrument.
/// @param newOperation New operation to add to the instrument.
- (void)connect:(OCSOperation *)newOperation;

/// Adds the User-Defined Operation to the instrument (and the opcode defintion .udo file)
/// @param newUserDefinedOperation New UDO to add to the instrument.
- (void)addUDO:(OCSUserDefinedOperation *)newUserDefinedOperation;

/// Adds any string to the CSD file, useful for testing and commenting within the CSD file.
/// @param newString New string to add to the instrument definition.
- (void)addString:(NSString *)newString;

/// Shortcut for the OCSAssignment operation for setting a parameter equal to another.
/// @param output Parameter being set.
/// @param input  Parameter being read.
- (void)assignOutput:(OCSParameter *)output To:(OCSParameter *)input; 

/// Shortcut for setting a parameter's value to zero.
/// @param parameterToReset Parameter whose value will be reset to zero.
- (void)resetParam:(OCSParameter *)parameterToReset;

/// Sets the orchestra as internal variable so that when the instrument is asked to play,
/// it sends the event to the appropriate orchestra.
/// @param orchestraToJoin Orchestra to which the instrument belongs.
- (void)joinOrchestra:(OCSOrchestra *)orchestraToJoin;

/// @returns The complete textual respresentation of the instrument in CSD form.
- (NSString *)stringForCSD;

/// Create a score line entry for starting the note immediately
/// @param playDuration Length of time in seconds to play the instrument.
- (void)playNoteForDuration:(float)playDuration;


/// Allows the unique identifying integer to be reset so that the numbers don't increment indefinitely.
+ (void)resetID;

@end
