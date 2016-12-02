//
//  AKMIDI+ReceivingMIDI.swift
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright © 2016 AudioKit. All rights reserved.
//

internal struct MIDISources: Collection {
    typealias Index = Int

    init() { }

    var startIndex: Index {
        return 0
    }

    var endIndex: Index {
        return MIDIGetNumberOfSources()
    }

    subscript (index: Index) -> MIDIEndpointRef {
      return MIDIGetSource(index)
    }

    func index(after index: Index) -> Index {
      return index + 1
    }
}

internal func GetMIDIObjectStringProperty(ref: MIDIObjectRef, property: CFString) -> String {
    var string: Unmanaged<CFString>? = nil
    MIDIObjectGetStringProperty(ref, property, &string)
    return (string?.takeRetainedValue())! as String
}

extension AKMIDI {
    
    /// Array of input names
    public var inputNames: [String] {
        return MIDISources().names
    }
    
    /// Add a listener to the listeners
    public func addListener(_ listener: AKMIDIListener) {
        listeners.append(listener)
    }
    
    /// Remove all listeners
    public func clearListeners() {
        listeners.removeAll()
    }
    
    /// Open a MIDI Input port
    ///
    /// - parameter namedInput: String containing the name of the MIDI Input
    ///
    public func openInput(_ namedInput: String = "") {        
        for (name, src) in zip(inputNames, MIDISources()) {
            if namedInput.isEmpty || namedInput == name {
                inputPorts[namedInput] = MIDIPortRef()
                
                var port = inputPorts[namedInput]!

                let result = MIDIInputPortCreateWithBlock(client, inputPortName, &port) {
                  packetList, _ in
                    for packet in packetList.pointee {
                        // a coremidi packet may contain multiple midi events
                        for event in packet {
                            self.handleMidiMessage(event)
                        }
                    }
                }
                
                inputPorts[namedInput] = port
                
                if result != noErr {
                    print("Error creating midiInPort : \(result)")
                }
                MIDIPortConnectSource(port, src, nil)
                endpoints[namedInput] = src
            }
        }
    }
    
    /// Close a MIDI Input port
    ///
    /// - parameter namedInput: String containing the name of the MIDI Input
    ///
    public func closeInput(_ namedInput: String = "") {
        for (key, endpoint) in inputPorts {
            if namedInput.isEmpty || key == namedInput {
                if let port = inputPorts[key] {
                    let result = MIDIPortDisconnectSource(port, endpoint)
                    if result == noErr {
                        endpoints.removeValue(forKey: namedInput)
                        inputPorts.removeValue(forKey: namedInput)
                    } else {
                        print("Error closing midiInPort : \(result)")
                    }
                }
            }
        }
    }
    
    /// Close all MIDI Input ports
    public func closeAllInputs() {
        closeInput()
    }
    
    internal func handleMidiMessage(_ event: AKMIDIEvent) {
        for listener in listeners {
            let type = event.status
            switch type {
            case .controllerChange:
                listener.receivedMIDIController(Int(event.internalData[1]),
                                                value: Int(event.internalData[2]),
                                                channel: MIDIChannel(event.channel))
            case .channelAftertouch:
                listener.receivedMIDIAfterTouch(Int(event.internalData[1]),
                                                channel: MIDIChannel(event.channel))
            case .noteOn:
                listener.receivedMIDINoteOn(noteNumber: MIDINoteNumber(event.internalData[1]),
                                            velocity: MIDIVelocity(event.internalData[2]),
                                            channel: MIDIChannel(event.channel))
            case .noteOff:
                listener.receivedMIDINoteOff(noteNumber: MIDINoteNumber(event.internalData[1]),
                                             velocity: MIDIVelocity(event.internalData[2]),
                                             channel: MIDIChannel(event.channel))
            case .pitchWheel:
                listener.receivedMIDIPitchWheel(Int(event.data),
                                                channel: MIDIChannel(event.channel))
            case .polyphonicAftertouch:
                listener.receivedMIDIAftertouch(noteNumber: MIDINoteNumber(event.internalData[1]),
                                                pressure: Int(event.internalData[2]),
                                                channel: MIDIChannel(event.channel))
            case .programChange:
                listener.receivedMIDIProgramChange(Int(event.internalData[1]),
                                                   channel: MIDIChannel(event.channel))
            case .systemCommand:
                listener.receivedMIDISystemCommand(event.internalData)
            default:
                break
            }
        }
    }
    
    internal func MyMIDINotifyBlock(_ midiNotification: UnsafePointer<MIDINotification>) {
        let notification = midiNotification.pointee
        
        for listener in listeners {
            switch notification.messageID {
            case .msgSetupChanged:
                listener.receivedMIDISetupChange()
            default:
                break
            }
        }
        
    }
}
