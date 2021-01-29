// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

#if !os(tvOS)
import CoreMIDI
import os.log

/// MIDI input and output handler
public class MIDI {

    /// Shared singleton
    public static var sharedInstance = MIDI()

    // MARK: - Properties

    /// MIDI Client Reference
    public var client = MIDIClientRef()

    /// MIDI Client Name
    internal let clientName: CFString = "MIDI Client" as CFString

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
    public init() {
        Log("Initializing MIDI", log: OSLog.midi)

        #if os(iOS)
        MIDINetworkSession.default().isEnabled = true
        MIDINetworkSession.default().connectionPolicy =
            MIDINetworkConnectionPolicy.anyone
        #endif

        if client == 0 {
            let result = MIDIClientCreateWithBlock(clientName, &client) {
                let messageID = $0.pointee.messageID

                switch messageID {
                case .msgSetupChanged:
                    for listener in self.listeners {
                        listener.receivedMIDISetupChange()
                    }
                case .msgPropertyChanged:
                    let rawPtr = UnsafeRawPointer($0)
                    let propChange = rawPtr.assumingMemoryBound(to: MIDIObjectPropertyChangeNotification.self).pointee
                    for listener in self.listeners {
                        listener.receivedMIDIPropertyChange(propertyChangeInfo: propChange)
                    }
                default:
                    for listener in self.listeners {
                        listener.receivedMIDINotification(notification: $0.pointee)
                    }
                }
            }
            if result != noErr {
                Log("Error creating MIDI client: \(result)", log: OSLog.midi, type: .error)
            }
        }
    }

    // MARK: - SYSEX

    internal var isReceivingSysEx: Bool = false
    func startReceivingSysEx(with midiBytes: [MIDIByte]) {
        Log("Starting to receive SysEx", log: OSLog.midi)
        isReceivingSysEx = true
        incomingSysEx = midiBytes
    }
    func stopReceivingSysEx() {
        Log("Done receiving SysEx", log: OSLog.midi)
        isReceivingSysEx = false
    }
    var incomingSysEx = [MIDIByte]()
    
    // I don't want to break logic of existing code for receiving SysEx messages,
    // So I use separate var for processUMPSysExMessage method
    internal var incomigUMPSysExMessage = [UInt8]()
}
#endif
