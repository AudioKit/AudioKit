//
//  AKMIDI+Sending+EndpointInfo.swift
//  AudioKit
//
//  Created by dejaWorks - Trevor D, Beydag on 14/06/2020.
//  Copyright © 2020 AudioKit. All rights reserved.
//

import Foundation


// MARK: -  Get/Open/Close Outputs with EndpointInfo object
extension AKMIDI{
    /// Returns all Outputs in EndpointInfo format
    public func outputs()->[EndpointInfo]{
        
        var endpointInfos = destinationInfos
        
        endpointInfos.enumerated().forEach {
            endpointInfos[$0].midiPortRef = portOf(outputInfo: $1)
        }
        
        return endpointInfos
    }
    
    /// Open a MIDI Output port with outputInfo
    ///
    /// - parameter outputInfo: EndpointInfo object which contains; MIDI Unique identifier for a MIDI Input, MIDIEndpointRef
    public func openOutput(outputInfo: EndpointInfo){
        
        let outputUid = outputInfo.midiUniqueID
        
        if outputEndpointPorts[outputInfo] == nil || outputEndpointPorts[outputInfo] == 0 {
            guard let tempPort = MIDIOutputPort(client: client, name: outputPortName) else {
                AKLog("Unable to create MIDIOutputPort", log: OSLog.midi, type: .error)
                return
            }
            //outputPort = tempPort
            outputEndpointPorts[outputInfo] = tempPort
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
    
    
    /// Close a MIDI Output port with outputInfo
    ///
    /// - parameter outputInfo: EndpointInfo object which contains; MIDI Unique identifier for a MIDI Input, MIDIEndpointRef
    public func closeOutput(outputInfo: EndpointInfo){
        let outputUid = outputInfo.midiUniqueID
        let name = destinationName(for: outputUid)
        AKLog("Closing MIDI Output '\(String(describing: name))'", log: OSLog.midi)
        var result = noErr
        if endpoints[outputUid] != nil {
            endpoints.removeValue(forKey: outputUid)
            outputEndpointPorts.removeValue(forKey: outputInfo)
            AKLog("Disconnected \(name) and removed it from endpoints", log: OSLog.midi)
            if endpoints.count == 0 {
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
    
    /// Get the MIDI Input port used for given inputInfo
    ///
    /// - parameter inputInfo: input EndpointInfo
    public func portOf(outputInfo:EndpointInfo)->MIDIPortRef?{
        return outputEndpointPorts[outputInfo]
        ///return outputPort
    }
    
}

// MARK: - Send with EndpointInfo
extension AKMIDI{
    /// Send a Note On Message
    public func sendNoteOnMessage(noteNumber: MIDINoteNumber,
                                  velocity: MIDIVelocity,
                                  channel: MIDIChannel = 0,
                                  endpointInfo:EndpointInfo) {
        let noteCommand: MIDIByte = MIDIByte(0x90) + channel
        let message: [MIDIByte] = [noteCommand, noteNumber, velocity]
        self.sendMessage(message, endpointInfo: endpointInfo)
    }
    
    /// Send a Note Off Message
    public func sendNoteOffMessage(noteNumber: MIDINoteNumber,
                                   velocity: MIDIVelocity,
                                   channel: MIDIChannel = 0,
                                   endpointInfo:EndpointInfo) {
        let noteCommand: MIDIByte = MIDIByte(0x80) + channel
        let message: [MIDIByte] = [noteCommand, noteNumber, velocity]
        self.sendMessage(message, endpointInfo: endpointInfo)
    }
    /// Send Message with data and targeted endpoint
    public func sendMessage(_ data: [MIDIByte],
                            endpointInfo:EndpointInfo,
                            offset: MIDITimeStamp = 0) {

        // Create a buffer that is big enough to hold the data to be sent and
        // all the necessary headers.
        let bufferSize = data.count + sizeOfMIDICombinedHeaders

        // the discussion section of MIDIPacketListAdd states that "The maximum
        // size of a packet list is 65536 bytes." Checking for that limit here.
        if bufferSize > 65_536 {
            AKLog("error sending midi : data array is too large, requires a buffer larger than 65536", log: OSLog.midi, type: .error)
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
                
                let endpoint = endpointInfo.midiEndpointRef
                guard let port = endpointInfo.midiPortRef else {return}
                
                let result = MIDISend(port, endpoint, packetListPointer)
                if result != noErr {
                    AKLog("error sending midi: \(result)", log: OSLog.midi, type: .error)
                }
                
                
                if virtualOutput != 0 {
                    MIDIReceived(virtualOutput, packetListPointer)
                }
            }
        }
    }
}
