//
//  AKMIDI+ReceivingMIDI.swift
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright © 2018 AudioKit. All rights reserved.
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

    /// Add a transformer to the transformers list
    public func addTransformer(_ transformer: AKMIDITransformer) {
        transformers.append(transformer)
    }

    /// Remove all transformers
    public func clearTransformers() {
        transformers.removeAll()
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
                        // a CoreMIDI packet may contain multiple MIDI events -
                        // treat it like an array of events that can be transformed
                        let events = [AKMIDIEvent](packet) //uses makeiterator
                        let transformedMIDIEventList = self.transformMIDIEventList(events)
                        for transformedEvent in transformedMIDIEventList {
                            self.handleMIDIMessage(transformedEvent)
                        }
                    }
                }

                inputPorts[namedInput] = port

                if result != noErr {
                    AKLog("Error creating MIDI Input Port : \(result)")
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
        AKLog("Closing MIDI Input '\(namedInput)'")
        var result = noErr
        for key in inputPorts.keys {
            if namedInput.isEmpty || key == namedInput {
                if let port = inputPorts[key], let endpoint = endpoints[key] {

                    result = MIDIPortDisconnectSource(port, endpoint)
                    if result == noErr {
                        endpoints.removeValue(forKey: key)
                        inputPorts.removeValue(forKey: key)
                        AKLog("Disconnected \(key) and removed it from endpoints and input ports")
                    } else {
                        AKLog("Error disconnecting MIDI port: \(result)")
                    }
                    result = MIDIPortDispose(port)
                    if result == noErr {
                        AKLog("Disposed \(key)")
                    } else {
                        AKLog("Error displosing  MIDI port: \(result)")
                    }
                }
            }
        }
    }

    /// Close all MIDI Input ports
    public func closeAllInputs() {
        AKLog("Closing All Inputs")
        closeInput()
    }

    internal func handleMIDIMessage(_ event: AKMIDIEvent) {
        for listener in listeners {
            guard let eventChannel = event.channel else {
                AKLog("No channel detected in handleMIDIMessage")
                return
            }
            guard let type = event.status else {
                AKLog("No status detected in handleMIDIMessage")
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
                listener.receivedMIDIPitchWheel(MIDIWord(Int(event.wordData)),
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

    internal func transformMIDIEventList(_ eventList: [AKMIDIEvent]) -> [AKMIDIEvent] {
        var eventsToProcess = eventList
        var processedEvents = eventList

        for transformer in transformers {
            processedEvents = transformer.transform(eventList: eventsToProcess)
            // prepare for next transformer
            eventsToProcess = processedEvents
        }
        return processedEvents
    }
}
