//
//  AKMidiEvent.h
//  AudioKit
//
//  Created by Stéphane Peter on 7/22/15.
//  Copyright © 2015 AudioKit. All rights reserved.
//

#import <Foundation/Foundation.h>

/// MIDI note on/off, control and system exclusive constants

// These are the top 4 bits of the MIDI command, for commands that take a channel number in the low 4 bits
typedef NS_ENUM(UInt8, AKMidiConstant)
{
    AKMidiConstantNoteOff = 8,
    AKMidiConstantNoteOn = 9,
    AKMidiConstantPolyphonicAftertouch = 10,
    AKMidiConstantControllerChange = 11,
    AKMidiConstantProgramChange = 12,
    AKMidiConstantChannelAftertouch = 13,
    AKMidiConstantPitchWheel = 14,
    AKMidiConstantSystemCommand = 15
};

// System commands (8 bits - 0xFx) that do not require a channel number
typedef NS_ENUM(UInt8, AKMidiSystemCommand)
{
    AKMidiCommandNone = 0,
    AKMidiCommandSysex = 240,
    AKMidiCommandSongPosition = 242,
    AKMidiCommandSongSelect = 243,
    AKMidiCommandTuneRequest = 246,
    AKMidiCommandSysexEnd = 247,
    AKMidiCommandClock = 248,
    AKMidiCommandStart = 250,
    AKMidiCommandContinue = 251,
    AKMidiCommandStop = 252,
    AKMidiCommandActiveSensing = 254,
    AKMidiCommandSysReset = 255
};

// Forward declaration from CoreMidi
typedef struct MIDIPacket MIDIPacket;

NS_ASSUME_NONNULL_BEGIN
@interface AKMidiEvent : NSObject

// Up to 3 bytes of data in a single MIDI event, status and channel share the first byte.
/// The MIDI status control, might be AKMidiConstantSystemCommand
@property (readonly,nonatomic) AKMidiConstant status;
/// The MIDI system command this event is for, or None
@property (readonly,nonatomic) AKMidiSystemCommand command;

/// Channel number is 0..15, not 1..16
@property (readonly,nonatomic) UInt8 channel;
/// Additional 7-bits of data (0..127)
@property (readonly,nonatomic) UInt8 data1, data2;
/// Composite using data1 as LSB, data2 as MSB (14 bits of data)
@property (readonly,nonatomic) UInt16 data;

/// The MIDI message data bytes as NSData.
@property (readonly,nonatomic) NSData *bytes;

- (instancetype)initWithStatus:(AKMidiConstant)status channel:(UInt8)channel data1:(UInt8)d1 data2:(UInt8)d2;
- (instancetype)initWithSystemCommand:(AKMidiSystemCommand)command data1:(UInt8)d1 data2:(UInt8)d2;
/// Create from a CoreMIDI packet.
- (instancetype)initWithMIDIPacket:(MIDIPacket *)packet;
/// Create from a NSData object.
- (instancetype)initWithData:(NSData *)data;

/// Convenience constructor
+ (instancetype)midiEventFromPacket:(MIDIPacket *)packet;

@end
NS_ASSUME_NONNULL_END

