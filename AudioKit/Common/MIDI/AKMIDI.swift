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
/// var midiIn = AKMidi()
/// midi.openInput()
/// midi.addListener(someClass)
/// ```
/// ...where someClass conforms to the AKMIDIListener protocol
///
/// You then implement the methods you need from AKMIDIListener and use the data how you need.
public class AKMIDI {
    
    // MARK: - Properties
    
    /// MIDI Client Reference
    public var client = MIDIClientRef()
    
    /// Array of MIDI In ports
    internal var inputPorts = [MIDIPortRef]()

    /// Virtual MIDI Input destination
    public var virtualInput = MIDIPortRef()

    /// MIDI Client Name
    private var clientName: CFString = "MIDI Client"
    
    /// MIDI In Port Name
    internal var inputPortName: CFString = "MIDI In Port"
    
    /// MIDI End Point
    private var endpoint: MIDIEndpointRef {
        return endpoints[0]
    }

    /// MIDI Out Port Reference
    internal var outputPort = MIDIPortRef()

    /// Virtual MIDI output
    internal var virtualOutput = MIDIPortRef()

    
    /// Array of MIDI Endpoints
    internal var endpoints = [MIDIEndpointRef]()
    
    /// MIDI Out Port Name
    internal var outputPortName: CFString = "MIDI Out Port"
    
    /// Array of all listeners
    internal var listeners = [AKMIDIListener]()
    
    // MARK: - Initialization

    /// Initialize the AKMIDI system
    public init() {

        #if os(iOS)
            MIDINetworkSession.defaultSession().enabled = true
            MIDINetworkSession.defaultSession().connectionPolicy =
                MIDINetworkConnectionPolicy.Anyone
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
    public func createVirtualPorts(uniqueId: Int32 = 2000000) {

        destroyVirtualPorts()
        
        var result = noErr
        result = MIDIDestinationCreateWithBlock(client, clientName, &virtualInput, MyMIDIReadBlock)
        
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
    public func destroyVirtualPorts() {
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
