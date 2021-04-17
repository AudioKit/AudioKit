// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

// MIDI+Receiving Goals
//      * Simplicty in discovery and presentation of available source inputs
//      * Simplicty in inserting multiple midi transformations between a source and listeners
//      * Simplicty in removing an individual midi transformation
//      * Simplicty in removing all midi transformations
//      * Simplicty in attaching multiple listeners to a source input
//      * Simplicty in removing an individual listeners from a source input
//      * Simplicty in removing all listeners
//      * Simplicty to close all ports
//      * Ports must be identifiers using MIDIUniqueIDs because ports can share the same name across devices and clients
//

#if !os(tvOS)

import os.log
import AVFoundation

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

// MARK: - MIDIListeners
extension MIDI {
    /// Add a listener
    /// - Parameter listener: MIDI Listener
    public func addListener(_ listener: MIDIListener) {
        listeners.append(listener)
    }

    /// REmove a listener
    /// - Parameter listener: MIDI Listener
    public func removeListener(_ listener: MIDIListener) {
        listeners.removeAll { (item) -> Bool in
            return item == listener
        }
    }

    /// Remove all listeners
    public func clearListeners() {
        listeners.removeAll()
    }
}

// MARK: - MIDITransformers
extension MIDI {
    /// Add a transformer to the transformers list
    /// - Parameter transformer: MIDI Transformer
    public func addTransformer(_ transformer: MIDITransformer) {
        transformers.append(transformer)
    }

    /// Remove a transformer from the transformers list
    /// - Parameter transformer: MIDI Transformer
    public func removeTransformer(_ transformer: MIDITransformer) {
        transformers.removeAll { $0 == transformer }
    }

    /// Remove all transformers
    public func clearTransformers() {
        transformers.removeAll()
    }
}

extension MIDI {

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
    /// - Returns: name of input or nil
    public func inputName(for inputUid: MIDIUniqueID) -> String? {

        let name: String? = zip(inputNames, inputUIDs).first { (arg: (String, MIDIUniqueID)) -> Bool in
                let (_, uid) = arg
                return inputUid == uid
        }.map { (arg) -> String in
                let (name, _) = arg
                return name
        }
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
        guard let index = inputNames.firstIndex(of: name) else {
            if name == "" {
                for uid in inputUIDs {
                    openInput(uid: uid)
                }
            }
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
    
    /// Message type of the Universal MIDI Packet
    ///
    /// https://www.midi.org/midi-articles/details-about-midi-2-0-midi-ci-profiles-and-property-exchange
    enum UMPMessageType: UInt8 {
        case Utility32bit = 0x0
        case SystemRealTimeAndCommon32bit = 0x1
        case MIDI1ChannelVoice32bit = 0x2
        case DataAndSysEx64bit = 0x3
        case MIDI2ChannelVoice64bit = 0x4
        case Data128bit = 0x5
        case Reserved32bit_1 = 0x6
        case Reserved32bit_2 = 0x7
        case Reserved64bit_3 = 0x8
        case Reserved64bit_4 = 0x9
        case Reserved64bit_5 = 0xA
        case Reserved96bit_6 = 0xB
        case Reserved96bit_7 = 0xC
        case Reserved128bit_8 = 0xD
        case Reserved128bit_9 = 0xE
        case Reserved128bit_10 = 0xF
    }
    
    /// Status of each UMP in a System Exclusive message
    ///
    /// Chapter 4.4 of M2-104-UM Universal MIDI Packet (UMP) Format and MIDI 2.0 Protocol
    /// http://download.xskernel.org/docs/protocols/M2-104-UM_v1-0_UMP_and_MIDI_2-0_Protocol_Specification.pdf
    enum UMPSysEx7bitStatus: UInt8 {
        case CompleteMessage = 0x0
        case Start = 0x1
        case Continue = 0x2
        case End = 0x3
    }
    
    private func byteArray<T>(from value: T) -> [UInt8] where T: FixedWidthInteger {
        withUnsafeBytes(of: value.bigEndian, Array.init)
    }
    
    private func getMSB(from uint8: UInt8) -> UInt8 {
        return (uint8 & 0xF0) >> 4
    }
    
    private func getLSB(from uint8: UInt8) -> UInt8 {
        return uint8 & 0x0F
    }
    
    /// The most significant 4 bits of the first UInt32 word in every UMP shall contain the Message Type field.
    /// UMP Message Type can tell us how many 32bit UMP packets we have to read next in order to get full MIDI message.
    /// A Universal MIDI Packet contains a MIDI message which can consists of one to four 32-bit words.
    ///
    /// https://www.midi.org/midi-articles/details-about-midi-2-0-midi-ci-profiles-and-property-exchange
    private func getUMPMessageTypeWithByteArray(from ump: UInt32) -> (UMPMessageType?, [UInt8]) {
        let bytes = byteArray(from: ump) // 4 bytes from UInt32
        // returning bytes without first type/group byte, I guess we don't need it in MIDI 1.0
        return (UMPMessageType(rawValue: getMSB(from: bytes[0])), Array(bytes[1...bytes.count - 1]))
    }
    
    /// Converting UMP SysEx message data to conform existing MIDI parser code.
    /// Returns only complete SysEx message data.
    private func processUMPSysExMessage(with bytes: [UInt8]) -> [UInt8]? {
        // Chapter 4.4 of Universal MIDI Packet (UMP) Format and MIDI 2.0 Protocol, Version 1.0
        // http://download.xskernel.org/docs/protocols/M2-104-UM_v1-0_UMP_and_MIDI_2-0_Protocol_Specification.pdf
        
        let umpSysExStatus = UMPSysEx7bitStatus(rawValue: getMSB(from: bytes[0])) // status byte
        let validBytesCount = getLSB(from: bytes[0]) // valid bytes count field
        let validBytes = Array(bytes[1..<1+Int(validBytesCount)])
        
        guard (umpSysExStatus != nil) else {
            Log("UMP SYSEX - Got unsupported UMPSysEx7bitStatus", log: OSLog.midi)
            return validBytes
        }
        
        // New UMP format for SysEx messages does not contain F0 and F7 as start / stop flags
        // We need to use new UMP message type field and add these flags to make existing MIDI parser code happy and people expect to have F0 and F7 in the SysEx message I think
        
        switch umpSysExStatus {
        case .CompleteMessage:
            Log("UMP SYSEX - Got complete SysEx message in one UMP packet", log: OSLog.midi)
            
            incomigUMPSysExMessage = [UInt8]()
            incomigUMPSysExMessage.append(0xF0)
            incomigUMPSysExMessage.append(contentsOf: validBytes)
            incomigUMPSysExMessage.append(0xF7)
            return incomigUMPSysExMessage
        case .Start:
            Log("UMP SYSEX - Start receiving UMP SysEx messages", log: OSLog.midi)
            
            incomigUMPSysExMessage = [UInt8]()
            incomigUMPSysExMessage.append(0xF0)
            incomigUMPSysExMessage.append(contentsOf: validBytes)
            // Full message not ready, nothing to return
            return nil
        case .Continue:
            Log("UMP SYSEX - Continue receiving UMP SysEx messages", log: OSLog.midi)
            
            incomigUMPSysExMessage.append(contentsOf: validBytes)
            // Full message not ready, nothing to return
            return nil
        case .End:
            Log("UMP SYSEX - End of UMP SysEx messages", log: OSLog.midi)
            
            incomigUMPSysExMessage.append(contentsOf: validBytes)
            incomigUMPSysExMessage.append(0xF7)
            return incomigUMPSysExMessage
        default:
            Log("UMP SYSEX - Got unsupported UMPSysEx7bitStatus", log: OSLog.midi)
            return nil
        }
    }

    /// Parsing UMP Messages
    @available(iOS 14.0, macOS 11.0, *)
    private func processUMPMessages(_ midiEventPacket: MIDIEventList.UnsafeSequence.Element) -> [MIDIEvent] {
        // Collection of UInt32 words
        let words = MIDIEventPacket.WordCollection(midiEventPacket)
        let timeStamp = midiEventPacket.pointee.timeStamp
        var midiEvents = [MIDIEvent]()
        var wordIndex = 0
        
        // Iterating through valid words in collection.
        // Using wordCount, because MIDIEventPacket will contain garbage data after wordCount.
        while (wordIndex < midiEventPacket.pointee.wordCount) {
            let word = words[wordIndex]
            
            // Parsing UMP words
            var (umpMessageType, umpMessageBytes) = self.getUMPMessageTypeWithByteArray(from: word)
            
            guard (umpMessageType != nil) else {
                Log("Got invalid UMP Message Type, skipping rest of the packet", log: OSLog.midi)
                return midiEvents
            }

            switch umpMessageType {
            case .Utility32bit, .SystemRealTimeAndCommon32bit, .MIDI1ChannelVoice32bit:

                midiEvents.append(MIDIEvent(data: umpMessageBytes, timeStamp: timeStamp))
                wordIndex += 1
                break
            case .Reserved32bit_1, .Reserved32bit_2:
                Log("Got unsupported 32 bit UMP message of type: \(String(describing: umpMessageType))", log: OSLog.midi)
                wordIndex += 1
                break
            case .DataAndSysEx64bit:
                // Appending bytes from second word to byte array
                let secondWordBytes = byteArray(from: words[wordIndex + 1])
                umpMessageBytes.append(contentsOf: secondWordBytes)
                if let completeSysExMessageData = processUMPSysExMessage(with: umpMessageBytes) {
                    midiEvents.append(MIDIEvent(data: completeSysExMessageData, timeStamp: timeStamp))
                }
                wordIndex += 2
                break
            case .MIDI2ChannelVoice64bit, .Reserved64bit_3, .Reserved64bit_4, .Reserved64bit_5:
                Log("Got unsupported 64 bit UMP message of type: \(String(describing: umpMessageType))", log: OSLog.midi)
                wordIndex += 2
                break
            case .Reserved96bit_6, .Reserved96bit_7:
                Log("Got unsupported 96 bit UMP message of type: \(String(describing: umpMessageType))", log: OSLog.midi)
                wordIndex += 3
                break
            case .Data128bit, .Reserved128bit_8, .Reserved128bit_9, .Reserved128bit_10:
                Log("Got unsupported 128 bit UMP message of type \(String(describing: umpMessageType))", log: OSLog.midi)
                wordIndex += 4
                break
            default:
                // We should not get there, because of the guard at the top
                Log("Received undefined UMP Message type", log: OSLog.midi)
                wordIndex = Int(midiEventPacket.pointee.wordCount) // data probably corrupted, skipping rest of the packet, exiting while loop
                break
            }
        }
        
        return midiEvents
    }

    /// Open a MIDI Input port
    ///
    /// - parameter inputUID: Unique identifier for a MIDI Input
    ///
    public func openInput(uid inputUID: MIDIUniqueID) {
        for (uid, src) in zip(inputUIDs, MIDISources()) {
            if inputUID == 0 || inputUID == uid {
                inputPorts[inputUID] = MIDIPortRef()

                if var port = inputPorts[inputUID] {
                    var inputPortCreationResult = noErr
                    
                    // Using MIDIInputPortCreateWithProtocol on iOS 14+
                    if #available(iOS 14.0, macOS 11.0, *) {
                        // Hardcoded MIDI protocol version 1.0 here, consider to have an option somewhere
                        inputPortCreationResult = MIDIInputPortCreateWithProtocol(client, inputPortName, ._1_0, &port) { eventPacketList, _ in

                            guard (eventPacketList.pointee.protocol == ._1_0) else {
                                Log("Got unsupported MIDI 2.0 MIDIEventList, skipping", log: OSLog.midi)
                                return
                            }

                            for midiEventPacket in eventPacketList.unsafeSequence() {

                                let midiEvents = self.processUMPMessages(midiEventPacket)
                                let transformedMIDIEventList = self.transformMIDIEventList(midiEvents)
                                for transformedEvent in transformedMIDIEventList where transformedEvent.status != nil
                                    || transformedEvent.command != nil {
                                    self.handleMIDIMessage(transformedEvent, fromInput: inputUID)
                                }
                            }
                        }
                    } else {
                        // Using MIDIInputPortCreateWithBlock on iOS 9 - 13
                        inputPortCreationResult = MIDIInputPortCreateWithBlock(client, inputPortName, &port) { packetList, _ in
                            
                            for packet in packetList.pointee {
                                // a CoreMIDI packet may contain multiple MIDI events -
                                // treat it like an array of events that can be transformed
                                let events = [MIDIEvent](packet) //uses MIDIPacketeList makeIterator
                                let transformedMIDIEventList = self.transformMIDIEventList(events)
                                // Note: incomplete SysEx packets will not have a status
                                for transformedEvent in transformedMIDIEventList where transformedEvent.status != nil
                                    || transformedEvent.command != nil {
                                    self.handleMIDIMessage(transformedEvent, fromInput: inputUID)
                                }
                            }
                        }
                    }
                    if inputPortCreationResult != noErr {
                        Log("Error creating MIDI Input Port: \(inputPortCreationResult)")
                    }

                    MIDIPortConnectSource(port, src, nil)
                    inputPorts[inputUID] = port
                    endpoints[inputUID] = src
                }
            }
        }
    }

    /// Open a MIDI Input port by name
    ///
    /// - Parameter inputIndex: Index of source port
    @available(*, deprecated, message: "Try to not use names any more because they are not unique across devices")
    public func closeInput(name: String) {
        guard  let index = inputNames.firstIndex(of: name) else { return }
        let uid = inputUIDs[index]
        closeInput(uid: uid)
    }

    /// Close input
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
        guard let name = inputName(for: inputUID) else {
            Log("Trying to close midi input \(inputUID), but no name was found", log: OSLog.midi)
            return
        }
        Log("Closing MIDI Input '\(name)'", log: OSLog.midi)
        var result = noErr
        for uid in inputPorts.keys {
            if inputUID == 0 || uid == inputUID {
                if let port = inputPorts[uid], let endpoint = endpoints[uid] {
                    result = MIDIPortDisconnectSource(port, endpoint)
                    if result == noErr {
                        endpoints.removeValue(forKey: uid)
                        inputPorts.removeValue(forKey: uid)
                        Log("Disconnected \(name) and removed it from endpoints and input ports", log: OSLog.midi)
                    } else {
                        Log("Error disconnecting MIDI port: \(result)", log: OSLog.midi, type: .error)
                    }
                    result = MIDIPortDispose(port)
                    if result == noErr {
                        Log("Disposed \(name)", log: OSLog.midi)
                    } else {
                        Log("Error displosing  MIDI port: \(result)", log: OSLog.midi, type: .error)
                    }
                }
            }
        }
    }

    /// Close all MIDI Input ports
    public func closeAllInputs() {
        Log("Closing All Inputs", log: OSLog.midi)
        for index in 0 ..< MIDISources().endIndex {
            closeInput(index: index)
        }
    }

    internal func handleMIDIMessage(_ event: MIDIEvent, fromInput portID: MIDIUniqueID) {
        for listener in listeners {
            let timeStamp = event.timeStamp
            if let type = event.status?.type {
                guard let eventChannel = event.channel else {
                    Log("No channel detected in handleMIDIMessage", log: OSLog.midi)
                    continue
                }
                switch type {
                case .controllerChange:
                    listener.receivedMIDIController(event.data[1],
                                                    value: event.data[2],
                                                    channel: MIDIChannel(eventChannel),
                                                    portID: portID,
                                                    timeStamp: timeStamp)
                case .channelAftertouch:
                    listener.receivedMIDIAftertouch(event.data[1],
                                                    channel: MIDIChannel(eventChannel),
                                                    portID: portID,
                                                    timeStamp: timeStamp)
                case .noteOn:
                    listener.receivedMIDINoteOn(noteNumber: MIDINoteNumber(event.data[1]),
                                                velocity: MIDIVelocity(event.data[2]),
                                                channel: MIDIChannel(eventChannel),
                                                portID: portID,
                                                timeStamp: timeStamp)
                case .noteOff:
                    listener.receivedMIDINoteOff(noteNumber: MIDINoteNumber(event.data[1]),
                                                 velocity: MIDIVelocity(event.data[2]),
                                                 channel: MIDIChannel(eventChannel),
                                                 portID: portID,
                                                 timeStamp: timeStamp)
                case .pitchWheel:
                    listener.receivedMIDIPitchWheel(event.pitchbendAmount ?? 0,
                                                    channel: MIDIChannel(eventChannel),
                                                    portID: portID,
                                                    timeStamp: timeStamp)
                case .polyphonicAftertouch:
                    listener.receivedMIDIAftertouch(noteNumber: MIDINoteNumber(event.data[1]),
                                                    pressure: event.data[2],
                                                    channel: MIDIChannel(eventChannel),
                                                    portID: portID,
                                                    timeStamp: timeStamp)
                case .programChange:
                    listener.receivedMIDIProgramChange(event.data[1],
                                                       channel: MIDIChannel(eventChannel),
                                                       portID: portID,
                                                       timeStamp: timeStamp)
                }
            } else if event.command != nil {
                listener.receivedMIDISystemCommand(event.data, portID: portID, timeStamp: timeStamp )
            } else {
                Log("No usable status detected in handleMIDIMessage", log: OSLog.midi)
            }
        }
    }

    internal func transformMIDIEventList(_ eventList: [MIDIEvent]) -> [MIDIEvent] {
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

#endif
