// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

#if !os(tvOS)
import CoreMIDI
import os.log

extension MIDI {

    // MARK: - Virtual MIDI
    //
    // Virtual MIDI Goals
    //      * Simplicty in creating a virtual input and virtual output ports together
    //      * Simplicty in disposing of virtual ports together
    //      * Ability to create a single virtual input, or single virtual output
    //
    // Possible Improvements:
    //      * Support a greater numbers of virtual ports
    //      * Support hidden uuid generation so the caller can worry about less
    //


     /// Create set of virtual input and output MIDI ports
    public func createVirtualPorts(numberOfPort: Int = 1, _ uniqueIDs: [Int32]? = nil, names: [String]? = nil) {
        Log("Creating \(numberOfPort) virtual input and output ports", log: OSLog.midi)
        destroyVirtualPorts()
        createVirtualInputPorts(numberOfPort: numberOfPort, names: names)
        createVirtualOutputPorts(numberOfPort: numberOfPort, names: names)
    }

    /// Create virtual MIDI input ports
    public func createVirtualInputPorts(numberOfPort: Int = 1, _ uniqueIDs: [Int32]? = nil, names: [String]? = nil) {
        destroyVirtualInputPort()
        guard numberOfPort > 0 else { return Log("Error: Number of port to create can't be less than one)",
                                                 log: OSLog.midi, type: .error)}

        var unnamedPortIndex = 1
        var unIDPortIndex: Int32 = 0
        for virtualPortIndex in 0...numberOfPort - 1 {
            var virtualPortName: String
            var uniqueID: Int32
            if virtualPortIndex != 0 {virtualInputs.append(0)}

            if names?.count ?? 0 > virtualPortIndex, let portName = names?[virtualPortIndex] {
                virtualPortName = portName
            } else {
               virtualPortName = String("\(clientName) \(unnamedPortIndex)")
               unnamedPortIndex += 1
           }

            if uniqueIDs?.count ?? 0 > virtualPortIndex, let portID = uniqueIDs?[virtualPortIndex] {
                uniqueID = portID
            } else {
                uniqueID = 2_000_000 + unIDPortIndex
                unIDPortIndex += 2
           }

            let result = MIDIDestinationCreateWithBlock(
            client,
            virtualPortName as CFString,
            &virtualInputs[virtualPortIndex]) { packetList, _ in
                for packet in packetList.pointee {
                    // a Core MIDI packet may contain multiple MIDI events
                    for event in packet {
                        self.handleMIDIMessage(event, fromInput: uniqueID)
                    }
                }
            }

            if result == noErr {
                MIDIObjectSetIntegerProperty(virtualInputs[virtualPortIndex], kMIDIPropertyUniqueID, uniqueID)
            } else {
                Log("Error \(result) Creating Virtual Input Port: \(virtualPortName) -- \(virtualInputs[virtualPortIndex])",
                log: OSLog.midi, type: .error)
                CheckError(result)
            }
        }
    }

    /// Create virtual MIDI output ports
    public func createVirtualOutputPorts(numberOfPort: Int = 1, _ uniqueIDs: [Int32]? = nil, names: [String]? = nil) {
        destroyVirtualOutputPort()
        guard numberOfPort > 0 else { return Log("Error: Number of port to create can't be less than one)",
                                                 log: OSLog.midi, type: .error)}
        var unnamedPortIndex = 1
        var unIDPortIndex: Int32 = 0
        for virtualPortIndex in 0...numberOfPort - 1 {
            var virtualPortName: String
            var uniqueID: Int32
            if virtualPortIndex != 0 {virtualOutputs.append(0)}

            if names?.count ?? 0 > virtualPortIndex, let portName = names?[virtualPortIndex] {
                virtualPortName = portName
            } else {
               virtualPortName = String("\(clientName) \(unnamedPortIndex)")
               unnamedPortIndex += 1
           }

            if uniqueIDs?.count ?? 0 > virtualPortIndex, let portID = uniqueIDs?[virtualPortIndex] {
                uniqueID = portID
            } else {
                uniqueID = 2_000_001 + unIDPortIndex
                unIDPortIndex += 2
           }
           let result = MIDISourceCreate(client, virtualPortName as CFString, &virtualOutputs[virtualPortIndex])
            if result == noErr {
                MIDIObjectSetIntegerProperty(virtualOutputs[virtualPortIndex], kMIDIPropertyUniqueID, uniqueID)
            } else {
                Log("Error \(result) Creating Virtual Output Port: \(virtualPortName) -- \(virtualOutputs[virtualPortIndex])",
                log: OSLog.midi, type: .error)
                CheckError(result)
            }
        }
    }

    /// Discard all virtual ports
    public func destroyVirtualPorts() {
        destroyVirtualInputPort()
        destroyVirtualOutputPort()
    }

    /// Closes the virtual input ports, if created one already.
    ///
    /// - Returns: Returns true if virtual inputs closed.
    ///
    @discardableResult public func destroyVirtualInputPort() -> Bool {
        if virtualInputs != [0] {
            for (index, virtualInput) in virtualInputs.enumerated().reversed() {
                guard MIDIEndpointDispose(virtualInput) == noErr else {return false}
                virtualInputs.remove(at: index)
            }
            virtualInputs.append(0)
            return true
            }
        return false
    }

    /// Closes the virtual output ports, if created one already.
    ///
    /// - Returns: Returns true if virtual outputs closed.
    ///
    @discardableResult public func destroyVirtualOutputPort() -> Bool {
        if virtualOutputs != [0] {
            for (index, virtualOutput) in virtualOutputs.enumerated().reversed() {
                guard MIDIEndpointDispose(virtualOutput) == noErr else {return false}
                virtualOutputs.remove(at: index)
            }
            virtualOutputs.append(0)
            return true
        }
        return false
    }
}

#endif
