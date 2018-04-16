//
//  AKMIDI+SendingMIDI.swift
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright © 2018 AudioKit. All rights reserved.
//

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

internal extension Collection where Index == Int {
    var startIndex: Index {
        return 0
    }

    func index(after index: Index) -> Index {
        return index + 1
    }
}

func MIDIOutputPort(client: MIDIClientRef, name: CFString) -> MIDIPortRef? {
    var port: MIDIPortRef = 0
    guard MIDIOutputPortCreate(client, name, &port) == noErr else {
        return nil
    }
    return port
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
            GetMIDIObjectStringProperty(ref: $0, property: kMIDIPropertyName)
        }
    }
}

extension AKMIDI {
    /// Array of destination names
    public var destinationNames: [String] {
        return MIDIDestinations().names
    }

    /// Open a MIDI Output Port
    ///
    /// Destination name (string) can be empty for some hardware device;
    /// So optional string is better for checking and targeting the device.
    ///
    /// - parameter namedOutput: String containing the name of the MIDI Input
    ///
    public func openOutput(_ namedOutput: String? = nil) {
        guard let tempPort = MIDIOutputPort(client: client, name: outputPortName) else {
            AKLog("Unable to create MIDIOutputPort")
            return
        }
        outputPort = tempPort

        // To get all endpoints; and set in endpoints array (mapping without condition)
        if namedOutput == nil {
            _ = zip(destinationNames, MIDIDestinations()).map {
                endpoints[$0] = $1
            }
        } else {
            // To get only  endpoint with name provided in namedOutput (conditional mapping)
            _ = zip(destinationNames, MIDIDestinations()).first { name, _ in namedOutput! == name }.map {
                endpoints[$0] = $1
            }
        }
    }
    /// Send Message with data
    public func sendMessage(_ data: [MIDIByte]) {

        // Create a buffer that is big enough to hold the data to be sent and
        // all the necessary headers.
        let bufferSize = data.count + sizeOfMIDICombinedHeaders

        // the discussion section of MIDIPacketListAdd states that "The maximum
        // size of a packet list is 65536 bytes." Checking for that limit here.
        if bufferSize > 65_536 {
            AKLog("error sending midi : data array is too large, requires a buffer larger than 65536")
            return
        }

        var buffer = Data(count: bufferSize)

        // Use Data (a.k.a NSData) to create a block where we have access to a
        // pointer where we can create the packetlist and send it. No need for
        // explicit alloc and dealloc.
        buffer.withUnsafeMutableBytes { (packetListPointer: UnsafeMutablePointer<MIDIPacketList>) -> Void in
            let packet = MIDIPacketListInit(packetListPointer)
            let nextPacket: UnsafeMutablePointer<MIDIPacket>? =
                MIDIPacketListAdd(packetListPointer, bufferSize, packet, 0, data.count, data)

            // I would prefer stronger error handling here, perhaps throwing
            // to force the app developer to handle the error.
            if nextPacket == nil {
                AKLog("error sending midi : Failed to add packet to packet list.")
                return
            }

            for endpoint in endpoints.values {
                let result = MIDISend(outputPort, endpoint, packetListPointer)
                if result != noErr {
                    AKLog("error sending midi : \(result)")
                }
            }

            if virtualOutput != 0 {
                MIDIReceived(virtualOutput, packetListPointer)
            }
        }
    }

    /// Clear MIDI destinations
    public func clearEndpoints() {
        endpoints.removeAll()
    }

    /// Send Messsage from MIDI event data
    public func sendEvent(_ event: AKMIDIEvent) {
        sendMessage(event.internalData)
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
}
