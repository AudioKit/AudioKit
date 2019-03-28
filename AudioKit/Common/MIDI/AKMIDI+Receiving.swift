//
//  AKMIDI+Receiving.swift
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright © 2018 AudioKit. All rights reserved.
//
// AKMIDI+Receiving Goals
//      * Simplicty in discovery and presentation of available source inputs
//      * Simplicty in inserting multiple midi transformations between a source and listeners
//      * Simplicty in removing an individual midi transformation
//      * Simplicty in removing all midi transformations
//      * Simplicty in attaching multiple listeners to a source input
//      * Simplicty in removing an individual listeners from a source input
//      * Simplicty in removing all listeners
//      * Simplicty to close all ports
//      * Ports must be identifies using MIDIUniqueIDs because ports can share the same name across devices and clients
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

// MARK: - AKMIDIListeners
extension AKMIDI {
    /// Add a listener to the listeners
    public func addListener(_ listener: AKMIDIListener) {
        listeners.append(listener)
    }

    public func removeListener(_ listener: AKMIDIListener) {
        listeners.removeAll { (item) -> Bool in
            return item == listener
        }
    }

    /// Remove all listeners
    public func clearListeners() {
        listeners.removeAll()
    }
}

// MARK: - AKMIDITransformers
extension AKMIDI {
    /// Add a transformer to the transformers list
    public func addTransformer(_ transformer: AKMIDITransformer) {
        transformers.append(transformer)
    }

    public func removeTransformer(_ transformer: AKMIDITransformer) {
        transformers.removeAll { $0 == transformer }
    }

    /// Remove all transformers
    public func clearTransformers() {
        transformers.removeAll()
    }
}

extension AKMIDI {

    /// Array of input source unique ids
    public var inputUIDs: [MIDIUniqueID] {
        return MIDISources().uniqueIds
    }

    /// Array of input source names
    public var inputNames: [String] {
        return MIDISources().names
    }

    /// Lookup a input name from its unique id
    ///
    /// - Parameter forUid: unique id for a input
    /// - Returns: name of input or "Unknown"
    public func inputName(for inputUid: MIDIUniqueID) -> String {
        let name: String = zip(inputNames, inputUIDs).first { (arg: (String, MIDIUniqueID)) -> Bool in
                let (_, uid) = arg
                return inputUid == uid
            }.map { (arg) -> String in
                let (name, _) = arg
                return name
            } ?? "Uknown"
        return name
    }



    /// Look up the unique id for a input index
    ///
    /// - Parameter inputIndex: index of destination
    /// - Returns: unique identifier for the port
    public func uidForInputAtIndex(_ inputIndex: Int = 0) -> MIDIUniqueID {
        let endpoint: MIDIEndpointRef = MIDISources()[inputIndex]
        let uid = getMIDIObjectIntegerProperty(ref: endpoint, property: kMIDIPropertyUniqueID)
        return uid
    }

    /// Open a MIDI Input port by name
    ///
    /// - Parameter inputIndex: Index of source port
    public func openInput(name: String = "") {
        guard  let index = inputNames.firstIndex(of: name) else {
            openInput(uid: 0)
            return
        }
        let uid = inputUIDs[index]
        openInput(uid: uid)
    }

    /// Open a MIDI Input port by index
    ///
    /// - Parameter inputIndex: Index of source port
    public func openInput(index inputIndex: Int) {
        guard inputIndex < inputNames.count else {
            return
        }
        let uid = uidForInputAtIndex(inputIndex)
        openInput(uid: uid)
    }

    /// Open a MIDI Input port
    ///
    /// - parameter inputUID: Unique identifier for a MIDI Input
    ///
    public func openInput(uid inputUID: MIDIUniqueID) {
        for (uid, src) in zip(inputUIDs, MIDISources()) {
            if inputUID == 0 || inputUID == uid {
                inputPorts[inputUID] = MIDIPortRef()

                var port = inputPorts[inputUID]!

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
                            self.handleMIDIMessage(transformedEvent)
                        }
                        packetCount += 1
                    }
                }

                inputPorts[inputUID] = port

                if result != noErr {
                    AKLog("Error creating MIDI Input Port : \(result)")
                }
                MIDIPortConnectSource(port, src, nil)
                endpoints[inputUID] = src
            }
        }
    }

    /// Open a MIDI Input port by name
    ///
    /// - Parameter inputIndex: Index of source port
    @available(*, deprecated, message: "Try to not use names any more because they are not unique across devices")
    public func closeInput(name: String) {
        guard  let index = inputNames.firstIndex(of: name) else {
            closeInput(uid: 0)
            return
        }
        let uid = inputUIDs[index]
        closeInput(uid: uid)
    }

    public func closeInput() {
        closeInput(uid: 0)
    }

    /// Open a MIDI Input port by index
    ///
    /// - Parameter inputIndex: Index of source port
    public func closeInput(index inputIndex: Int) {
        let uid = uidForInputAtIndex(inputIndex)
        closeInput(uid: uid)
    }

    /// Close a MIDI Input port
    ///
    /// - parameter inputName: Unique id of the MIDI Input
    ///
    public func closeInput(uid inputUID: MIDIUniqueID) {
        let name = inputName(for: inputUID)
        AKLog("Closing MIDI Input '\(String(describing: inputName))'")
        var result = noErr
        for uid in inputPorts.keys {
            if inputUID == 0 || uid == inputUID {
                if let port = inputPorts[uid], let endpoint = endpoints[uid] {
                    result = MIDIPortDisconnectSource(port, endpoint)
                    if result == noErr {
                        endpoints.removeValue(forKey: uid)
                        inputPorts.removeValue(forKey: uid)
                        AKLog("Disconnected \(name) and removed it from endpoints and input ports")
                    } else {
                        AKLog("Error disconnecting MIDI port: \(result)")
                    }
                    result = MIDIPortDispose(port)
                    if result == noErr {
                        AKLog("Disposed \(name)")
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
            if let type = event.status?.type {
                guard let eventChannel = event.channel else {
                    AKLog("No channel detected in handleMIDIMessage")
                    continue
                }
                switch type {
                case .controllerChange:
                    listener.receivedMIDIController(event.data[1],
                                                    value: event.data[2],
                                                    channel: MIDIChannel(eventChannel))
                case .channelAftertouch:
                    listener.receivedMIDIAfterTouch(event.data[1],
                                                    channel: MIDIChannel(eventChannel))
                case .noteOn:
                    listener.receivedMIDINoteOn(noteNumber: MIDINoteNumber(event.data[1]),
                                                velocity: MIDIVelocity(event.data[2]),
                                                channel: MIDIChannel(eventChannel))
                case .noteOff:
                    listener.receivedMIDINoteOff(noteNumber: MIDINoteNumber(event.data[1]),
                                                 velocity: MIDIVelocity(event.data[2]),
                                                 channel: MIDIChannel(eventChannel))
                case .pitchWheel:
                    listener.receivedMIDIPitchWheel(event.pitchbendAmount!,
                                                    channel: MIDIChannel(eventChannel))
                case .polyphonicAftertouch:
                    listener.receivedMIDIAftertouch(noteNumber: MIDINoteNumber(event.data[1]),
                                                    pressure: event.data[2],
                                                    channel: MIDIChannel(eventChannel))
                case .programChange:
                    listener.receivedMIDIProgramChange(event.data[1],
                                                       channel: MIDIChannel(eventChannel))
                }
            } else if event.command != nil {
                //AKLog("Passing [\(event.command?.description ?? "unknown")] to listener \(listener)")
                listener.receivedMIDISystemCommand(event.data, time: event.timeStamp)
            } else {
                AKLog("No usable status detected in handleMIDIMessage")
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
