//
//  AKMIDI+ReceivingMIDI.swift
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright © 2017 Aurelius Prochazka. All rights reserved.
//

internal struct MIDISources: Collection {
    typealias Index = Int
    typealias Element = MIDIEndpointRef

    init() { }

    var endIndex: Index {
        return MIDIGetNumberOfSources()
    }

    subscript (index: Index) -> Element {
        return MIDIGetSource(index)
    }
}

internal func GetMIDIObjectStringProperty(ref: MIDIObjectRef, property: CFString) -> String {
    var string: Unmanaged<CFString>?
    MIDIObjectGetStringProperty(ref, property, &string)
    if let returnString = string?.takeRetainedValue() {
        return returnString as String
    } else {
        return ""
    }
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

                let result = MIDIInputPortCreateWithBlock(client, inputPortName, &port) { packetList, _ in
                    for packet in packetList.pointee {
                        // a coremidi packet may contain multiple midi events
                        for event in packet {
                            self.handleMIDIMessage(event)
                        }
                    }
                }

                inputPorts[namedInput] = port

                if result != noErr {
                    AKLog("Error creating midiInPort : \(result)")
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
        var result = noErr
        for key in inputPorts.keys {
            if namedInput.isEmpty || key == namedInput {
                if let port = inputPorts[key], let endpoint = endpoints[key] {

                    result = MIDIPortDisconnectSource(port, endpoint)
                    if result == noErr {
                        endpoints.removeValue(forKey: namedInput)
                        inputPorts.removeValue(forKey: namedInput)
                    } else {
                        AKLog("Error closing midiInPort : \(result)")
                    }
                }
            }
        }
//        The below code is not working properly - error closing midi port
//        for (key, endpoint) in inputPorts {
//            if namedInput.isEmpty || key == namedInput {
//                if let port = inputPorts[key] {
//                    // the next line is returning error -50, either port or endpoint is not right
//                    let result = MIDIPortDisconnectSource(port, endpoint)
//                    if result == noErr {
//                        endpoints.removeValue(forKey: namedInput)
//                        inputPorts.removeValue(forKey: namedInput)
//                    } else {
//                        AKLog("Error closing midiInPort : \(result)")
//                    }
//                }
//            }
//        }
    }

    /// Close all MIDI Input ports
    public func closeAllInputs() {
        closeInput()
    }

    internal func handleMIDIMessage(_ event: AKMIDIEvent) {
        for listener in listeners {
            guard let eventChannel = event.channel else {
                return
            }
            guard let type = event.status else {
                return
            }
            switch type {
            case .controllerChange:
                listener.receivedMIDIController(event.internalData[1],
                                                value: event.internalData[2],
                                                channel: MIDIChannel(eventChannel))
            case .channelAftertouch:
                listener.receivedMIDIAfterTouch(event.internalData[1],
                                                channel: MIDIChannel(eventChannel))
            case .noteOn:
                listener.receivedMIDINoteOn(noteNumber: MIDINoteNumber(event.internalData[1]),
                                            velocity: MIDIVelocity(event.internalData[2]),
                                            channel: MIDIChannel(eventChannel))
            case .noteOff:
                listener.receivedMIDINoteOff(noteNumber: MIDINoteNumber(event.internalData[1]),
                                             velocity: MIDIVelocity(event.internalData[2]),
                                             channel: MIDIChannel(eventChannel))
            case .pitchWheel:
                print(event.data)
                listener.receivedMIDIPitchWheel(MIDIByte(Int(event.data)),
                                                channel: MIDIChannel(eventChannel))
            case .polyphonicAftertouch:
                listener.receivedMIDIAftertouch(noteNumber: MIDINoteNumber(event.internalData[1]),
                                                pressure: event.internalData[2],
                                                channel: MIDIChannel(eventChannel))
            case .programChange:
                listener.receivedMIDIProgramChange(event.internalData[1],
                                                   channel: MIDIChannel(eventChannel))
            case .systemCommand:
                listener.receivedMIDISystemCommand(event.internalData)
            default:
                break
            }
        }
    }
}
