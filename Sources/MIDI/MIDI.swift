// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

#if !os(tvOS)
import os.log
import Utilities
@_exported import MIDIKitIO

/// MIDI input and output handler
public class MIDI {
    /// Shared singleton
    public static let shared = MIDI()

    // MARK: - Properties

    /// MIDI I/O Manager engine that provides all MIDI connectivity as well as device and endpoint metadata
    public var manager: MIDIManager
    
    /// Dictionary of Virtual MIDI Input destination
    public var virtualInputs: [String: MIDIInput] {
        manager.managedInputs
    }

    /// Dictionary of Virtual MIDI output
    public var virtualOutputs: [String: MIDIOutput] {
        manager.managedOutputs
    }

    /// Array of managed input connections to MIDI output ports
    public var inputConnections: [String: MIDIInputConnection] {
        manager.managedInputConnections
    }
    
    /// Array of managed input connections to MIDI output ports
    public var outputConnections: [String: MIDIOutputConnection] {
        manager.managedOutputConnections
    }

    /// MIDI Input and Output Endpoints
    public var endpoints: MIDIEndpointsProtocol {
        manager.endpoints
    }

    /// Array of all listeners
    public var listeners = [MIDIListener]()

    /// Array of all transformers
    public var transformers = [MIDITransformer]()

    // MARK: - Initialization

    /// Initialize the MIDI system
    public init() {
        Log("Initializing MIDI", log: OSLog.midi)

        #if os(iOS)
        MIDIKitIO.setMIDINetworkSession(policy: .anyone)
        #endif
        
        manager = MIDIManager(
            clientName: "AudioKit",
            model: "",
            manufacturer: ""
        )
        
        manager.notificationHandler = { [weak self] notification, manager in
            self?.listeners.forEach {
                $0.received(midiNotification: notification)
            }
        }
        
        do {
            try manager.start()
        } catch {
            Log("Error creating MIDI client: \(error.localizedDescription)",
                log: OSLog.midi,
                type: .error)
        }
    }
}
#endif
