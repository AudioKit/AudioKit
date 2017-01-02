//
//  AKMIDI+SendingMIDI.swift
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright © 2016 AudioKit. All rights reserved.
//

internal struct MIDIDestinations: Collection {
    typealias Index = Int

    init() { }

    var startIndex: Index {
        return 0
    }

    var endIndex: Index {
        return MIDIGetNumberOfDestinations()
    }

    subscript (index: Index) -> MIDIEndpointRef {
      return MIDIGetDestination(index)
    }

    func index(after index: Index) -> Index {
      return index + 1
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
    public func openOutput(_ namedOutput: String = "") {
        var foundDest = false
        let result = MIDIOutputPortCreate(client, outputPortName, &outputPort)

        if result != noErr {
            AKLog("Error creating MIDI output port : \(result)")
        }
        for (name, endpoint) in zip(destinationNames, MIDIDestinations()) {
            if namedOutput.isEmpty || namedOutput == name {
                AKLog("Found destination at \(name)")
                endpoints[name] = endpoint
                foundDest = true
            }
        }
        if !foundDest {
            AKLog("no midi destination found named \"\(namedOutput)\"")
        }
    }

    /// Send Message with data
    public func sendMessage(_ data: [UInt8]) {
        let packetListPointer: UnsafeMutablePointer<MIDIPacketList> = UnsafeMutablePointer.allocate(capacity: 1)

        var packet: UnsafeMutablePointer<MIDIPacket>? = nil
        packet = MIDIPacketListInit(packetListPointer)
        packet = MIDIPacketListAdd(packetListPointer, 1024, packet!, 0, data.count, data)
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

    /// Send Messsage from midi event data
    public func sendEvent(_ event: AKMIDIEvent) {
        sendMessage(event.internalData)
    }

    /// Send a Note On Message
    public func sendNoteOnMessage(noteNumber: MIDINoteNumber,
                                             velocity: MIDIVelocity,
                                             channel: MIDIChannel = 0) {
        let noteCommand: UInt8 = UInt8(0x90) + UInt8(channel)
        let message: [UInt8] = [noteCommand, UInt8(noteNumber), UInt8(velocity)]
        self.sendMessage(message)
    }

    /// Send a Note Off Message
    public func sendNoteOffMessage(noteNumber: MIDINoteNumber,
                                             velocity: MIDIVelocity,
                                             channel: MIDIChannel = 0) {
        let noteCommand: UInt8 = UInt8(0x80) + UInt8(channel)
        let message: [UInt8] = [noteCommand, UInt8(noteNumber), UInt8(velocity)]
        self.sendMessage(message)
    }

    /// Send a Continuous Controller message
    public func sendControllerMessage(_ control: Int, value: Int, channel: MIDIChannel = 0) {
        let controlCommand: UInt8 = UInt8(0xB0) + UInt8(channel)
        let message: [UInt8] = [controlCommand, UInt8(control), UInt8(value)]
        self.sendMessage(message)
    }

}
