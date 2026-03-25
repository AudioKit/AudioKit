// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

#if !os(tvOS)
import CoreMIDI
import os.log

/// MIDI input and output handler
@MainActor
public class MIDI {

    /// Shared singleton
    nonisolated(unsafe) public static let sharedInstance = MIDI()

    // MARK: - Properties

    /// MIDI Client Reference
    nonisolated(unsafe) public var client = MIDIClientRef()

    /// MIDI Client Name
    nonisolated(unsafe) internal let clientName: CFString = "AudioKit" as CFString

    /// Array of MIDI In ports
    public var inputPorts = [MIDIUniqueID: MIDIPortRef]()

    /// Array of Virtual MIDI Input destination
    public var virtualInputs = [MIDIPortRef()]

    /// MIDI In Port Name
    internal let inputPortName: CFString = "MIDI In Port" as CFString

    /// MIDI Out Port Reference
    public var outputPort = MIDIPortRef()

    /// Array of Virtual MIDI output
    public var virtualOutputs = [MIDIPortRef()]

    /// MIDI Out Port Name
    var outputPortName: CFString = "MIDI Out Port" as CFString

    /// Array of MIDI Endpoints
    public var endpoints = [MIDIUniqueID: MIDIEndpointRef]()

    /// Array of all listeners
    public var listeners = [MIDIListener]()

    /// Array of all transformers
    public var transformers = [MIDITransformer]()

    // MARK: - Initialization

    /// Initialize the MIDI system
    nonisolated public init() {
        Log("Initializing MIDI", log: OSLog.midi)

        #if os(iOS)
        MIDINetworkSession.default().isEnabled = true
        MIDINetworkSession.default().connectionPolicy =
            MIDINetworkConnectionPolicy.anyone
        #endif

        if client == 0 {
            // Capture self without @MainActor isolation for use in CoreMIDI callbacks
            nonisolated(unsafe) let midi = self
            let result = MIDIClientCreateWithBlock(clientName, &client) { notification in
                let messageID = notification.pointee.messageID

                switch messageID {
                case .msgSetupChanged:
                    Task { @MainActor in
                        for listener in midi.listeners {
                            listener.receivedMIDISetupChange()
                        }
                    }
                case .msgPropertyChanged:
                    let rawPtr = UnsafeRawPointer(notification)
                    let propChange = rawPtr.assumingMemoryBound(to: MIDIObjectPropertyChangeNotification.self).pointee
                    nonisolated(unsafe) let propChangeCopy = propChange
                    Task { @MainActor in
                        for listener in midi.listeners {
                            listener.receivedMIDIPropertyChange(propertyChangeInfo: propChangeCopy)
                        }
                    }
                default:
                    let notificationValue = notification.pointee
                    Task { @MainActor in
                        for listener in midi.listeners {
                            listener.receivedMIDINotification(notification: notificationValue)
                        }
                    }
                }
            }
            if result != noErr {
                Log("Error creating MIDI client: \(result)", log: OSLog.midi, type: .error)
            }
        }
    }

    // MARK: - SYSEX

    nonisolated(unsafe) internal var isReceivingSysEx: Bool = false
    nonisolated func startReceivingSysEx(with midiBytes: [MIDIByte]) {
        Log("Starting to receive SysEx", log: OSLog.midi)
        isReceivingSysEx = true
        incomingSysEx = midiBytes
    }
    nonisolated func stopReceivingSysEx() {
        Log("Done receiving SysEx", log: OSLog.midi)
        isReceivingSysEx = false
    }
    nonisolated(unsafe) var incomingSysEx = [MIDIByte]()
    
    // I don't want to break logic of existing code for receiving SysEx messages,
    // So I use separate var for processUMPSysExMessage method
    nonisolated(unsafe) internal var incomingUMPSysExMessage = [UInt8]()
}
#endif
