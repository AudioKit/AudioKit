//
//  AKMIDI+Receiving+EndpointInfo.swift
//  AudioKit
//
//  Created by dejaWorks - Trevor D, Beydag on 14/06/2020.
//  Copyright © 2020 AudioKit. All rights reserved.
//

import Foundation


// MARK: -  Get/Open/Close Inputs with EndpointInfo object
extension AKMIDI{
    
    /// Returns all Inputs in EndpointInfo format
    public func inputs()->[EndpointInfo]{
        
        var endpointInfos = inputInfos
        
        endpointInfos.enumerated().forEach {
            endpointInfos[$0].midiPortRef = portOf(inputInfo: $1)
        }
        
        return endpointInfos
    }
    
    /// Open a MIDI Input port with inputInfo
    ///
    /// - parameter inputInfo: EndpointInfo object which contains; MIDI Unique identifier for a MIDI Input, MIDIEndpointRef
    public func openInput(inputInfo: EndpointInfo){
        let inputUID = inputInfo.midiUniqueID
        
        for (uid, src) in zip(inputUIDs, MIDISources()) {
            if inputUID == 0 || inputUID == uid {
                inputPorts[inputUID] = MIDIPortRef()
                
                if var port = inputPorts[inputUID] {
                    
                    let result = MIDIInputPortCreateWithBlock(client, inputPortName, &port) { packetList, _ in
                        var packetCount = 1
                        for packet in packetList.pointee {
                            // a CoreMIDI packet may contain multiple MIDI events -
                            // treat it like an array of events that can be transformed
                            let events = [AKMIDIEvent](packet) //uses MIDIPacketeList makeIterator
                            let transformedMIDIEventList = self.transformMIDIEventList(events)
                            // Note: incomplete sysex packets will not have a status
                            for transformedEvent in transformedMIDIEventList where transformedEvent.status != nil
                                || transformedEvent.command != nil {
                                    self.handleMIDIMessage(transformedEvent, fromInput: inputUID)
                            }
                            packetCount += 1
                        }
                    }
                    
                    if result != noErr {
                        AKLog("Error creating MIDI Input Port: \(result)")
                    }
                    
                    MIDIPortConnectSource(port, src, nil)
                    inputPorts[inputUID] = port
                    endpoints[inputUID] = src
                    
                    inputEndpointPorts[inputUID] = port
                }
            }
        }
    }
    
    /// Close a MIDI Input port with inputInfo
    ///
    /// - parameter inputInfo: EndpointInfo object which contains; MIDI Unique identifier for a MIDI Input, MIDIEndpointRef
    public func closeInput(inputInfo: EndpointInfo){
        
        let inputUID = inputInfo.midiUniqueID
        
        guard let name = inputName(for: inputUID) else {
            AKLog("Trying to close midi input \(inputUID), but no name was found", log: OSLog.midi)
            return
        }
        AKLog("Closing MIDI Input '\(name)'", log: OSLog.midi)
        var result = noErr
        for uid in inputPorts.keys {
            if inputUID == 0 || uid == inputUID {
                if let port = inputPorts[uid], let endpoint = endpoints[uid] {
                    result = MIDIPortDisconnectSource(port, endpoint)
                    if result == noErr {
                        endpoints.removeValue(forKey: uid)
                        inputPorts.removeValue(forKey: uid)
                        inputEndpointPorts.removeValue(forKey: inputUID)
                        AKLog("Disconnected \(name) and removed it from endpoints and input ports", log: OSLog.midi)
                    } else {
                        AKLog("Error disconnecting MIDI port: \(result)", log: OSLog.midi, type: .error)
                    }
                    result = MIDIPortDispose(port)
                    if result == noErr {
                        AKLog("Disposed \(name)", log: OSLog.midi)
                    } else {
                        AKLog("Error displosing  MIDI port: \(result)", log: OSLog.midi, type: .error)
                    }
                }
            }
        }
    }
    
    /// Get the MIDI Input port used for given inputInfo
    ///
    /// - parameter inputInfo: input EndpointInfo
    public func portOf(inputInfo:EndpointInfo)->MIDIPortRef?{
        let p = inputEndpointPorts[inputInfo.midiUniqueID]
        print("input MIDIPortRef: \(String(describing: p))")

        return p
    }
}
