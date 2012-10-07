//
//  OCSEvent.h
//  Objective-C Sound
//
//  Created by Aurelius Prochazka on 7/1/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//

#import "OCSInstrument.h"
#import "OCSNote.h"

/** Analogous to a MIDI event, an OCS Event can be based on a OCSNote such as
 a note on, note off, note property change, or it can be a block containing
 intrument property changes.  The block can 
 */

@interface OCSEvent : NSObject

// -----------------------------------------------------------------------------
#  pragma mark - Initialization
// -----------------------------------------------------------------------------

@property (nonatomic, strong) OCSNote *note;

/// Create an event with a note
- (id)initWithNote:(OCSNote *)newNote;

/// Create an event with a note and a block
- (id)initWithNote:(OCSNote *)newNote block:(void (^)())aBlock;

/// Create an event from the code block given
/// @param aBlock Code to run when the event is started
- (id)initWithBlock:(void (^)())aBlock;

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

