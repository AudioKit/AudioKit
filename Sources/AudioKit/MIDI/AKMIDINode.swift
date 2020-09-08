// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

#if !os(tvOS)
import AVFoundation
import CoreAudio

/// A version of AKInstrument specifically targeted to instruments that
/// should be triggerable via MIDI or sequenced with the sequencer.
open class AKMIDINode: AKNode, AKMIDIListener {

    // MARK: - Properties

    /// MIDI Input
    open var midiIn = MIDIEndpointRef()

    /// Name of the instrument
    open var name = "AKMIDINode"

    private var internalNode: AKPolyphonicNode

    // MARK: - Initialization

    /// Initialize the MIDI node
    ///
    /// - parameter node: A polyphonic node that will be triggered via MIDI
    /// - parameter midiOutputName: Name of the node's MIDI output
    ///
    public init(node: AKPolyphonicNode, midiOutputName: String? = nil) {
        internalNode = node
        super.init(avAudioNode: AVAudioNode())
        avAudioNode = internalNode.avAudioNode
        avAudioUnit = internalNode.avAudioUnit
      enableMIDI(name: midiOutputName ?? "Unnamed")
    }

    /// Enable MIDI input from a given MIDI client
    ///
    /// - Parameters:
    ///   - midiClient: A reference to the midi client
    ///   - name: Name to connect with
    ///
    public func enableMIDI(_ midiClient: MIDIClientRef = AKMIDI.sharedInstance.client,
                           name: String = "Unnamed") {
        CheckError(MIDIDestinationCreateWithBlock(midiClient, name as CFString, &midiIn) { packetList, _ in
            for e in packetList.pointee {
                let event = AKMIDIEvent(packet: e)
                guard event.data.count > 2 else {
                    return
                }
                self.handleMIDI(data1: event.data[0],
                                data2: event.data[1],
                                data3: event.data[2])

            }
        })
    }

    // MARK: - Handling MIDI Data

    // Send MIDI data to the audio unit
    func handleMIDI(data1: MIDIByte, data2: MIDIByte, data3: MIDIByte) {
        let status = AKMIDIStatus(byte: data1)
        let channel = status?.channel
        let noteNumber = MIDINoteNumber(data2)
        let velocity = MIDIVelocity(data3)

        if status?.type == .noteOn && velocity > 0 {
            internalNode.play(noteNumber: noteNumber, velocity: velocity, channel: channel ?? 0)
        } else if status?.type == .noteOn && velocity == 0 {
            internalNode.stop(noteNumber: noteNumber)
        } else if status?.type == .noteOff {
            internalNode.stop(noteNumber: noteNumber)
        }
    }

    public func receivedMIDINoteOn(noteNumber: MIDINoteNumber, velocity: MIDIVelocity, channel: MIDIChannel, portID: MIDIUniqueID?, offset: MIDITimeStamp) {
        if velocity > 0 {
            internalNode.play(noteNumber: noteNumber, velocity: velocity, channel: channel)
        } else {
            internalNode.stop(noteNumber: noteNumber)
        }
    }

    public func receivedMIDINoteOff(noteNumber: MIDINoteNumber, velocity: MIDIVelocity, channel: MIDIChannel, portID: MIDIUniqueID?, offset: MIDITimeStamp) {
        // Do nothing
    }

    public func receivedMIDIController(_ controller: MIDIByte, value: MIDIByte, channel: MIDIChannel, portID: MIDIUniqueID?, offset: MIDITimeStamp) {
        // Do nothing
    }

    public func receivedMIDIAftertouch(noteNumber: MIDINoteNumber, pressure: MIDIByte, channel: MIDIChannel, portID: MIDIUniqueID?, offset: MIDITimeStamp) {
        // Do nothing
    }

    public func receivedMIDIAftertouch(_ pressure: MIDIByte, channel: MIDIChannel, portID: MIDIUniqueID?, offset: MIDITimeStamp) {
        // Do nothing
    }

    public func receivedMIDIPitchWheel(_ pitchWheelValue: MIDIWord, channel: MIDIChannel, portID: MIDIUniqueID?, offset: MIDITimeStamp) {
        // Do nothing
    }

    public func receivedMIDIProgramChange(_ program: MIDIByte, channel: MIDIChannel, portID: MIDIUniqueID?, offset: MIDITimeStamp) {
        // Do nothing
    }

    public func receivedMIDISystemCommand(_ data: [MIDIByte], portID: MIDIUniqueID?, offset: MIDITimeStamp) {
        // Do nothing
    }

    public func receivedMIDISetupChange() {
        // Do nothing
    }

    public func receivedMIDIPropertyChange(propertyChangeInfo: MIDIObjectPropertyChangeNotification) {
        // Do nothing
    }

    public func receivedMIDINotification(notification: MIDINotification) {
        // Do nothing
    }
}

#endif
