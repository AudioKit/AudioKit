// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

#if !os(tvOS)

import os.log
import AVFoundation

private let sizeOfMIDIPacketList = MemoryLayout<MIDIPacketList>.size
private let sizeOfMIDIPacket = MemoryLayout<MIDIPacket>.size

/// The `MIDIPacketList` struct consists of two fields, numPackets(`UInt32`) and
/// packet(an Array of 1 instance of `MIDIPacket`). The packet is supposed to be a "An open-ended
/// array of variable-length MIDIPackets." but for convenience it is instaciated with
/// one instance of a `MIDIPacket`. To figure out the size of the header portion of this struct,
/// we can get the size of a UInt32, or subtract the size of a single packet from the size of a
/// packet list. I opted for the latter.
private let sizeOfMIDIPacketListHeader = sizeOfMIDIPacketList - sizeOfMIDIPacket

/// The MIDIPacket struct consists of a timestamp (`MIDITimeStamp`), a length (`UInt16`) and
/// data (an Array of 256 instances of `Byte`). The data field is supposed to be a "A variable-length
/// stream of MIDI messages." but for convenience it is instaciated as 256 bytes. To figure out the
/// size of the header portion of this struct, we can add the size of the `timestamp` and `length`
/// fields, or subtract the size of the 256 `Byte`s from the size of the whole packet. I opted for
/// the former.
private let sizeOfMIDIPacketHeader = MemoryLayout<MIDITimeStamp>.size + MemoryLayout<UInt16>.size
private let sizeOfMIDICombinedHeaders = sizeOfMIDIPacketListHeader + sizeOfMIDIPacketHeader

func MIDIOutputPort(client: MIDIClientRef, name: CFString) -> MIDIPortRef? {
    var port: MIDIPortRef = 0
    guard MIDIOutputPortCreate(client, name, &port) == noErr else {
        return nil
    }
    return port
}

internal extension Collection where Index == Int {
    var startIndex: Index {
        return 0
    }

    func index(after index: Index) -> Index {
        return index + 1
    }
}

internal struct MIDIDestinations: Collection {
    typealias Index = Int
    typealias Element = MIDIEndpointRef

    init() { }

    var endIndex: Index {
        return MIDIGetNumberOfDestinations()
    }

    subscript (index: Index) -> Element {
        return MIDIGetDestination(index)
    }
}

extension Collection where Iterator.Element == MIDIEndpointRef {
    var names: [String] {
        return map {
            getMIDIObjectStringProperty(ref: $0, property: kMIDIPropertyName)
        }
    }

    var uniqueIds: [MIDIUniqueID] {
        return map {
            getMIDIObjectIntegerProperty(ref: $0, property: kMIDIPropertyUniqueID)
        }
    }
}

internal func getMIDIObjectStringProperty(ref: MIDIObjectRef, property: CFString) -> String {
    var string: Unmanaged<CFString>?
    MIDIObjectGetStringProperty(ref, property, &string)
    if let returnString = string?.takeRetainedValue() {
        return returnString as String
    } else {
        return ""
    }
}

internal func getMIDIObjectIntegerProperty(ref: MIDIObjectRef, property: CFString) -> Int32 {
    var result: Int32 = 0
    MIDIObjectGetIntegerProperty(ref, property, &result)
    return result
}

extension AKMIDI {

    /// Array of destination unique ids
    public var destinationUIDs: [MIDIUniqueID] {
        return MIDIDestinations().uniqueIds
    }

    /// Array of destination names
    public var destinationNames: [String] {
        return MIDIDestinations().names
    }

    /// Lookup a destination name from its unique id
    ///
    /// - Parameter forUid: unique id for a destination
    /// - Returns: name of destination or "Unknown"
    ///
    public func destinationName(for destUid: MIDIUniqueID) -> String {
        let name: String = zip(destinationNames, destinationUIDs).first { (arg: (String, MIDIUniqueID)) -> Bool in
                let (_, uid) = arg
                return destUid == uid
        }.map { (arg) -> String in
                let (name, _) = arg
                return name
        } ?? "Unknown"
        return name
    }

    /// Look up the unique id for a destination index
    ///
    /// - Parameter outputIndex: index of destination
    /// - Returns: unique identifier for the port
    ///
    public func uidForDestinationAtIndex(_ outputIndex: Int = 0) -> MIDIUniqueID {
        let endpoint: MIDIEndpointRef = MIDIDestinations()[outputIndex]
        let uid = getMIDIObjectIntegerProperty(ref: endpoint, property: kMIDIPropertyUniqueID)
        return uid
    }

    /// Open a MIDI Output Port by name
    ///
    /// - Parameter name: String containing the name of the MIDI Output
    ///
    @available(*, deprecated, message: "Try to not use names any more because they are not unique across devices")
    public func openOutput(name: String) {
        guard let index = destinationNames.firstIndex(of: name) else {
            openOutput(uid: 0)
            return
        }
        let uid = uidForDestinationAtIndex(index)
        openOutput(uid: uid)
    }

    /// Handle the acceptable default case of no parameter without causing a
    /// deprecation warning
    public func openOutput() {
        openOutput(uid: 0)
    }

    /// Open a MIDI Output Port by index
    ///
    /// - Parameter outputIndex: Index of destination endpoint
    ///
    public func openOutput(index outputIndex: Int) {
        guard outputIndex < destinationNames.count else {
            return
        }
        let uid = uidForDestinationAtIndex(outputIndex)
        openOutput(uid: uid)
    }

    ///
    /// Open a MIDI Output Port
    ///
    /// - parameter outputUid: Unique id of the MIDI Output
    ///
    public func openOutput(uid outputUid: MIDIUniqueID) {
        if outputPort == 0 {
            guard let tempPort = MIDIOutputPort(client: client, name: outputPortName) else {
                AKLog("Unable to create MIDIOutputPort", log: OSLog.midi, type: .error)
                return
            }
            outputPort = tempPort
        }

        let destinations = MIDIDestinations()

        // To get all endpoints; and set in endpoints array (mapping without condition)
        if outputUid == 0 {
            _ = zip(destinationUIDs, destinations).map {
                endpoints[$0] = $1
            }
        } else {
            // To get only [the FIRST] endpoint with name provided in output (conditional mapping)
            _ = zip(destinationUIDs, destinations).first { (arg: (MIDIUniqueID, MIDIDestinations.Element)) -> Bool in
                    let (uid, _) = arg
                    return outputUid == uid
            }.map {
                    endpoints[$0] = $1
            }
        }
    }

    /// Close a MIDI Output port by name
    ///
    /// - Parameter name: Name of port to close.
    ///
    public func closeOutput(name: String = "") {
        guard let index = destinationNames.firstIndex(of: name) else {
            return
        }
        let uid = uidForDestinationAtIndex(index)
        closeOutput(uid: uid)
    }

    /// Close a MIDI Output port by index
    ///
    /// - Parameter index: Index of destination port name
    ///
    public func closeOutput(index outputIndex: Int) {
        guard outputIndex < destinationNames.count else {
            return
        }
        let uid = uidForDestinationAtIndex(outputIndex)
        closeOutput(uid: uid)
    }

    /// Close a MIDI Output port
    ///
    /// - parameter inputName: Unique id of the MIDI Output
    ///
    public func closeOutput(uid outputUid: MIDIUniqueID) {
        let name = destinationName(for: outputUid)
        AKLog("Closing MIDI Output '\(String(describing: name))'", log: OSLog.midi)
        var result = noErr
        if endpoints[outputUid] != nil {
            endpoints.removeValue(forKey: outputUid)
            AKLog("Disconnected \(name) and removed it from endpoints", log: OSLog.midi)
            if endpoints.isEmpty {
                // if there are no more endpoints, dispose of midi output port
                result = MIDIPortDispose(outputPort)
                if result == noErr {
                    AKLog("Disposed MIDI Output port", log: OSLog.midi)
                } else {
                    AKLog("Error disposing  MIDI Output port: \(result)", log: OSLog.midi, type: .error)
                }
                outputPort = 0
            }
        }
    }

    /// Send Message with data
    public func sendMessage(_ data: [MIDIByte], offset: MIDITimeStamp = 0) {

        // Create a buffer that is big enough to hold the data to be sent and
        // all the necessary headers.
        let bufferSize = data.count + sizeOfMIDICombinedHeaders

        // the discussion section of MIDIPacketListAdd states that "The maximum
        // size of a packet list is 65536 bytes." Checking for that limit here.
        if bufferSize > 65_536 {
            AKLog("error sending midi : data array is too large, requires a buffer larger than 65536",
                  log: OSLog.midi,
                  type: .error)
            return
        }

        var buffer = Data(count: bufferSize)

        // Use Data (a.k.a NSData) to create a block where we have access to a
        // pointer where we can create the packetlist and send it. No need for
        // explicit alloc and dealloc.
        buffer.withUnsafeMutableBytes { (ptr: UnsafeMutableRawBufferPointer) -> Void in
            if let packetListPointer = ptr.bindMemory(to: MIDIPacketList.self).baseAddress {

                let packet = MIDIPacketListInit(packetListPointer)
                let nextPacket: UnsafeMutablePointer<MIDIPacket>? =
                    MIDIPacketListAdd(packetListPointer, bufferSize, packet, offset, data.count, data)

                // I would prefer stronger error handling here, perhaps throwing
                // to force the app developer to handle the error.
                if nextPacket == nil {
                    AKLog("error sending midi: Failed to add packet to packet list.", log: OSLog.midi, type: .error)
                    return
                }

                for endpoint in endpoints.values {
                    let result = MIDISend(outputPort, endpoint, packetListPointer)
                    if result != noErr {
                        AKLog("error sending midi: \(result)", log: OSLog.midi, type: .error)
                    }
                }

                if virtualOutput != 0 {
                    MIDIReceived(virtualOutput, packetListPointer)
                }
            }
        }
    }

    /// Clear MIDI destinations
    public func clearEndpoints() {
        endpoints.removeAll()
    }

    /// Send Messsage from MIDI event data
    public func sendEvent(_ event: AKMIDIEvent) {
        sendMessage(event.data)
    }

    /// Send a Note On Message
    public func sendNoteOnMessage(noteNumber: MIDINoteNumber,
                                  velocity: MIDIVelocity,
                                  channel: MIDIChannel = 0) {
        let noteCommand: MIDIByte = MIDIByte(0x90) + channel
        let message: [MIDIByte] = [noteCommand, noteNumber, velocity]
        self.sendMessage(message)
    }

    /// Send a Note Off Message
    public func sendNoteOffMessage(noteNumber: MIDINoteNumber,
                                   velocity: MIDIVelocity,
                                   channel: MIDIChannel = 0) {
        let noteCommand: MIDIByte = MIDIByte(0x80) + channel
        let message: [MIDIByte] = [noteCommand, noteNumber, velocity]
        self.sendMessage(message)
    }

    /// Send a Continuous Controller message
    public func sendControllerMessage(_ control: MIDIByte, value: MIDIByte, channel: MIDIChannel = 0) {
        let controlCommand: MIDIByte = MIDIByte(0xB0) + channel
        let message: [MIDIByte] = [controlCommand, control, value]
        self.sendMessage(message)
    }

    /// Send a pitch bend message.
    ///
    /// - Parameters:
    ///   - value: Value of pitch shifting between 0 and 16383. Send 8192 for no pitch bending.
    ///   - channel: Channel you want to send pitch bend message. Defaults 0.
    public func sendPitchBendMessage(value: UInt16, channel: MIDIChannel = 0) {
        let pitchCommand = MIDIByte(0xE0) + channel
        let mask: UInt16 = 0x007F
        let byte1 = MIDIByte(value & mask) // MSB, bit shift right 7
        let byte2 = MIDIByte((value & (mask << 7)) >> 7) // LSB, mask of 127
        let message: [MIDIByte] = [pitchCommand, byte1, byte2]
        self.sendMessage(message)
    }

    // MARK: - Expand api to include MIDITimeStamp

    // MARK: - Send a message with MIDITimeStamp
    public func sendNoteOnMessageWithTime(noteNumber: MIDINoteNumber,
                                          velocity: MIDIVelocity,
                                          channel: MIDIChannel = 0,
                                          time: MIDITimeStamp = 0) {
        let noteCommand: UInt8 = UInt8(0x90) + UInt8(channel)
        let message: [UInt8] = [noteCommand, UInt8(noteNumber), UInt8(velocity)]
        self.sendMessageWithTime(message, time: time)
    }

    /// Send a Note Off Message
    public func sendNoteOffMessageWithTime(noteNumber: MIDINoteNumber,
                                           velocity: MIDIVelocity,
                                           channel: MIDIChannel = 0,
                                           time: MIDITimeStamp = 0) {
        let noteCommand: UInt8 = UInt8(0x80) + UInt8(channel)
        let message: [UInt8] = [noteCommand, UInt8(noteNumber), UInt8(velocity)]
        self.sendMessageWithTime(message, time: time)
    }

    /// Send Message with data
    public func sendMessageWithTime(_ data: [UInt8], time: MIDITimeStamp) {
        let packetListPointer: UnsafeMutablePointer<MIDIPacketList> = UnsafeMutablePointer.allocate(capacity: 1)

        var packet: UnsafeMutablePointer<MIDIPacket> = MIDIPacketListInit(packetListPointer)
        packet = MIDIPacketListAdd(packetListPointer, 1_024, packet, time, data.count, data)

        for endpoint in endpoints.values {
            let result = MIDISend(outputPort, endpoint, packetListPointer)
            if result != noErr {
                AKLog("error sending midi: \(result)", log: OSLog.midi, type: .error)
            }
        }

        if virtualOutput != 0 {
            MIDIReceived(virtualOutput, packetListPointer)
        }
    }

}

#endif
