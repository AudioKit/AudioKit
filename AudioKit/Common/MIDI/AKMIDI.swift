//
//  AKMIDI.swift
//  AudioKit
//
//  Created by Jeff Cooper, revision history on Github.
//  Copyright © 2016 AudioKit. All rights reserved.
//

import Foundation
import CoreMIDI

/// MIDI input and output handler
///
/// You add midi listeners like this:
/// ```
/// var midiIn = AKMIDI()
/// midi.openInput()
/// midi.addListener(someClass)
/// ```
/// ...where someClass conforms to the AKMIDIListener protocol
///
/// You then implement the methods you need from AKMIDIListener and use the data how you need.
open class AKMIDI {
    
    // MARK: - Properties
    
    /// MIDI Client Reference
    open var client = MIDIClientRef()
    
    /// Array of MIDI In ports
    internal var inputPorts = [String: MIDIPortRef]()
    
    /// Virtual MIDI Input destination
    open var virtualInput = MIDIPortRef()

    /// MIDI Client Name
    fileprivate var clientName: CFString = "MIDI Client" as CFString
    
    /// MIDI In Port Name
    internal var inputPortName: CFString = "MIDI In Port" as CFString
    
    /// MIDI Out Port Reference
    internal var outputPort = MIDIPortRef()

    /// Virtual MIDI output
    internal var virtualOutput = MIDIPortRef()
    
    /// Array of MIDI Endpoints
    internal var endpoints = [String: MIDIEndpointRef]()
    
    /// MIDI Out Port Name
    internal var outputPortName: CFString = "MIDI Out Port" as CFString
    
    /// Array of all listeners
    internal var listeners = [AKMIDIListener]()
    
    // MARK: - Initialization

    /// Initialize the AKMIDI system
    public init() {

        #if os(iOS)
            MIDINetworkSession.default().isEnabled = true
            MIDINetworkSession.default().connectionPolicy =
                MIDINetworkConnectionPolicy.anyone
        #endif
        var result = noErr
        if client == 0 {
            result = MIDIClientCreateWithBlock(clientName, &client, MyMIDINotifyBlock)
            if result != noErr {
                print("Error creating midi client : \(result)")
            }
        }
    }
    
    // MARK: - Virtual MIDI
    
    /// Create set of virtual MIDI ports
    open func createVirtualPorts(_ uniqueId: Int32 = 2000000) {

        destroyVirtualPorts()
        
        var result = noErr
        
        let readBlock: MIDIReadBlock = { packetList, srcConnRefCon in
            for packet in packetList.pointee {
                // a coremidi packet may contain multiple midi events
                for event in packet {
                    self.handleMidiMessage(event)
                }
            }
        }
        
        result = MIDIDestinationCreateWithBlock(client, clientName, &virtualInput, readBlock)
        
        if result == noErr {
            MIDIObjectSetIntegerProperty(virtualInput, kMIDIPropertyUniqueID, uniqueId)
        } else {
            print("Error creatervirt dest: \(clientName) -- \(virtualInput)")
        }
        
        
        result = MIDISourceCreate(client, clientName, &virtualOutput)
        if result == noErr {
            MIDIObjectSetIntegerProperty(virtualInput, kMIDIPropertyUniqueID, uniqueId + 1)
        } else {
            print("Error creating virtual source: \(clientName) -- \(virtualOutput)")
        }
    }
    
    /// Discard all virtual ports
    open func destroyVirtualPorts() {
        if virtualInput != 0 {
            MIDIEndpointDispose(virtualInput)
            virtualInput = 0
        }

        if virtualInput != 0 {
            MIDIEndpointDispose(virtualOutput)
            virtualInput = 0
        }
    }
}
