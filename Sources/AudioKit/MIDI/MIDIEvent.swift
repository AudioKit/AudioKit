// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

#if !os(tvOS)
import CoreMIDI
import os.log

/// A container for the values that define a MIDI event
public struct MIDIEvent: MIDIMessage {

    /// Internal data
    public var data = [MIDIByte]()

    /// Position data - used for events parsed from a MIDI file
    public var positionInBeats: Double?

    /// Offset within a buffer. Used mostly in receiving events from an au sequencer
    public var offset: MIDITimeStamp?

    /// TimeStamp from packet. Used mostly in receiving packets live
    public var timeStamp: MIDITimeStamp?

    /// Pretty printout
    public var description: String {
        if let status = self.status {
            return "\(status.description) - \(data)"
        }
        if let command = self.command {
            return "\(command.description) - \(data)"
        }
        if let meta = MIDICustomMetaEvent(data: data) {
            return "\(meta.description) - \(data)"
        }
        return "Unhandled event \(data)"
    }

    #if swift(>=5.2)
    // This method CRASHES the LLVM compiler with Swift version 5.1 and "Build Libraries for Distribution" turned on
    /// Internal MIDIByte-sized packets - in development / not used yet
    public var internalPackets: [[MIDIByte]] {
        var splitData = [[MIDIByte]]()
        let byteLimit = Int(data.count / 256)
        for i in 0...byteLimit {
            let arrayStart = i * 256
            let arrayEnd: Int = min(Int(arrayStart + 256), Int(data.count))
            let tempData = Array(data[arrayStart..<arrayEnd])
            splitData.append(tempData)
        }
        return splitData
    }
    #endif

    /// The length in bytes for this MIDI message (1 to 3 bytes)
    public var length: Int {
        return data.count
    }

    /// Status
    public var status: MIDIStatus? {
        if let statusByte = data.first {
            return MIDIStatus(byte: statusByte)
        }
        return nil
    }

    /// System Command
    public var command: MIDISystemCommand? {
        // FIXME: Improve this if statement to catch valid system reset commands (0xFF)
        // but ignore meta events (0xFF, 0x..., 0x..., etc)
        if let statusByte = data.first, statusByte != MIDISystemCommand.sysReset.rawValue {
            return MIDISystemCommand(rawValue: statusByte)
        }
        return nil
    }

    /// MIDI Channel
    public var channel: MIDIChannel? {
        return status?.channel
    }

    /// MIDI Note Number
    public var noteNumber: MIDINoteNumber? {
        if status?.type == .noteOn || status?.type == .noteOff, data.count > 1 {
            return MIDINoteNumber(data[1])
        }
        return nil
    }

    /// Representation of the pitchBend data as a MIDI word 0-16383
    public var pitchbendAmount: MIDIWord? {
        if status?.type == .pitchWheel {
            if data.count > 2 {
                return MIDIWord(byte1: data[1], byte2: data[2])
            }
        }
        return nil
    }

    // MARK: - Initialization

    /// Initialize the MIDI Event from a MIDI Packet
    ///
    /// - parameter packet: MIDIPacket that is potentially a known event type
    ///
    public init(packet: MIDIPacket) {
        timeStamp = packet.timeStamp
        // MARK: we currently assume this is one midi event could be any number of events

        let isSystemCommand = packet.isSystemCommand
        if isSystemCommand {
            let systemCommand = packet.systemCommand
            let length = systemCommand?.length
            if systemCommand == .sysEx {
                data = [] // reset internal data

                // voodoo to convert packet 256 element tuple to byte arrays
                if let midiBytes = MIDIEvent.decode(packet: packet) {
                    // flag midi system that a sysEx packet has started so it can gather bytes until the end
                    MIDI.sharedInstance.startReceivingSysEx(with: midiBytes)
                    data += midiBytes
                    if let sysExEndIndex = midiBytes.firstIndex(of: MIDISystemCommand.sysExEnd.byte) {
                        let length = sysExEndIndex + 1
                        data = Array(data.prefix(length))
                        MIDI.sharedInstance.stopReceivingSysEx()
                    } else {
                        data.removeAll()
                    }
                }
            } else if length == 1 {
                let bytes = [packet.data.0]
                data = bytes
            } else if length == 2 {
                let bytes = [packet.data.0, packet.data.2]
                data = bytes
            } else if length == 3 {
                let bytes = [packet.data.0, packet.data.1, packet.data.2]
                data = bytes
            }
        } else {
            let bytes = [packet.data.0, packet.data.1, packet.data.2]
            data = bytes
        }
    }

    init?(fileEvent event: MIDIFileChunkEvent) {
        guard
            event.computedData.isNotEmpty,
            event.computedData[0] != 0xFF //would be a meta event, not realtime system reset message
        else {
            return nil
        }
        self = MIDIEvent(data: event.computedData)
        if event.timeFormat == .ticksPerBeat {
            positionInBeats = event.position
        }
    }

    /// Initialize the MIDI Event from a raw MIDIByte packet (ie. from Bluetooth)
    ///
    /// - Parameters:
    ///   - data:  [MIDIByte] bluetooth packet
    ///
    public init(data: [MIDIByte], timeStamp: MIDITimeStamp? = nil) {
        self.timeStamp = timeStamp
        if MIDI.sharedInstance.isReceivingSysEx {
            if let sysExEndIndex = data.firstIndex(of: MIDISystemCommand.sysExEnd.rawValue) {
                self.data = Array(data[0...sysExEndIndex])
            }
        } else if let command = MIDISystemCommand(rawValue: data[0]) {
            self.data = []
            // is sys command
            if command == .sysEx {
                for byte in data {
                    self.data.append(byte)
                }
            } else {
                fillData(command: command, bytes: Array(data.suffix(from: 1)))
            }
        } else if let status = MIDIStatusType.from(byte: data[0]) {
            // is regular MIDI status
            let channel = data[0].lowBit
            fillData(status: status, channel: channel, bytes: Array(data.dropFirst()))
        } else if let metaType = MIDICustomMetaEventType(rawValue: data[0]) {
            Log("is meta event \(metaType.description)", log: OSLog.midi)
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
    init(status: MIDIStatusType, channel: MIDIChannel, byte1: MIDIByte, byte2: MIDIByte) {
        let data = [byte1, byte2]
        fillData(status: status, channel: channel, bytes: data)
    }

    fileprivate mutating func fillData(status: MIDIStatusType,
                                       channel: MIDIChannel,
                                       bytes: [MIDIByte]) {
        data = []
        data.append(MIDIStatus(type: status, channel: channel).byte)
        for byte in bytes {
            data.append(byte.lower7bits())
        }
    }

    /// Initialize the MIDI Event from a system command message
    ///
    /// - Parameters:
    ///   - command: MIDI System Command
    ///   - byte1:   First data byte
    ///   - byte2:   Second data byte
    ///
    init(command: MIDISystemCommand, byte1: MIDIByte, byte2: MIDIByte? = nil) {
        var data = [byte1]
        if let byte2 = byte2 {
            data.append(byte2)
        }
        fillData(command: command, bytes: data)
    }

    fileprivate mutating func fillData(command: MIDISystemCommand,
                                       bytes: [MIDIByte]) {
        data.removeAll()
        data.append(command.byte)

        for byte in bytes {
            data.append(byte)
        }
    }

    // MARK: - Utility constructors for common MIDI events

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
        self.init(data: [MIDIStatus(type: .noteOn, channel: channel).byte, noteNumber, velocity])
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
        self.init(data: [MIDIStatus(type: .noteOff, channel: channel).byte, noteNumber, velocity])
    }

    /// Create program change event
    ///
    /// - Parameters:
    ///   - data: Program change byte
    ///   - channel: Channel on which the program change appears
    ///
    public init(programChange data: MIDIByte,
                channel: MIDIChannel) {
        self.init(data: [MIDIStatus(type: .programChange, channel: channel).byte, data])
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
        self.init(data: [MIDIStatus(type: .controllerChange, channel: channel).byte, controller, value])
    }

    /// Array of MIDI events from a MIDI packet list poionter
    public static func midiEventsFrom(packetListPointer: UnsafePointer<MIDIPacketList>) -> [MIDIEvent] {
        return packetListPointer.pointee.map { MIDIEvent(packet: $0) }
    }

    static func appendIncomingSysEx(packet: MIDIPacket) -> MIDIEvent? {
        if let midiBytes = MIDIEvent.decode(packet: packet) {
            MIDI.sharedInstance.incomingSysEx += midiBytes
            if midiBytes.contains(MIDISystemCommand.sysExEnd.rawValue) {
                let sysExEvent = MIDIEvent(data: MIDI.sharedInstance.incomingSysEx, timeStamp: packet.timeStamp)
                MIDI.sharedInstance.stopReceivingSysEx()
                return sysExEvent
            }
        }
        return nil
    }

    /// Generate array of MIDI events from Bluetooth data
    public static func generateFrom(bluetoothData: [MIDIByte]) -> [MIDIEvent] {
        //1st byte timestamp coarse will always be > 128
        //2nd byte fine timestamp will always be > 128 - if 2nd message < 128, is continuing sysEx
        //3nd < 128 running message - timestamp
        //status byte determines length of message

        var midiEvents: [MIDIEvent] = []
        if bluetoothData.count > 1 {
            var rawEvents: [[MIDIByte]] = []
            if bluetoothData[1] < 128 {
                //continuation of SysEx from previous packet - handle separately
                //(probably needs a whole bluetooth MIDI class so we can see the previous packets)
            } else {
                var rawEvent: [MIDIByte] = []
                var lastStatus: MIDIByte = 0
                var messageJustFinished = false

                // drops first two bytes as these are timestamp bytes
                for byte in bluetoothData.dropFirst().dropFirst() {
                    if byte >= 128 {
                        // if we have a new status byte or if rawEvent is a real event

                        if messageJustFinished, byte >= 128 {
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
                    if (rawEvent.count == 3 && lastStatus != MIDISystemCommand.sysEx.rawValue)
                        || byte == MIDISystemCommand.sysExEnd.rawValue {
                        //end of message
                        messageJustFinished = true
                        if rawEvent.isNotEmpty {
                            rawEvents.append(rawEvent)
                        }
                        rawEvent = [] // init raw Event
                    }
                }
            }
            for event in rawEvents {
                midiEvents.append(MIDIEvent(data: event))
            }
        } // end bluetoothData.count > 0
        return midiEvents
    }

    static func decode(packet: MIDIPacket) -> [MIDIByte]? {
        var outBytes = [MIDIByte]()
        var tupleIndex: UInt16 = 0
        let byteCount = packet.length
        let mirrorData = Mirror(reflecting: packet.data)
        for (_, value) in mirrorData.children { // [tupleIndex, outBytes] in
            if tupleIndex < 256 {
                tupleIndex += 1
            }
            if let byte = value as? MIDIByte {
                if tupleIndex <= byteCount {
                    outBytes.append(byte)
                }
            }
        }
        return outBytes
    }
}

#endif
