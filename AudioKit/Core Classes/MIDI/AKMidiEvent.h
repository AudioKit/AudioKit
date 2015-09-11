//
//  AKMidiEvent.h
//  AudioKit
//
//  Created by Stéphane Peter on 7/22/15.
//  Copyright © 2015 AudioKit. All rights reserved.
//

#import <Foundation/Foundation.h>

// Notification names broadcasted for MIDI events being received from the inputs.
extern NSString * _Nonnull const AKMidiNoteOnNotification;
extern NSString * _Nonnull const AKMidiNoteOffNotification;
extern NSString * _Nonnull const AKMidiPolyphonicAftertouchNotification;
extern NSString * _Nonnull const AKMidiProgramChangeNotification;
extern NSString * _Nonnull const AKMidiAftertouchNotification;
extern NSString * _Nonnull const AKMidiPitchWheelNotification;
extern NSString * _Nonnull const AKMidiControllerNotification;
extern NSString * _Nonnull const AKMidiModulationNotification;
extern NSString * _Nonnull const AKMidiPortamentoNotification;
extern NSString * _Nonnull const AKMidiVolumeNotification;
extern NSString * _Nonnull const AKMidiBalanceNotification;
extern NSString * _Nonnull const AKMidiPanNotification;
extern NSString * _Nonnull const AKMidiExpressionNotification;
extern NSString * _Nonnull const AKMidiControlNotification;

/// MIDI note on/off, control and system exclusive constants

// These are the top 4 bits of the MIDI command, for commands that take a channel number in the low 4 bits
typedef NS_ENUM(UInt8, AKMidiStatus)
{
    AKMidiStatusNoteOff = 8,
    AKMidiStatusNoteOn = 9,
    AKMidiStatusPolyphonicAftertouch = 10,
    AKMidiStatusControllerChange = 11,
    AKMidiStatusProgramChange = 12,
    AKMidiStatusChannelAftertouch = 13,
    AKMidiStatusPitchWheel = 14,
    AKMidiStatusSystemCommand = 15
};

/// System commands (8 bits - 0xFx) that do not require a channel number
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

/// Value of byte 2 in conjunction with AKMidiStatusControllerChange
typedef NS_ENUM(UInt8, AKMidiControl)
{
    AKMidiControlCC0 = 0,
    AKMidiControlModulationWheel = 1,
    AKMidiControlBreathControl = 2,
    AKMidiControlCC3 = 3,
    AKMidiControlFootControl = 4,
    AKMidiControlPortamento = 5,
    AKMidiControlDataEntry = 6,
    AKMidiControlMainVolume = 7,
    AKMidiControlBalance = 8,
    AKMidiControlCC9 = 9,
    AKMidiControlPan = 10,
    AKMidiControlExpression = 11,
    AKMidiControlCC12 = 12,
    AKMidiControlCC13 = 13,
    AKMidiControlCC14 = 14,
    AKMidiControlCC15 = 15,
    AKMidiControlCC16 = 16,
    AKMidiControlCC17 = 17,
    AKMidiControlCC18 = 18,
    AKMidiControlCC19 = 19,
    AKMidiControlCC20 = 20,
    AKMidiControlCC21 = 21,
    AKMidiControlCC22 = 22,
    AKMidiControlCC23 = 23,
    AKMidiControlCC24 = 24,
    AKMidiControlCC25 = 25,
    AKMidiControlCC26 = 26,
    AKMidiControlCC27 = 27,
    AKMidiControlCC28 = 28,
    AKMidiControlCC29 = 29,
    AKMidiControlCC30 = 30,
    AKMidiControlCC31 = 31,
    
    AKMidiControlLSB = 32, // Combine with above constants to get the LSB

    AKMidiControlDamperOnOff = 64,
    AKMidiControlPortamentoOnOff = 65,
    AKMidiControlSustenutoOnOff = 66,
    AKMidiControlSoftPedalOnOff = 67,
    
    AKMidiControlDataEntryPlus = 96,
    AKMidiControlDataEntryMinus = 97,
    
    AKMidiControlLocalControlOnOff = 122,
    AKMidiControlAllNotesOff = 123,
};

/// Forward declaration from CoreMidi
typedef struct MIDIPacket MIDIPacket;

/// A class to wrap MIDI events and keep MIDI constants in
NS_ASSUME_NONNULL_BEGIN
@interface AKMidiEvent : NSObject

// Up to 3 bytes of data in a single MIDI event, status and channel share the first byte.
/// The MIDI status control, might be AKMidiStatusSystemCommand
@property (readonly,nonatomic) AKMidiStatus status;
/// The MIDI system command this event is for, or None
@property (readonly,nonatomic) AKMidiSystemCommand command;

/// Channel number (1..16), or 0 if this MIDI event doesn't have a channel number.
@property (readonly,nonatomic) UInt8 channel;
/// Additional 7-bits of data (0..127)
@property (readonly,nonatomic) UInt8 data1, data2;
/// Composite value using data1 as LSB, data2 as MSB (14 bits of data)
@property (readonly,nonatomic) UInt16 data;

/// The length in bytes for this MIDI message (1 to 3 bytes)
@property (readonly,nonatomic) UInt8 length;
/// The MIDI message data bytes as NSData.
@property (readonly,nonatomic) NSData *bytes;

/// Create a MIDI status message.
/// @param status The status number (4 bits)
/// @param channel The channel number (1..16)
/// @param d1 The first data byte (7 bits)
/// @param d2 The second data byte (7 bits)
- (instancetype)initWithStatus:(AKMidiStatus)status channel:(UInt8)channel data1:(UInt8)d1 data2:(UInt8)d2;

/// Create a MIDI system command message.
/// @param command The command number (8 bits, 0xFx)
/// @param d1 The first data byte (7 bits)
/// @param d2 The second data byte (7 bits)
- (instancetype)initWithSystemCommand:(AKMidiSystemCommand)command data1:(UInt8)d1 data2:(UInt8)d2;

/// Create from a CoreMIDI packet.
/// @param packet The 3-byte buffer containing the MIDI bytes.
- (instancetype)initWithMIDIPacket:(const UInt8 [3])packet;

/// Create from a NSData object.
/// @param data A NSData object containing the MIDI data (up to 3 bytes)
- (instancetype)initWithData:(NSData *)data;

/// Parse multiple events, a single MIDIPacket might return several discrete events.
/// @param packet A MIDIPacket structure received from CoreMIDI.
+ (NSArray<AKMidiEvent *> *)midiEventsFromPacket:(const MIDIPacket *)packet;

/// Copy the bytes from the MIDI message to a provided buffer.
/// @param ptr The address of a buffer to copy the bytes to, must be at least `length` bytes long.
- (void)copyBytes:(void *)ptr;

/// Post a notification describing the MIDI event. Returns YES if a notification was actually posted.
- (BOOL)postNotification;


#pragma mark - Convenience Constructors

/// Create a MIDI "note on" event.
/// @param note The MIDI note number.
/// @param channel The channel number (1..16)
/// @param velocity The velocity of the event (0..127)
+ (instancetype)eventWithNoteOn:(UInt8)note channel:(UInt8)channel velocity:(UInt8)velocity;

/// Create a MIDI "note off" event.
/// @param note The MIDI note number.
/// @param channel The channel number (1..16)
/// @param velocity The velocity of the event (0..127)
+ (instancetype)eventWithNoteOff:(UInt8)note channel:(UInt8)channel velocity:(UInt8)velocity;

/// Create a MIDI "program change" event.
/// @param program The program number to change to (0..127)
/// @param channel The channel number (1..16)
+ (instancetype)eventWithProgramChange:(UInt8)program channel:(UInt8)channel;

@end
NS_ASSUME_NONNULL_END

