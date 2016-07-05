//
//  AKMIDIEvent.swift
//  AudioKit
//
//  Created by Jeff Cooper, revision history on Github.
//  Copyright © 2016 AudioKit. All rights reserved.
//

import Foundation
import CoreMIDI

/// A container for the values that define a MIDI event
public struct AKMIDIEvent {

    // MARK: - Properties

    /// Internal data - defaults to 3 bytes
    var internalData = [UInt8](count: 3, repeatedValue: 0)

    /// The length in bytes for this MIDI message (1 to 3 bytes)
    var length: UInt8?

    /// Status
    var status: AKMIDIStatus {
        let status = internalData[0] >> 4
        return AKMIDIStatus(rawValue: Int(status))!
    }

    /// System Command
    var command: AKMIDISystemCommand {
        let status = internalData[0] >> 4
        if status < 15 {
            return .None
        }
        return AKMIDISystemCommand(rawValue: internalData[0])!
    }

    /// MIDI Channel
    var channel: UInt8 {
        let status = internalData[0] >> 4
        if status < 16 {
            return internalData[0] & 0xF
        }
        return 0
    }

    var data1: UInt8 {
        return internalData[1]
    }

    var data2: UInt8 {
        return internalData[2]
    }

    var data: UInt16 {
        if internalData.count < 2{
            return 0
        }
        let x = UInt16(internalData[1])
        let y = UInt16(internalData[2]) << 7
        return y + x
    }

    var bytes: NSData {
        return NSData(bytes: [internalData[0], internalData[1], internalData[2]] as [UInt8], length: 3)
    }

    static private let statusBit:   UInt8 = 0b10000000
    static private let dataMask:    UInt8 = 0b01111111
    static private let messageMask: UInt8 = 0b01110000
    static private let channelMask: UInt8 = 0b00001111

    // MARK: - Initialization

    /// Initialize the MIDI Event from a MIDI Packet
    ///
    /// - parameter packet: MIDIPacket that is potentially a known event type
    ///
    init(packet: MIDIPacket) {
        if packet.data.0 < 0xF0 {
            let status = AKMIDIStatus(rawValue: Int(packet.data.0) >> 4)
            let channel = UInt8(packet.data.0 & 0xF)
            if let statusExists = status {
                fillData(status: statusExists,
                         channel: channel,
                         byte1: packet.data.1,
                         byte2: packet.data.2)
            }
        } else {
            if isSysex(packet) {
                internalData = [] //reset internalData
                
                //voodoo
                let mirrorData = Mirror(reflecting: data)
                var i = 0
                for (_, value) in mirrorData.children {
                    internalData.append(UInt8(value as! UInt8))
                    i += 1
                    if value as! UInt8 == 247 {
                        break
                    }
                }
            } else {
                fillData(command: AKMIDISystemCommand(rawValue: packet.data.0)!,
                         byte1: packet.data.1,
                         byte2: packet.data.2)
            }
        }
    }

    /// Initialize the MIDI Event from a status message
    ///
    /// - Parameters:
    ///   - status:  MIDI Status
    ///   - channel: Channel on which the event occurs
    ///   - byte1:   First data byte
    ///   - byte2:   Second data byte
    ///
    init(status: AKMIDIStatus, channel: UInt8, byte1: UInt8, byte2: UInt8) {
        fillData(status: status, channel: channel, byte1: byte1, byte2: byte2)
    }

    private mutating func fillData(status status: AKMIDIStatus,
                                          channel: UInt8,
                                          byte1: UInt8,
                                          byte2: UInt8) {
        internalData[0] = UInt8(status.rawValue << 4) | UInt8((channel) & 0xf)
        internalData[1] = byte1 & 0x7F
        internalData[2] = byte2 & 0x7F

        switch status {
        case .ControllerChange:
            if byte1 < AKMIDIControl.DataEntryPlus.rawValue ||
                byte1 == AKMIDIControl.LocalControlOnOff.rawValue {

                length = 3
            } else {
                length = 2
            }
        case .ChannelAftertouch: break
        case .ProgramChange:
            length = 2
        default:
            length = 3
        }
    }

    /// Initialize the MIDI Event from a system command message
    ///
    /// - Parameters:
    ///   - command: MIDI System Command
    ///   - byte1:   First data byte
    ///   - byte2:   Second data byte 
    ///
    init(command: AKMIDISystemCommand, byte1: UInt8, byte2: UInt8) {
        fillData(command: command, byte1: byte1, byte2: byte2)
    }

    private mutating func fillData(command command: AKMIDISystemCommand,
                                           byte1: UInt8,
                                           byte2: UInt8) {
        internalData[0] = command.rawValue
        switch command {
        case .Sysex: break
        case .SongPosition:
            internalData[1] = byte1 & 0x7F
            internalData[2] = byte2 & 0x7F
            length = 3
        case .SongSelect:
            internalData[1] = byte1 & 0x7F
            length = 2
        default:
            length = 1
        }
    }

    // MARK: - Utility constructors for common MIDI events

    /// Determine whether a given byte is the status byte for a MIDI event
    ///
    /// - parameter byte: Byte to test
    ///
    static func isStatusByte(byte: UInt8) -> Bool {
        return (byte & AKMIDIEvent.statusBit) == AKMIDIEvent.statusBit
    }

    /// Determine whether a given byte is a data byte for a MIDI Event
    ///
    /// - parameter byte: Byte to test
    ///
    static func isDataByte(byte: UInt8) -> Bool {
        return (byte & AKMIDIEvent.statusBit) == 0
    }

    /// Convert a byte into a MIDI Status
    ///
    /// - parameter byte: Byte to convert
    ///
    static func statusFromValue(byte: UInt8) -> AKMIDIStatus {
        let status = byte >> 4
        return AKMIDIStatus(rawValue: Int(status))!
    }

    /// Create note on event
    ///
    /// - Parameters:
    ///   - noteNumber: MIDI Note number
    ///   - velocity:   MIDI Note velocity (0-127)
    ///   - channel:    Channel on which the note appears
    ///
    static public func eventWithNoteOn(noteNumber noteNumber: UInt8,
                                                  velocity: UInt8,
                                                  channel: UInt8 ) -> AKMIDIEvent {
        return AKMIDIEvent(status: .NoteOn,
                           channel: channel,
                           byte1: noteNumber,
                           byte2: velocity)
    }

    /// Create note off event
    ///
    /// - Parameters:
    ///   - noteNumber: MIDI Note number
    ///   - velocity:   MIDI Note velocity (0-127)
    ///   - channel:    Channel on which the note appears
    ///
    static public func eventWithNoteOff(noteNumber noteNumber: UInt8,
                                                   velocity: UInt8,
                                                   channel: UInt8) -> AKMIDIEvent {
        return AKMIDIEvent(status: .NoteOff,
                           channel: channel,
                           byte1: noteNumber,
                           byte2: velocity)
    }

    /// Create program change event
    ///
    /// - Parameters:
    ///   - program: Program change byte
    ///   - channel: Channel on which the program change appears
    ///
    static public func eventWithProgramChange(program: UInt8,
                                              channel: UInt8) -> AKMIDIEvent {
        return AKMIDIEvent(status: .ProgramChange,
                           channel: channel,
                           byte1: program,
                           byte2: 0)
    }

    /// Create controller event
    ///
    /// - Parameters:
    ///   - controller: Controller number
    ///   - value:      Value of the controller
    ///   - channel:    Channel on which the controller value has changed
    ///
    static public func eventWithController(controller: UInt8,
                                           value: UInt8,
                                           channel: UInt8) -> AKMIDIEvent {
        return AKMIDIEvent(status: .ControllerChange,
                           channel: channel,
                           byte1: controller,
                           byte2: value)
    }

    private func isSysex(packet: MIDIPacket) -> Bool {
        return packet.data.0 == AKMIDISystemCommand.Sysex.rawValue
    }

}
