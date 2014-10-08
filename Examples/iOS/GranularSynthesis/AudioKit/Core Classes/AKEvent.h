//
//  AKEvent.h
//  AudioKit
//
//  Created by Aurelius Prochazka on 7/1/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//

#import "AKInstrument.h"
#import "AKNote.h"

/** Analogous to a MIDI event, an AK Event can be based on a AKNote such as
 a note on, note off, note property change, or it can be a block containing
 intrument property changes.  The block can 
 */

@interface AKEvent : NSObject

// -----------------------------------------------------------------------------
#  pragma mark - Initialization
// -----------------------------------------------------------------------------

/// Optional note to play at the time of the event
@property (nonatomic, strong) AKNote *note;

/// Create an event with a note
/// @param newNote Note to play when the event is started
- (instancetype)initWithNote:(AKNote *)newNote;

/// Create an event with a note and a block
/// @param newNote Note to play when the event is started
/// @param aBlock  Code to run when the event is started
- (instancetype)initWithNote:(AKNote *)newNote block:(void (^)())aBlock;

/// Create an event from the code block given
/// @param aBlock Code to run when the event is started
- (instancetype)initWithBlock:(void (^)())aBlock;

// -----------------------------------------------------------------------------
#  pragma mark - Event actions
// -----------------------------------------------------------------------------

/// Play the stored note
- (void)playNote;

/// Execute the block of code stored in the event.
- (void)runBlock;

/// Helper method to start the event.
- (void)trigger;


@end

