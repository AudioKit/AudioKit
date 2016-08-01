//
//  AKMIDI+SendingMIDI.swift
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright © 2016 AudioKit. All rights reserved.
//

extension AKMIDI {
    /// Array of destination names
    public var destinationNames: [String] {
        var nameArray = [String]()
        let outputCount = MIDIGetNumberOfDestinations()
        for i in 0 ..< outputCount {
            let destination = MIDIGetDestination(i)
            var endpointName: Unmanaged<CFString>?
            endpointName = nil
            MIDIObjectGetStringProperty(destination, kMIDIPropertyName, &endpointName)
            let endpointNameStr = (endpointName?.takeRetainedValue())! as String
            nameArray.append(endpointNameStr)
        }
        return nameArray
    }
    
    /// Open a MIDI Output Port
    ///
    /// - parameter namedOutput: String containing the name of the MIDI Input
    ///
    public func openOutput(namedOutput: String = "") {
        
        var result = noErr
        
        let outputCount = MIDIGetNumberOfDestinations()
        var foundDest = false
        result = MIDIOutputPortCreate(client, outputPortName, &outputPort)
        
        if result != noErr {
            print("Error creating MIDI output port : \(result)")
        }
        
        for i in 0 ..< outputCount {
            let src = MIDIGetDestination(i)
            var endpointName: Unmanaged<CFString>? = nil
            
            MIDIObjectGetStringProperty(src, kMIDIPropertyName, &endpointName)
            let endpointNameStr = (endpointName?.takeRetainedValue())! as String
            if namedOutput.isEmpty || namedOutput == endpointNameStr {
                print("Found destination at \(endpointNameStr)")
                endpoints[endpointNameStr] = MIDIGetDestination(i)
                foundDest = true
            }
        }
        if !foundDest {
            print("no midi destination found named \"\(namedOutput)\"")
        }
    }
    
    /// Send Message with data
    public func sendMessage(data: [UInt8]) {
        var result = noErr
        let packetListPointer: UnsafeMutablePointer<MIDIPacketList> = UnsafeMutablePointer.alloc(1)
        
        var packet: UnsafeMutablePointer<MIDIPacket> = nil
        packet = MIDIPacketListInit(packetListPointer)
        packet = MIDIPacketListAdd(packetListPointer, 1024, packet, 0, data.count, data)
        for endpointName in endpoints.keys {
            if let endpoint = endpoints[endpointName] {
                result = MIDISend(outputPort, endpoint, packetListPointer)
                if result != noErr {
                    print("error sending midi : \(result)")
                }
            }
        }
        
        if virtualOutput != 0 {
            MIDIReceived(virtualOutput, packetListPointer)
        }
        
        packetListPointer.destroy()
        packetListPointer.dealloc(1)//necessary? wish i could do this without the alloc above
    }
    
    /// Send Messsage from midi event data
    public func sendEvent(event: AKMIDIEvent) {
        sendMessage(event.internalData)
    }
    
    /// Send a Note On Message
    public func sendNoteOnMessage(noteNumber noteNumber: MIDINoteNumber,
                                             velocity: MIDIVelocity,
                                             channel: MIDIChannel = 0) {
        let noteCommand: UInt8 = UInt8(0x90) + UInt8(channel)
        let message: [UInt8] = [noteCommand, UInt8(noteNumber), UInt8(velocity)]
        self.sendMessage(message)
    }

    /// Send a Note Off Message
    public func sendNoteOffMessage(noteNumber noteNumber: MIDINoteNumber,
                                             velocity: MIDIVelocity,
                                             channel: MIDIChannel = 0) {
        let noteCommand: UInt8 = UInt8(0x80) + UInt8(channel)
        let message: [UInt8] = [noteCommand, UInt8(noteNumber), UInt8(velocity)]
        self.sendMessage(message)
    }

    /// Send a Continuous Controller message
    public func sendControllerMessage(control: Int, value: Int, channel: MIDIChannel = 0) {
        let controlCommand: UInt8 = UInt8(0xB0) + UInt8(channel)
        let message: [UInt8] = [controlCommand, UInt8(control), UInt8(value)]
        self.sendMessage(message)
    }

}
