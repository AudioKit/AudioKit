//
//  AKMIDIEvent.swift
//  AudioKit
//
//  Created by Jeff Cooper, revision history on Github.
//  Copyright © 2016 AudioKit. All rights reserved.
//

import Foundation
import CoreMIDI

extension UInt8 {
    /// This limits the range to be from 0 to 127
    func lower7bits() -> UInt8 {
        return self & 0x7F
    }
    
    /// This limits the range to be from 0 to 16
    func lowbit() -> UInt8 {
        return self & 0xF
    }

}

/// A container for the values that define a MIDI event
public struct AKMIDIEvent {

    // MARK: - Properties

    /// Internal data - defaults to 3 bytes
    var internalData = [UInt8](zeroes: 3)

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
            return .none
        }
        return AKMIDISystemCommand(rawValue: internalData[0])!
    }

    /// MIDI Channel
    var channel: UInt8 {
        let status = internalData[0] >> 4
        if status < 16 {
            return internalData[0].lowbit()
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

    var bytes: Data {
        return Data(bytes: UnsafePointer<UInt8>([internalData[0], internalData[1], internalData[2]] as [UInt8]),
                      count: 3)
    }

    static fileprivate let statusBit: UInt8 = 0b10000000

    // MARK: - Initialization

    /// Initialize the MIDI Event from a MIDI Packet
    ///
    /// - parameter packet: MIDIPacket that is potentially a known event type
    ///
    init(packet: MIDIPacket) {
        if packet.data.0 < 0xF0 {
            let status = AKMIDIStatus(rawValue: Int(packet.data.0) >> 4)
            let channel = UInt8(packet.data.0.lowbit())
            
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
                if let cmd = AKMIDISystemCommand(rawValue: packet.data.0) {
                    fillData(command: cmd, byte1: packet.data.1, byte2: packet.data.2)
                } else {
                    print("AKMIDISystemCommand failure due to bad data - need to investigate")
                }
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

    fileprivate mutating func fillData(status: AKMIDIStatus,
                                          channel: UInt8,
                                          byte1: UInt8,
                                          byte2: UInt8) {
        internalData[0] = UInt8(status.rawValue << 4) | UInt8((channel).lowbit())
        internalData[1] = byte1.lower7bits()
        internalData[2] = byte2.lower7bits()

        switch status {
        case .controllerChange:
            if byte1 < AKMIDIControl.dataEntryPlus.rawValue ||
                byte1 == AKMIDIControl.localControlOnOff.rawValue {

                length = 3
            } else {
                length = 2
            }
        case .channelAftertouch: break
        case .programChange:
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

    fileprivate mutating func fillData(command: AKMIDISystemCommand,
                                           byte1: UInt8,
                                           byte2: UInt8) {
        internalData[0] = command.rawValue
        
        switch command {
        case .sysex:
            break
        case .songPosition:
            internalData[1] = byte1.lower7bits()
            internalData[2] = byte2.lower7bits()
            length = 3
        case .songSelect:
            internalData[1] = byte1.lower7bits()
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
    static func isStatusByte(_ byte: UInt8) -> Bool {
        return (byte & AKMIDIEvent.statusBit) == AKMIDIEvent.statusBit
    }

    /// Determine whether a given byte is a data byte for a MIDI Event
    ///
    /// - parameter byte: Byte to test
    ///
    static func isDataByte(_ byte: UInt8) -> Bool {
        return (byte & AKMIDIEvent.statusBit) == 0
    }

    /// Convert a byte into a MIDI Status
    ///
    /// - parameter byte: Byte to convert
    ///
    static func statusFromValue(_ byte: UInt8) -> AKMIDIStatus {
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
    static public func noteOn(noteNumber: UInt8,
                                         velocity: UInt8,
                                         channel: UInt8 ) -> AKMIDIEvent {
        return AKMIDIEvent(status: .noteOn,
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
    static public func noteOff(noteNumber: UInt8,
                                          velocity: UInt8,
                                          channel: UInt8) -> AKMIDIEvent {
        return AKMIDIEvent(status: .noteOff,
                           channel: channel,
                           byte1: noteNumber,
                           byte2: velocity)
    }

    /// Create program change event
    ///
    /// - Parameters:
    ///   - data: Program change byte
    ///   - channel: Channel on which the program change appears
    ///
    static public func programChange(data: UInt8,
                                          channel: UInt8) -> AKMIDIEvent {
        return AKMIDIEvent(status: .programChange,
                           channel: channel,
                           byte1: data,
                           byte2: 0)
    }

    /// Create controller event
    ///
    /// - Parameters:
    ///   - controller: Controller number
    ///   - value:      Value of the controller
    ///   - channel:    Channel on which the controller value has changed
    ///
    static public func controllerChange(controller: UInt8,
                                                   value: UInt8,
                                                   channel: UInt8) -> AKMIDIEvent {
        return AKMIDIEvent(status: .controllerChange,
                           channel: channel,
                           byte1: controller,
                           byte2: value)
    }

    fileprivate func isSysex(_ packet: MIDIPacket) -> Bool {
        return packet.data.0 == AKMIDISystemCommand.sysex.rawValue
    }

}
