//
//  AKMIDI.swift
//  AudioKit
//
//  Created by Jeff Cooper, revision history on Github.
//  Copyright © 2017 Aurelius Prochazka. All rights reserved.
//

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
    private let clientName: CFString = "MIDI Client" as CFString

    /// MIDI In Port Name
    internal let inputPortName: CFString = "MIDI In Port" as CFString

    /// MIDI Out Port Reference
    internal var outputPort = MIDIPortRef()

    /// Virtual MIDI output
    open var virtualOutput = MIDIPortRef()

    /// Array of MIDI Endpoints
    open var endpoints = [String: MIDIEndpointRef]()

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

        if client == 0 {
            let result = MIDIClientCreateWithBlock(clientName, &client) {
                guard $0.pointee.messageID == .msgSetupChanged else {
                    return
                }
                for l in self.listeners {
                    l.receivedMIDISetupChange()
                }
            }
            if result != noErr {
                AKLog("Error creating midi client : \(result)")
            }
        }
    }

    // MARK: - Virtual MIDI

    /// Create set of virtual MIDI ports
    open func createVirtualPorts(_ uniqueID: Int32 = 2_000_000, name: String? = nil) {
        destroyVirtualPorts()
        createVirtualInputPort(uniqueID, name: name)
        createVirtualOutputPort(uniqueID, name: name)
    }

    /// Create a virtual MIDI input port
    open func createVirtualInputPort(_ uniqueID: Int32 = 2_000_000, name: String? = nil) {
        destroyVirtualPorts()
        let virtualPortname = ((name != nil) ? name! : String(clientName))

        let result = MIDIDestinationCreateWithBlock(client, virtualPortname as CFString, &virtualInput) { packetList, _ in
            for packet in packetList.pointee {
                // a coremidi packet may contain multiple midi events
                for event in packet {
                    self.handleMIDIMessage(event)
                }
            }
        }

        if result == noErr {
            MIDIObjectSetIntegerProperty(virtualInput, kMIDIPropertyUniqueID, uniqueID)
        } else {
            AKLog("Error creatervirt dest: \(virtualPortname) -- \(virtualInput)")
        }
    }

    /// Create a virtual MIDI output port
    open func createVirtualOutputPort(_ uniqueID: Int32 = 2_000_000, name: String? = nil) {
        let virtualPortname = ((name != nil) ? name! : String(clientName))

        let result = MIDISourceCreate(client, virtualPortname as CFString, &virtualOutput)
        if result == noErr {
            MIDIObjectSetIntegerProperty(virtualInput, kMIDIPropertyUniqueID, uniqueID + 1)
        } else {
            AKLog("Error creating virtual source: \(virtualPortname) -- \(virtualOutput)")
        }
    }

    /// Discard all virtual ports
    open func destroyVirtualPorts() {
        if virtualInput != 0 {
            MIDIEndpointDispose(virtualInput)
            virtualInput = 0
        }

        if virtualOutput != 0 {
            MIDIEndpointDispose(virtualOutput)
            virtualOutput = 0
        }
    }
}
