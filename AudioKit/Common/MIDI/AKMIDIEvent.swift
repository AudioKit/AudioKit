//
//  AKMIDIEvent.swift
//  AudioKit
//
//  Created by Jeff Cooper, revision history on Github.
//  Copyright © 2017 Aurelius Prochazka. All rights reserved.
//

import Foundation
import CoreMIDI

extension MIDIByte {
    /// This limits the range to be from 0 to 127
    func lower7bits() -> MIDIByte {
        return self & 0x7F
    }

    /// This limits the range to be from 0 to 16
    func lowbit() -> MIDIByte {
        return self & 0xF
    }
}

extension MIDIPacket {
    var isSysex: Bool {
        return data.0 == AKMIDISystemCommand.sysex.rawValue
    }

    var status: AKMIDIStatus? {
        return AKMIDIStatus(rawValue: Int(data.0) >> 4)
    }

    var channel: MIDIChannel {
        return data.0.lowbit()
    }

    var command: AKMIDISystemCommand? {
        return AKMIDISystemCommand(rawValue: data.0)
    }
}

/// A container for the values that define a MIDI event
public struct AKMIDIEvent {

    // MARK: - Properties

    /// Internal data
    public var internalData = [MIDIByte](zeros: 128)

    /// The length in bytes for this MIDI message (1 to 3 bytes)
    var length: MIDIByte?

    /// Status
    public var status: AKMIDIStatus {
        let status = internalData[0] >> 4
        return AKMIDIStatus(rawValue: Int(status))!
    }

    /// System Command
    public var command: AKMIDISystemCommand {
        let status = internalData[0] >> 4
        if status < 15 {
            return .none
        }
        return AKMIDISystemCommand(rawValue: internalData[0])!
    }

    /// MIDI Channel
    public var channel: MIDIChannel? {
        let status = internalData[0] >> 4
        if status < 16 {
            return internalData[0].lowbit()
        }
        return nil
    }

    func statusFrom(rawByte: MIDIByte) -> AKMIDIStatus? {
        return AKMIDIStatus(rawValue: Int(rawByte >> 4))
    }

    func channelFrom(rawByte: MIDIByte) -> MIDIChannel {
        let status = rawByte >> 4
        if status < 16 {
            return MIDIChannel(rawByte.lowbit())
        }
        return 0
    }

    public var noteNumber: MIDINoteNumber? {
        if status == .noteOn || status == .noteOff {
            return MIDINoteNumber(internalData[1])
        }
        return nil
    }
    public var data1: MIDIByte {
        return internalData[1]
    }

    public var data2: MIDIByte {
        return internalData[2]
    }

    var data: MIDIWord {
        if internalData.count < 2 {
            return 0
        }
        let x = MIDIWord(internalData[1])
        let y = MIDIWord(internalData[2]) << 7
        return y + x
    }

    var bytes: Data {
        return Data(bytes: internalData.prefix(3))
    }

    static fileprivate let statusBit: MIDIByte = 0b10000000

    // MARK: - Initialization

    /// Initialize the MIDI Event from a MIDI Packet
    ///
    /// - parameter packet: MIDIPacket that is potentially a known event type
    ///
    init(packet: MIDIPacket) {
        if packet.data.0 < 0xF0 {
            if let status = packet.status {
                fillData(status: status,
                         channel: packet.channel,
                         byte1: packet.data.1,
                         byte2: packet.data.2)
            }
        } else {

            if packet.isSysex {
                internalData = [] //reset internalData
                length = MIDIByte(0)
                //voodoo
                let mirrorData = Mirror(reflecting: packet.data)
                for (_, value) in mirrorData.children {
                    length = 1 + length!
                    internalData.append(MIDIByte(value as! MIDIByte))
                    if value as! MIDIByte == 247 {
                        break
                    }
                }

            } else {
                if let cmd = packet.command {
                    fillData(command: cmd, byte1: packet.data.1, byte2: packet.data.2)
                } else {
                    AKLog("AKMIDISystemCommand failure due to bad data - need to investigate")
                }
            }
        }
        internalData = Array(internalData.prefix(Int(length!)))
    }

    public static func generateFrom(bluetoothData: [MIDIByte]) -> [AKMIDIEvent] {
        //1st byte timestamp coarse will always be > 128
        //2nd byte fine timestamp will always be > 128 - if 2nd message < 128, is continuing sysex
        //3nd < 128 running message - timestamp
        //status byte determines length of message

        var midiEvents: [AKMIDIEvent] = []
        if bluetoothData.count > 1 {
            var rawEvents: [[MIDIByte]] = []
            if bluetoothData[1] < 128 {
                //continuation of sysex from previous packet - handle separately 
                //(probably needs a whole bluetooth midi class so we can see the previous packets)
            } else {
                var rawEvent: [MIDIByte] = []
                var lastStatus: MIDIByte = 0
                var messageJustFinished = false
                for byte in bluetoothData.dropFirst().dropFirst() { //drops first two bytes as these are timestamp bytes
                    if byte >= 128 {
                        //if we have a new status byte or if rawEvent is a real event

                        if messageJustFinished && byte >= 128 {
                            messageJustFinished = false
                            continue
                        }
                        lastStatus = byte
                    } else {
                        if rawEvent.isEmpty {
                            rawEvent.append(lastStatus)
                        }
                    }
                    rawEvent.append(byte) //set the status byte
                    if (rawEvent.count == 3 && lastStatus != AKMIDISystemCommand.sysex.rawValue)
                        || byte == AKMIDISystemCommand.sysexEnd.rawValue {
                        //end of message
                        messageJustFinished = true
                        if !rawEvent.isEmpty {
                            rawEvents.append(rawEvent)
                        }
                        rawEvent = [] //init raw Event
                    }
                }
            }
            for event in rawEvents {
                midiEvents.append(AKMIDIEvent(data: event))
            }
        }//end bluetoothData.count > 0
        return midiEvents
    }

    /// Initialize the MIDI Event from a raw MIDIByte packet (ie. from Bluetooth)
    ///
    /// - Parameters:
    ///   - data:  [MIDIByte] bluetooth packet
    ///
    init(data: [MIDIByte]) {
        if let command = AKMIDISystemCommand(rawValue: data[0]) {
            internalData = []
            //is sys command
            if command == .sysex {
                for byte in data {
                    internalData.append(byte)
                }
                length = MIDIByte(internalData.count)
            } else {
                fillData(command: command, byte1: data[1], byte2: data[2])
            }
        } else if let status = statusFrom(rawByte: data[0]) {
            //is regular midi status
            let channel = channelFrom(rawByte: data[0])
            fillData(status: status, channel: channel, byte1: data[1], byte2: data[2])
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
    init(status: AKMIDIStatus, channel: MIDIChannel, byte1: MIDIByte, byte2: MIDIByte) {
        fillData(status: status, channel: channel, byte1: byte1, byte2: byte2)
    }

    fileprivate mutating func fillData(status: AKMIDIStatus,
                                       channel: MIDIChannel,
                                       byte1: MIDIByte,
                                       byte2: MIDIByte) {
        internalData[0] = MIDIByte(status.rawValue << 4) | MIDIByte(channel.lowbit())
        internalData[1] = byte1.lower7bits()
        internalData[2] = byte2.lower7bits()

        switch status {
        case .controllerChange:
            length = 3
        case .channelAftertouch:
            break
        case .programChange:
            length = 2
        default:
            length = 3
        }
        internalData = Array(internalData.prefix(Int(length!)))
    }

    /// Initialize the MIDI Event from a system command message
    ///
    /// - Parameters:
    ///   - command: MIDI System Command
    ///   - byte1:   First data byte
    ///   - byte2:   Second data byte
    ///
    init(command: AKMIDISystemCommand, byte1: MIDIByte, byte2: MIDIByte) {
        fillData(command: command, byte1: byte1, byte2: byte2)
    }

    fileprivate mutating func fillData(command: AKMIDISystemCommand,
                                       byte1: MIDIByte,
                                       byte2: MIDIByte) {
        internalData[0] = command.rawValue

        switch command {
        case .sysex:
            AKLog("sysex")
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
        internalData = Array(internalData.prefix(Int(length!)))
    }

    // MARK: - Utility constructors for common MIDI events

    /// Determine whether a given byte is the status byte for a MIDI event
    ///
    /// - parameter byte: Byte to test
    ///
    static func isStatusByte(_ byte: MIDIByte) -> Bool {
        return (byte & AKMIDIEvent.statusBit) == AKMIDIEvent.statusBit
    }

    /// Determine whether a given byte is a data byte for a MIDI Event
    ///
    /// - parameter byte: Byte to test
    ///
    static func isDataByte(_ byte: MIDIByte) -> Bool {
        return (byte & AKMIDIEvent.statusBit) == 0
    }

    /// Convert a byte into a MIDI Status
    ///
    /// - parameter byte: Byte to convert
    ///
    static func statusFromValue(_ byte: MIDIByte) -> AKMIDIStatus {
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
    public init(noteOn noteNumber: MIDINoteNumber,
                velocity: MIDIVelocity,
                channel: MIDIChannel) {
      self.init(status: .noteOn,
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
  public init(noteOff noteNumber: MIDINoteNumber,
              velocity: MIDIVelocity,
              channel: MIDIChannel) {
        self.init(status: .noteOff,
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
    public init(programChange data: MIDIByte,
                channel: MIDIChannel) {
      self.init(status: .programChange,
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
    public init(controllerChange controller: MIDIByte,
                value: MIDIByte,
                channel: MIDIChannel) {
      self.init(status: .controllerChange,
                channel: channel,
                byte1: controller,
                byte2: value)
    }

    static public func midiEventsFrom(packetListPointer: UnsafePointer< MIDIPacketList>) -> [AKMIDIEvent] {
        return packetListPointer.pointee.map { AKMIDIEvent(packet: $0) }
    }
}
