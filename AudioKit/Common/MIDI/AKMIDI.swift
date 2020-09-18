//
//  AKMIDI.swift
//  AudioKit
//
//  Created by Jeff Cooper, revision history on Github.
//  Copyright © 2018 AudioKit. All rights reserved.
//

import CoreMIDI

/// MIDI input and output handler
///
open class AKMIDI {

    // MARK: - Properties

    /// MIDI Client Reference
    open var client = MIDIClientRef()

    /// MIDI Client Name
    internal let clientName: CFString = "MIDI Client" as CFString

    /// Array of MIDI In ports
    public var inputPorts = [MIDIUniqueID: MIDIPortRef]()

    /// Virtual MIDI Input destination
    open var virtualInput = MIDIPortRef()

    /// MIDI In Port Name
    internal let inputPortName: CFString = "MIDI In Port" as CFString

    /// MIDI Out Port Reference
    public var outputPort = MIDIPortRef()

    /// Virtual MIDI output
    open var virtualOutput = MIDIPortRef()

    /// MIDI Out Port Name
    var outputPortName: CFString = "MIDI Out Port" as CFString

    /// Array of MIDI Endpoints
    open var endpoints = [MIDIUniqueID: MIDIEndpointRef]()

    /// Array of all listeners
    public var listeners = [AKMIDIListener]()

    public var transformers = [AKMIDITransformer]()

    /// Dictionary of MIDI In ports of EndpointInfo
    internal var inputEndpointPorts = [EndpointInfo: MIDIPortRef]()
    
    /// Dictionary of MIDI Out ports of EndpointInfo
    internal var outputEndpointPorts = [EndpointInfo: MIDIPortRef]()
    
    // MARK: - Initialization

    /// Initialize the AKMIDI system
    @objc public init() {
        AKLog("Initializing MIDI", log: OSLog.midi)

        #if os(iOS)
        MIDINetworkSession.default().isEnabled = true
        MIDINetworkSession.default().connectionPolicy =
            MIDINetworkConnectionPolicy.anyone
        #endif

        if client == 0 {
            let result = MIDIClientCreateWithBlock(clientName, &client) {
                let messageID = $0.pointee.messageID

                switch messageID {
                case .msgSetupChanged:
                    for listener in self.listeners {
                        listener.receivedMIDISetupChange()
                    }
                case .msgPropertyChanged:
                    let rawPtr = UnsafeRawPointer($0)
                    let propChange = rawPtr.assumingMemoryBound(to: MIDIObjectPropertyChangeNotification.self).pointee
                    for listener in self.listeners {
                        listener.receivedMIDIPropertyChange(propertyChangeInfo: propChange)
                    }
                default:
                    for listener in self.listeners {
                        listener.receivedMIDINotification(notification: $0.pointee)
                    }
                }
            }
            if result != noErr {
                AKLog("Error creating MIDI client: \(result)", log: OSLog.midi, type: .error)
            }
        }
    }

    // MARK: - SYSEX

    internal var isReceivingSysEx: Bool = false
    func startReceivingSysEx(with midiBytes: [MIDIByte]) {
        AKLog("Starting to receive SysEx", log: OSLog.midi)
        isReceivingSysEx = true
        incomingSysEx = midiBytes
    }
    func stopReceivingSysEx() {
        AKLog("Done receiving SysEx", log: OSLog.midi)
        isReceivingSysEx = false
    }
    var incomingSysEx = [MIDIByte]()
}
