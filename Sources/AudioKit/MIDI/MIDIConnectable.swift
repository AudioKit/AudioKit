// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/
import AVFoundation

#if !os(tvOS)

/// Protocol for a node that can be connected to a MIDI client.
protocol MIDIConnectable {
    /// MIDI Input
    var midiIn: MIDIEndpointRef { get set }
    
    /// Enable MIDI input from a given MIDI client
    ///
    /// - Parameters:
    ///   - midiClient: A reference to the midi client
    ///   - name: Name to connect with
    ///
    func enableMIDI(_ midiClient: MIDIClientRef, name: String?)
    
    /// Discard all virtual ports
    func destroyEndpoint()
    
    func showVirtualMIDIPort()
    
    func hideVirtualMIDIPort()
}

#endif
