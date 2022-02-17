// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

#if !os(tvOS)
import CoreMIDI
import os.log

extension MIDI {

    // MARK: - Virtual MIDI
    //
    // Virtual MIDI Goals
    //      * Simplicity in creating a virtual input and virtual output ports together
    //      * Simplicity in disposing of virtual ports together
    //      * Ability to create a single virtual input, or single virtual output
    //
    // Possible Improvements:
    //      * Support a greater numbers of virtual ports
    //      * Support hidden uuid generation so the caller can worry about less (completed)
    //

    /// Array of virtual input ids
    public var virtualInputUIDs: [MIDIUniqueID] {
        var ids = [MIDIUniqueID]()
        for input in self.virtualInputs {
            ids.append(getMIDIObjectIntegerProperty(ref: input, property: kMIDIPropertyUniqueID))
            // Remove uninitialized ports
            ids.removeAll(where: {$0 == 0})
        }
        return ids
    }

    /// Array of virtual input names
    public var virtualInputNames: [String] {
        var names = [String]()
        for input in self.virtualInputs {
            names.append(getMIDIObjectStringProperty(ref: input, property: kMIDIPropertyName))
            // Remove uninitialized ports
            names.removeAll(where: {$0 == ""})
        }
        return names
    }

    /// Array of virtual output ids
    public var virtualOutputUIDs: [MIDIUniqueID] {
        var ids = [MIDIUniqueID]()
        for output in self.virtualOutputs {
            ids.append(getMIDIObjectIntegerProperty(ref: output, property: kMIDIPropertyUniqueID))
            // Remove uninitialized ports
            ids.removeAll(where: {$0 == 0})
        }
        return ids
    }

    /// Array of virtual output names
    public var virtualOutputNames: [String] {
        var names = [String]()
        for output in self.virtualOutputs {
            names.append(getMIDIObjectStringProperty(ref: output, property: kMIDIPropertyName))
            // Remove uninitialized ports
            names.removeAll(where: {$0 == ""})
        }
        return names
    }

    /// Create set of virtual input and output MIDI ports
    /// - Parameters:
    ///   - count: Number of ports to create (default: 1 Virtual Input and 1 Virtual Output)
    ///   - inputPortIDs: Optional list of UIDs for the input port(s) (otherwise they are automatically generated)
    ///   - outputPortIDs: Optional list of UIDs for the output port(s) (otherwise they are automatically generated)
    ///   - inputPortNames: Optional list of names for the input port(s) (otherwise they are automatically generated)
    ///   - outputPortNames: Optional list of names for the output port(s) (otherwise they are automatically generated)
    public func createVirtualPorts(count: Int = 1,
                                   inputPortIDs: [Int32]? = nil,
                                   outputPortIDs: [Int32]? = nil,
                                   inputPortNames: [String]? = nil,
                                   outputPortNames: [String]? = nil) {
        guard count > 0 else {
            return Log("Error: Number of port to create can't be less than one)", log: OSLog.midi, type: .error)
        }

        Log("Creating \(count) virtual input and output ports", log: OSLog.midi)
        createVirtualInputPorts(count: count, uniqueIDs: inputPortIDs, names: inputPortNames)
        createVirtualOutputPorts(count: count, uniqueIDs: outputPortIDs, names: outputPortNames)
    }

    /// Create virtual MIDI input ports (ports sending to AudioKit)
    /// - Parameters:
    ///   - count: Number of ports to create (default: 1)
    ///   - uniqueIDs: Optional list of IDs (otherwise they are automatically generated)
    ///   - names: Optional list of names (otherwise they are automatically generated)
    public func createVirtualInputPorts(count: Int = 1, uniqueIDs: [Int32]? = nil, names: [String]? = nil) {
        guard count > 0 else { return Log("Error: Number of port to create can't be less than one)",
                                          log: OSLog.midi, type: .error)}
        let currentPortCount = self.virtualInputs.count
        let startIndex = currentPortCount - 1
        let endIndex = startIndex + (count - 1)
        var unnamedPortIndex = startIndex + 1
        var unIDPortIndex: Int32 = Int32(startIndex)
        for virtualPortIndex in startIndex...(endIndex) {
            var virtualPortName: String
            var uniqueID: Int32
            virtualInputs.append(0)

            if names?.count ?? 0 > virtualPortIndex, let portName = names?[virtualPortIndex] {
                virtualPortName = portName
            } else {
                virtualPortName = String("\(clientName) Input \(unnamedPortIndex)")
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
                Log(
                    """
                    Error \(result) Creating Virtual Input Port:
                    \(virtualPortName) --
                    \(virtualInputs[virtualPortIndex])
                    """,
                    log: OSLog.midi, type: .error
                )
                CheckError(result)
            }
        }
    }

    /// Create virtual MIDI output ports (ports sending from AudioKit)
    /// - Parameters:
    ///   - count: Number of ports to create (default: 1)
    ///   - uniqueIDs: Optional list of IDs (otherwise they are automatically generated)
    ///   - names: Optional list of names (otherwise they are automatically generated)
    public func createVirtualOutputPorts(count: Int = 1, uniqueIDs: [Int32]? = nil, names: [String]? = nil) {
        guard count > 0 else { return Log("Error: Number of port to create can't be less than one)",
                                          log: OSLog.midi, type: .error)}
        let currentPortCount = self.virtualOutputs.count
        let startIndex = currentPortCount - 1
        let endIndex = startIndex + (count - 1)
        var unnamedPortIndex = startIndex + 1
        var unIDPortIndex: Int32 = Int32(startIndex)
        for virtualPortIndex in startIndex...(endIndex) {
            var virtualPortName: String
            var uniqueID: Int32
            virtualOutputs.append(0)

            if names?.count ?? 0 > virtualPortIndex, let portName = names?[virtualPortIndex] {
                virtualPortName = portName
            } else {
                virtualPortName = String("\(clientName) Output \(unnamedPortIndex)")
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
                Log(
                    """
                    Error \(result) Creating Virtual Output Port:
                    \(virtualPortName) --
                    \(virtualOutputs[virtualPortIndex])
                    """,
                    log: OSLog.midi, type: .error
                )
                CheckError(result)
            }
        }
    }

    /// Discard all virtual ports
    public func destroyAllVirtualPorts() {
        destroyAllVirtualInputPorts()
        destroyAllVirtualOutputPorts()
    }

    /// Closes the virtual input ports, if created one already.
    ///
    /// - Returns: Returns true if virtual inputs closed.
    ///
    @discardableResult public func destroyAllVirtualInputPorts() -> Bool {
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
    @discardableResult public func destroyAllVirtualOutputPorts() -> Bool {
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
