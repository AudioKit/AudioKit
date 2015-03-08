//
//  AKMidiListener.h
//  AudioKit
//
//  Created by Aurelius Prochazka on 10/8/12.
//  Copyright (c) 2012 Aurelius Prochazka. All rights reserved.
//

/** Implement the AKMidiListener protocol on any classes that need to respond
 to incoming MIDI events.  Every method in the protocol is optional to allow
 the classes complete freedom to respond to only the particular MIDI messages
 of interest.
 */

#import <Foundation/Foundation.h>

@protocol AKMidiListener <NSObject>

// -----------------------------------------------------------------------------
#  pragma mark - AKMidiListener Procol - Basic MIDI
// -----------------------------------------------------------------------------

@optional

/// Receive the MIDI note on event
/// @param note     Note number of activated note
/// @param velocity MIDI Velocity (0-127)
/// @param channel  MIDI Channel (1-16)
- (void)midiNoteOn:(int)note
          velocity:(int)velocity
           channel:(int)channel;

/// Receive the MIDI note off event
/// @param note     Note number of released note
/// @param velocity MIDI Velocity (0-127) usually speed of release, often 0.
/// @param channel  MIDI Channel (1-16)
- (void)midiNoteOff:(int)note
           velocity:(int)velocity
            channel:(int)channel;

/// Receive single note based aftertouch event
/// @param note     Note number of touched note
/// @param pressure Pressure applied to the note (0-127)
/// @param channel  MIDI Channel (1-16)
- (void)midiAftertouchOnNote:(int)note
                    pressure:(int)pressure
                     channel:(int)channel;

/// Receive a generic controller value
/// @param controller MIDI Controller Number
/// @param value      Value of this controller
/// @param channel    MIDI Channel (1-16)
- (void)midiController:(int)controller
        changedToValue:(int)value
               channel:(int)channel;

/// Receive global aftertouch
/// @param pressure Pressure applied (0-127)
/// @param channel  MIDI Channel (1-16)
- (void)midiAftertouch:(int)pressure
               channel:(int)channel;

/// Receive pitch wheel value
/// @param pitchWheelValue MIDI Pitch Wheel Value (0-127)
/// @param channel         MIDI Channel (1-16)
- (void)midiPitchWheel:(int)pitchWheelValue
               channel:(int)channel;

// -----------------------------------------------------------------------------
# pragma mark - AKMidiListener Protocol - Named Controllers
// -----------------------------------------------------------------------------
/// Receive modulation controllervalue
/// @param modulation Modulation value
/// @param channel    MIDI Channel (1-16)
- (void)midiModulation:(int)modulation channel:(int)channel;

/// Receive portamento controller value
/// @param portamento Portamento value
/// @param channel    MIDI Channel (1-16)
- (void)midiPortamento:(int)portamento channel:(int)channel;

/// Receive value controller value
/// @param volume Volume (Loudness)
/// @param channel  MIDI Channel (1-16)
- (void)midiVolume:(int)volume channel:(int)channel;

/// Receive balance controller value
/// @param balance Left-right balance (Left 0-63, Center 64, Right 65-127)
/// @param channel MIDI Channel (1-16)
- (void)midiBalance:(int)balance channel:(int)channel;

/// Receive pan controller value
/// @param pan     Pan (Left 0-63, Center 64, Right 65-127)
/// @param channel MIDI Channel (1-16)
- (void)midiPan:(int)pan channel:(int)channel;

/// Receive expression controller value
/// @param expression Expression (usually as a pedal)
/// @param channel    MIDI Channel (1-16)
- (void)midiExpression:(int)expression channel:(int)channel;

@end


