// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

#if !os(tvOS)
import CoreMIDI
import os.log

extension AKMIDI {

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
        AKLog("Creating virtual input and output ports", log: OSLog.midi)
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
            &virtualInput) { packetList, _ in
                for packet in packetList.pointee {
                    // a Core MIDI packet may contain multiple MIDI events
                    for event in packet {
                        self.handleMIDIMessage(event, fromInput: uniqueID)
                    }
                }
        }

        if result == noErr {
            MIDIObjectSetIntegerProperty(virtualInput, kMIDIPropertyUniqueID, uniqueID)
        } else {
            AKLog("Error \(result) Creating Virtual Input Port: \(virtualPortname) -- \(virtualInput)",
                log: OSLog.midi, type: .error)
            CheckError(result)
        }
    }

    /// Create a virtual MIDI output port
    public func createVirtualOutputPort(_ uniqueID: Int32 = 2_000_001, name: String? = nil) {
        destroyVirtualOutputPort()
        let virtualPortname = name ?? String(clientName)

        let result = MIDISourceCreate(client, virtualPortname as CFString, &virtualOutput)
        if result == noErr {
            MIDIObjectSetIntegerProperty(virtualInput, kMIDIPropertyUniqueID, uniqueID)
        } else {
            AKLog("Error \(result) Creating Virtual Output Port: \(virtualPortname) -- \(virtualOutput)",
                log: OSLog.midi, type: .error)
            CheckError(result)
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
    ///
    @discardableResult public func destroyVirtualOutputPort() -> Bool {
        if virtualOutput != 0 {
            if MIDIEndpointDispose(virtualOutput) == noErr {
                virtualOutput = 0
                return true
            }
        }
        return false
    }
}

#endif
