// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

#if !os(tvOS)
import Foundation

/// New sample-accurate version of AKCallbackInstrument
/// Old AKCallbackInstrument renamed to AKMIDICallbackInstrument
/// If you have used this before, you should be able to simply switch to AKMIDICallbackInstrument
open class AKCallbackInstrument: AKPolyphonicNode, AKComponent {

    public typealias AKAudioUnitType = AKCallbackInstrumentAudioUnit
    /// Four letter unique description of the node
    public static let ComponentDescription = AudioComponentDescription(instrument: "clbk")

    // MARK: - Properties

    public private(set) var internalAU: AKAudioUnitType?

    /// This will be called on the main thread when the node receives MIDI.
    open var callback: AKMIDICallback = { status, data1, data2 in } {
        willSet {
            internalAU?.callback = newValue
        }
    }
    // MARK: - Initialization

    public init(midiCallback: AKMIDICallback? = nil) {

        super.init(avAudioNode: AVAudioNode())

        instantiateAudioUnit { avAudioUnit in
            self.avAudioUnit = avAudioUnit
            self.avAudioNode = avAudioUnit
            self.midiInstrument = avAudioUnit as? AVAudioUnitMIDIInstrument
            self.internalAU = avAudioUnit.auAudioUnit as? AKAudioUnitType

        }
        if let callback = midiCallback {
            self.callback = callback
        }
    }

    deinit {
        internalAU?.destroy()
    }
}
#endif
