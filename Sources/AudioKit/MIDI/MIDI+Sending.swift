// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

#if !os(tvOS)

import os.log
import AVFoundation

private let sizeOfMIDIPacketList = MemoryLayout<MIDIPacketList>.size
private let sizeOfMIDIPacket = MemoryLayout<MIDIPacket>.size

/// The `MIDIPacketList` struct consists of two fields, numPackets(`UInt32`) and
/// packet(an Array of 1 instance of `MIDIPacket`). The packet is supposed to be a "An open-ended
/// array of variable-length MIDIPackets." but for convenience it is instantiated with
/// one instance of a `MIDIPacket`. To figure out the size of the header portion of this struct,
/// we can get the size of a UInt32, or subtract the size of a single packet from the size of a
/// packet list. I opted for the latter.
private let sizeOfMIDIPacketListHeader = sizeOfMIDIPacketList - sizeOfMIDIPacket

/// The MIDIPacket struct consists of a timestamp (`MIDITimeStamp`), a length (`UInt16`) and
/// data (an Array of 256 instances of `Byte`). The data field is supposed to be a "A variable-length
/// stream of MIDI messages." but for convenience it is instantiated as 256 bytes. To figure out the
/// size of the header portion of this struct, we can add the size of the `timestamp` and `length`
/// fields, or subtract the size of the 256 `Byte`s from the size of the whole packet. I opted for
/// the former.
private let sizeOfMIDIPacketHeader = MemoryLayout<MIDITimeStamp>.size + MemoryLayout<UInt16>.size
private let sizeOfMIDICombinedHeaders = sizeOfMIDIPacketListHeader + sizeOfMIDIPacketHeader

func MIDIOutputPort(client: MIDIClientRef, name: CFString) -> MIDIPortRef? {
    var port: MIDIPortRef = 0
    guard MIDIOutputPortCreate(client, name, &port) == noErr else {
        return nil
    }
    return port
}

internal extension Collection where Index == Int {
    var startIndex: Index {
        return 0
    }

    func index(after index: Index) -> Index {
        return index + 1
    }
}

internal struct MIDIDestinations: Collection {
    typealias Index = Int
    typealias Element = MIDIEndpointRef

    init() { }

    var endIndex: Index {
        return MIDIGetNumberOfDestinations()
    }

    subscript (index: Index) -> Element {
        return MIDIGetDestination(index)
    }
}

extension Collection where Iterator.Element == MIDIEndpointRef {
    var names: [String] {
        return map {
            getMIDIObjectStringProperty(ref: $0, property: kMIDIPropertyName)
        }
    }

    var uniqueIds: [MIDIUniqueID] {
        return map {
            getMIDIObjectIntegerProperty(ref: $0, property: kMIDIPropertyUniqueID)
        }
    }
    
    var endpointRefs: [MIDIEndpointRef] {
        return map {
            $0
        }
    }
}

internal func getMIDIObjectStringProperty(ref: MIDIObjectRef, property: CFString) -> String {
    var string: Unmanaged<CFString>?
    MIDIObjectGetStringProperty(ref, property, &string)
    if let returnString = string?.takeRetainedValue() {
        return returnString as String
    } else {
        return ""
    }
}

internal func getMIDIObjectIntegerProperty(ref: MIDIObjectRef, property: CFString) -> Int32 {
    var result: Int32 = 0
    MIDIObjectGetIntegerProperty(ref, property, &result)
    return result
}

extension MIDI {

    /// Array of destination unique ids
    public var destinationUIDs: [MIDIUniqueID] {
        var ids = MIDIDestinations().uniqueIds
        // Remove outputs which are actually virtual inputs to AudioKit
        for output in self.virtualInputs {
            let virtualId = getMIDIObjectIntegerProperty(ref: output, property: kMIDIPropertyUniqueID)
            ids.removeAll(where: { $0 == virtualId})
            // Add this UID to the inputUIDs
        }
        return ids
    }

    /// Array of destination names
    public var destinationNames: [String] {
        var names = MIDIDestinations().names
        // Remove outputs which are actually virtual inputs to AudioKit
        for output in self.virtualInputs {
            let virtualName = getMIDIObjectStringProperty(ref: output, property: kMIDIPropertyName)
            names.removeAll(where: { $0 == virtualName})
        }
        return names
    }
    
    /// Array of destination endpoint references
    public var destinationRefs: [MIDIEndpointRef] {
        var refs = MIDIDestinations().endpointRefs
        // Remove outputs which are actually virtual inputs to AudioKit
        for output in self.virtualInputs {
            refs.removeAll(where: { $0 == output })
        }
        return refs
    }

    /// Lookup a destination name from its unique id
    ///
    /// - Parameter forUid: unique id for a destination
    /// - Returns: name of destination or "Unknown"
    ///
    public func destinationName(for destUid: MIDIUniqueID) -> String {
        let name: String = zip(destinationNames, destinationUIDs).first { (arg: (String, MIDIUniqueID)) -> Bool in
                let (_, uid) = arg
                return destUid == uid
        }.map { (arg) -> String in
                let (name, _) = arg
                return name
        } ?? "Unknown"
        return name
    }

    /// Look up the unique id for a destination index
    ///
    /// - Parameter outputIndex: index of destination
    /// - Returns: unique identifier for the port
    ///
    public func uidForDestinationAtIndex(_ outputIndex: Int = 0) -> MIDIUniqueID {
        let endpoint: MIDIEndpointRef = MIDIDestinations()[outputIndex]
        let uid = getMIDIObjectIntegerProperty(ref: endpoint, property: kMIDIPropertyUniqueID)
        return uid
    }

    /// Open a MIDI Output Port by name
    ///
    /// - Parameter name: String containing the name of the MIDI Output
    ///
    @available(*, deprecated, message: "Try to not use names any more because they are not unique across devices")
    public func openOutput(name: String) {
        guard let index = destinationNames.firstIndex(of: name) else {
            openOutput(uid: 0)
            return
        }
        let uid = uidForDestinationAtIndex(index)
        openOutput(uid: uid)
    }

    /// Handle the acceptable default case of no parameter without causing a
    /// deprecation warning
    public func openOutput() {
        openOutput(uid: 0)
    }

    /// Open a MIDI Output Port by index
    ///
    /// - Parameter outputIndex: Index of destination endpoint
    ///
    public func openOutput(index outputIndex: Int) {
        guard outputIndex < destinationNames.count else {
            return
        }
        let uid = uidForDestinationAtIndex(outputIndex)
        openOutput(uid: uid)
    }

    ///
    /// Open a MIDI Output Port
    ///
    /// - parameter outputUid: Unique id of the MIDI Output
    ///
    public func openOutput(uid outputUid: MIDIUniqueID) {
        if outputPort == 0 {
            guard let tempPort = MIDIOutputPort(client: client, name: outputPortName) else {
                Log("Unable to create MIDIOutputPort", log: OSLog.midi, type: .error)
                return
            }
            outputPort = tempPort
        }

        // Since destinationUIDs filters out our own virtual inputs, we need to do the same with the endpoint refs.
        let destinations = destinationRefs

        // To get all endpoints; and set in endpoints array (mapping without condition)
        if outputUid == 0 {
            _ = zip(destinationUIDs, destinations).map {
                endpoints[$0] = $1
            }
        } else {
            // To get only [the FIRST] endpoint with name provided in output (conditional mapping)
            _ = zip(destinationUIDs, destinations).first { (arg: (MIDIUniqueID, MIDIDestinations.Element)) -> Bool in
                    let (uid, _) = arg
                    return outputUid == uid
            }.map {
                    endpoints[$0] = $1
            }
        }
    }

    /// Close a MIDI Output port by name
    ///
    /// - Parameter name: Name of port to close.
    ///
    public func closeOutput(name: String = "") {
        guard let index = destinationNames.firstIndex(of: name) else {
            return
        }
        let uid = uidForDestinationAtIndex(index)
        closeOutput(uid: uid)
    }

    /// Close a MIDI Output port by index
    ///
    /// - Parameter index: Index of destination port name
    ///
    public func closeOutput(index outputIndex: Int) {
        guard outputIndex < destinationNames.count else {
            return
        }
        let uid = uidForDestinationAtIndex(outputIndex)
        closeOutput(uid: uid)
    }

    /// Close a MIDI Output port
    ///
    /// - parameter inputName: Unique id of the MIDI Output
    ///
    public func closeOutput(uid outputUid: MIDIUniqueID) {
        let name = destinationName(for: outputUid)
        Log("Closing MIDI Output '\(String(describing: name))'", log: OSLog.midi)
        var result = noErr
        if endpoints[outputUid] != nil {
            endpoints.removeValue(forKey: outputUid)
            Log("Disconnected \(name) and removed it from endpoints", log: OSLog.midi)
            if endpoints.isEmpty {
                // if there are no more endpoints, dispose of midi output port
                result = MIDIPortDispose(outputPort)
                if result == noErr {
                    Log("Disposed MIDI Output port", log: OSLog.midi)
                } else {
                    Log("Error disposing  MIDI Output port: \(result)", log: OSLog.midi, type: .error)
                }
                outputPort = 0
            }
        }
    }

    /// Clear MIDI destinations
    public func clearEndpoints() {
        endpoints.removeAll()
    }

    /// Send Message from MIDI event data
    /// - Parameter event: Event so send
    public func sendEvent(_ event: MIDIEvent,
                          endpointsUIDs: [MIDIUniqueID]? = nil,
                          virtualOutputPorts: [MIDIPortRef]? = nil) {
        sendMessage(event.data, endpointsUIDs: endpointsUIDs, virtualOutputPorts: virtualOutputPorts)
    }

    /// Send a Note On Message
    /// - Parameters:
    ///   - noteNumber: MIDI Note Number
    ///   - velocity: MIDI Velocity
    ///   - channel: MIDI Channel (default: 0)
    ///   - time: MIDI Timestamp (default: mach_absolute_time(), note: time should never be 0)
    public func sendNoteOnMessage(noteNumber: MIDINoteNumber,
                                  velocity: MIDIVelocity,
                                  channel: MIDIChannel = 0,
                                  time: MIDITimeStamp = mach_absolute_time(),
                                  endpointsUIDs: [MIDIUniqueID]? = nil,
                                  virtualOutputPorts: [MIDIPortRef]? = nil) {
        let noteCommand: MIDIByte = noteOnByte + channel
        let message: [MIDIByte] = [noteCommand, noteNumber, velocity]
        self.sendMessage(message, time: time, endpointsUIDs: endpointsUIDs, virtualOutputPorts: virtualOutputPorts)
    }

    /// Send a Note Off Message
    /// - Parameters:
    ///   - noteNumber: MIDI Note Number
    ///   - channel: MIDI Channel (default: 0)
    ///   - time: MIDI Timestamp (default: mach_absolute_time(), note: time should never be 0)
    public func sendNoteOffMessage(noteNumber: MIDINoteNumber,
                                   channel: MIDIChannel = 0,
                                   time: MIDITimeStamp = mach_absolute_time(),
                                   endpointsUIDs: [MIDIUniqueID]? = nil,
                                   virtualOutputPorts: [MIDIPortRef]? = nil) {
        let noteCommand: MIDIByte = noteOffByte + channel
        let message: [MIDIByte] = [noteCommand, noteNumber, 0]
        self.sendMessage(message, time: time, endpointsUIDs: endpointsUIDs, virtualOutputPorts: virtualOutputPorts)
    }

    /// Send a Continuous Controller message
    /// - Parameters:
    ///   - control: MIDI Control number
    ///   - value: Value to assign
    ///   - channel: MIDI Channel (default: 0)
    public func sendControllerMessage(_ control: MIDIByte,
                                      value: MIDIByte,
                                      channel: MIDIChannel = 0,
                                      endpointsUIDs: [MIDIUniqueID]? = nil,
                                      virtualOutputPorts: [MIDIPortRef]? = nil) {
        let controlCommand: MIDIByte = MIDIByte(0xB0) + channel
        let message: [MIDIByte] = [controlCommand, control, value]
        self.sendMessage(message, endpointsUIDs: endpointsUIDs, virtualOutputPorts: virtualOutputPorts)
    }

    /// Send a pitch bend message.
    ///
    /// - Parameters:
    ///   - value: Value of pitch shifting between 0 and 16383. Send 8192 for no pitch bending.
    ///   - channel: Channel you want to send pitch bend message. Defaults 0.
    public func sendPitchBendMessage(value: UInt16,
                                     channel: MIDIChannel = 0,
                                     endpointsUIDs: [MIDIUniqueID]? = nil,
                                     virtualOutputPorts: [MIDIPortRef]? = nil) {
        let pitchCommand = MIDIByte(0xE0) + channel
        let mask: UInt16 = 0x007F
        let byte1 = MIDIByte(value & mask) // MSB, bit shift right 7
        let byte2 = MIDIByte((value & (mask << 7)) >> 7) // LSB, mask of 127
        let message: [MIDIByte] = [pitchCommand, byte1, byte2]
        self.sendMessage(message, endpointsUIDs: endpointsUIDs, virtualOutputPorts: virtualOutputPorts)
    }

    // MARK: - Expand api to include MIDITimeStamp

    /// Send Message with data with timestamp
    /// - Parameters:
    ///   - data: Array of MIDI Bytes
    ///   - time: MIDI Timestamp (default: mach_absolute_time(), note: time should never be 0)
    public func sendMessage(_ data: [MIDIByte],
                            time: MIDITimeStamp = mach_absolute_time(),
                            endpointsUIDs: [MIDIUniqueID]? = nil,
                            virtualOutputPorts: [MIDIPortRef]? = nil) {
        let packetListPointer: UnsafeMutablePointer<MIDIPacketList> = UnsafeMutablePointer.allocate(capacity: 1)

        var packet: UnsafeMutablePointer<MIDIPacket> = MIDIPacketListInit(packetListPointer)
        packet = MIDIPacketListAdd(packetListPointer, 1_024, packet, time, data.count, data)

        var endpointsRef: [MIDIEndpointRef] = []

        if let endpointsUIDS = endpointsUIDs {
            for endpointUID in endpointsUIDS {
                if let endpoint = endpoints[endpointUID] {endpointsRef.append(endpoint)}
            }
        } else {
            endpointsRef = Array(endpoints.values)
        }

        for endpoint in endpointsRef {
            let result = MIDISend(outputPort, endpoint, packetListPointer)
            if result != noErr {
                Log("error sending midi: \(result)", log: OSLog.midi, type: .error)
            }
        }

        if virtualOutputs != [0] {
            virtualOutputPorts?.forEach {MIDIReceived($0, packetListPointer)}
        }

        packetListPointer.deallocate()
    }
}

#endif
