//
//  AKMIDI+SendingMIDI.swift
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright © 2017 Aurelius Prochazka. All rights reserved.
//

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
    /// - parameter namedOutput: String containing the name of the MIDI Input
    ///
    // Destination name (string) can be empty for some hardware device;
    // So optional string is better for checking and targeting the device.
    public func openOutput(_ namedOutput: String? = nil) {
        guard let tempPort = MIDIOutputPort(client: client, name: outputPortName) else {
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
        let packetListPointer: UnsafeMutablePointer<MIDIPacketList> = UnsafeMutablePointer.allocate(capacity: 1)

        var packet = MIDIPacketListInit(packetListPointer)
        packet = MIDIPacketListAdd(packetListPointer, 1_024, packet, 0, data.count, data)
        for endpoint in endpoints.values {
            let result = MIDISend(outputPort, endpoint, packetListPointer)
            if result != noErr {
                AKLog("error sending midi : \(result)")
            }
        }

        if virtualOutput != 0 {
            MIDIReceived(virtualOutput, packetListPointer)
        }

        packetListPointer.deinitialize()
        packetListPointer.deallocate(capacity: 1)//necessary? wish i could do this without the alloc above
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

}
