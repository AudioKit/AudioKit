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
/// You add MIDI listeners like this:
/// ```
/// var midiIn = AudioKit.midi
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
  internal var inputPorts: [String: MIDIPortRef] = [:]

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

  internal var transformers = [AKMIDITransformer]()

  // MARK: - Initialization

  /// Initialize the AKMIDI system
  @objc public init() {

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
        AKLog("Error creating MIDI client : \(result)")
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
    destroyVirtualInputPort()
    let virtualPortname = name ?? String(clientName)

    let result = MIDIDestinationCreateWithBlock(client,
                                                virtualPortname as CFString,
                                                &virtualInput) { packetList, _ in
                                                  for packet in packetList.pointee {
                                                    // a Core MIDI packet may contain multiple MIDI events
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
    destroyVirtualOutputPort()
    let virtualPortname = name ?? String(clientName)

    let result = MIDISourceCreate(client, virtualPortname as CFString, &virtualOutput)
    if result == noErr {
      MIDIObjectSetIntegerProperty(virtualInput, kMIDIPropertyUniqueID, uniqueID + 1)
    } else {
      AKLog("Error creating virtual source: \(virtualPortname) -- \(virtualOutput)")
    }
  }

  /// Discard all virtual ports
  open func destroyVirtualPorts() {
    destroyVirtualInputPort()
    destroyVirtualOutputPort()
  }

  /// Closes the virtual input port, if created one already.
  ///
  /// - Returns: Returns true if virtual input closed.
  @discardableResult open func destroyVirtualInputPort() -> Bool {
    if virtualInput != 0 {
      if MIDIEndpointDispose(virtualInput) == noErr {
        virtualInput = 0
        return true
      }
    }
    return false
  }

  /// Closes the virtual output port, if created one already.
  ///
  /// - Returns: Returns true if virtual output closed.
  @discardableResult open func destroyVirtualOutputPort() -> Bool {
    if virtualOutput != 0 {
      if MIDIEndpointDispose(virtualOutput) == noErr {
        virtualOutput = 0
        return true
      }
    }
    return false
  }
}
