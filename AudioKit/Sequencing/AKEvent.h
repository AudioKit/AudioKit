//
//  AKEvent.h
//  AudioKit
//
//  Created by Aurelius Prochazka on 7/1/12.
//  Copyright (c) 2012 Aurelius Prochazka. All rights reserved.
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

/// Create an event from the code block given
/// @param aBlock Code to run when the event is started
- (instancetype)initWithBlock:(void (^)())aBlock;

// -----------------------------------------------------------------------------
#  pragma mark - Event actions
// -----------------------------------------------------------------------------

/// Execute the block of code stored in the event.
- (void)runBlock;

/// Helper method to start the event.
- (void)trigger;


@end

