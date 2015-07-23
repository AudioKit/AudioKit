//
//  AKMidi.h
//  AudioKit
//
//  Created by Aurelius Prochazka on 8/12/12.
//  Copyright (c) 2012 Aurelius Prochazka. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "CsoundObj.h"
#import "AKMidiEvent.h"

/** AKMidi is the object that handles the MIDI input and output from AudioKit.
 */
NS_ASSUME_NONNULL_BEGIN
@interface AKMidi : NSObject

- (instancetype)initWithCsound:(CsoundObj *)csound;

/// Create the MIDI client and connect to all available MIDI input sources.
- (void)openMidiIn;

/// Dispose of the MIDI client.
- (void)closeMidiIn;

/// Send a MIDI event to Csound.
- (void)sendEvent:(AKMidiEvent *)event;

/// Whether received MIDI events are automatically forwarded to Csound (default: YES)
@property BOOL forwardEvents;

/// The number of detected MIDI inputs
@property (readonly) NSUInteger inputs;

@end
NS_ASSUME_NONNULL_END
