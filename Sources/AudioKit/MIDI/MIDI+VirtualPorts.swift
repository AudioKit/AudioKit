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
    public func createVirtualPorts(_ uniqueID: Int32 = 2_000_000, name: String? = nil) {
        Log("Creating virtual input and output ports", log: OSLog.midi)
        destroyVirtualPorts()
        createVirtualInputPort(name: name)
        createVirtualOutputPort(name: name)
    }

    /// Create a virtual MIDI input port
    public func createVirtualInputPort(_ uniqueID: Int32 = 2_000_000, name: String? = nil) {
        destroyVirtualInputPort()
        let virtualPortname = name ?? String(clientName)

        let result = MIDIDestinationCreateWithBlock(
            client,
            virtualPortname as CFString,
            &virtualInputs[0]) { packetList, _ in
                for packet in packetList.pointee {
                    // a Core MIDI packet may contain multiple MIDI events
                    for event in packet {
                        self.handleMIDIMessage(event, fromInput: uniqueID)
                    }
                }
        }

        if result == noErr {
            MIDIObjectSetIntegerProperty(virtualInputs[0], kMIDIPropertyUniqueID, uniqueID)
        } else {
            Log("Error \(result) Creating Virtual Input Port: \(virtualPortname) -- \(virtualInputs[0])",
                log: OSLog.midi, type: .error)
            CheckError(result)
        }
    }

    /// Create a virtual MIDI output port
    public func createVirtualOutputPort(_ uniqueID: Int32 = 2_000_001, name: String? = nil) {
        destroyVirtualOutputPort()
        let virtualPortname = name ?? String(clientName)

        let result = MIDISourceCreate(client, virtualPortname as CFString, &virtualOutputs[0])
        if result == noErr {
            MIDIObjectSetIntegerProperty(virtualInputs[0], kMIDIPropertyUniqueID, uniqueID)
        } else {
            Log("Error \(result) Creating Virtual Output Port: \(virtualPortname) -- \(virtualOutputs[0])",
                log: OSLog.midi, type: .error)
            CheckError(result)
        }
    }

     /// Create multiple set of virtual input and output MIDI ports
    public func createMultipleVirtualPorts(_ uniqueIDs: [Int32]? = nil, names: [String]? = nil) {
        Log("Creating multiple virtual input and output ports", log: OSLog.midi)
        destroyVirtualPorts()
        createMultipleVirtualInputPorts(names: names)
        createMultipleVirtualOutputPorts(names: names)
    }

    /// Create multiple virtual MIDI input ports
    public func createMultipleVirtualInputPorts(numberOfPorts: Int = 2, _ uniqueIDs: [Int32]? = nil, names: [String]? = nil) {
        destroyVirtualInputPort()

        var unnamedPortIndex = 1
        var unIDPortIndex: Int32 = 0
        for virtualPortIndex in 1...numberOfPorts {
            var virtualPortName: String
            var uniqueID: Int32
            
            if names?[virtualPortIndex] != nil {
                virtualPortName = names![virtualPortIndex]
            } else {
               virtualPortName = String("\(clientName) \(unnamedPortIndex)")
               unnamedPortIndex += 1
           }

            if uniqueIDs?[virtualPortIndex] != nil {
                uniqueID = uniqueIDs![virtualPortIndex]
            } else {
                uniqueID = 2_000_001 + unIDPortIndex
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

    /// Create multiple virtual MIDI output ports
    public func createMultipleVirtualOutputPorts(numberOfPorts: Int = 2,_ uniqueIDs: [Int32]? = nil, names: [String]? = nil) {
        destroyVirtualOutputPort()
        var unnamedPortIndex = 1
        var unIDPortIndex: Int32 = 0
        for virtualPortIndex in 1...numberOfPorts {
            var virtualPortName: String
            var uniqueID: Int32
            
            if names?[virtualPortIndex] != nil {
                virtualPortName = names![virtualPortIndex]
            } else {
               virtualPortName = String("\(clientName) \(unnamedPortIndex)")
               unnamedPortIndex += 1
           }

            if uniqueIDs?[virtualPortIndex] != nil {
                uniqueID = uniqueIDs![virtualPortIndex]
            } else {
                uniqueID = 2_000_001 + unIDPortIndex
                unIDPortIndex += 2
           }
           let result = MIDISourceCreate(client, virtualPortName as CFString, &virtualOutputs[virtualPortIndex])
            if result == noErr {
                MIDIObjectSetIntegerProperty(virtualInputs[virtualPortIndex], kMIDIPropertyUniqueID, uniqueID)
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

    /// Closes the virtual input port, if created one already.
    ///
    /// - Returns: Returns true if virtual input closed.
    ///
    @discardableResult public func destroyVirtualInputPort() -> Bool {
        if virtualInputs[0] != 0 {
            if MIDIEndpointDispose(virtualInputs[0]) == noErr {
                virtualInputs[0] = 0
                return true
            }
        }
        return false
    }

    /// Closes the virtual output port, if created one already.
    ///
    /// - Returns: Returns true if virtual output closed.
    ///
    @discardableResult public func destroyVirtualOutputPort() -> Bool {
        if virtualOutputs[0] != 0 {
            if MIDIEndpointDispose(virtualOutputs[0]) == noErr {
                virtualOutputs[0] = 0
                return true
            }
        }
        return false
    }
}

#endif
