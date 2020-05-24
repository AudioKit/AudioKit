// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

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

    open var callback: AKMIDICallback = { status, data1, data2 in } {
        willSet {
            internalAU?.callback = newValue
        }
    }
    // MARK: - Initialization

    @objc public init(midiCallback: AKMIDICallback? = nil) {

        _Self.register()

        super.init(avAudioNode: AVAudioNode())

        AVAudioUnit._instantiate(with: _Self.ComponentDescription) { [weak self] avAudioUnit in
            guard let strongSelf = self else {
                AKLog("Error: self is nil")
                return
            }
            strongSelf.avAudioUnit = avAudioUnit
            strongSelf.avAudioNode = avAudioUnit
            self?.midiInstrument = avAudioUnit as? AVAudioUnitMIDIInstrument
            strongSelf.internalAU = avAudioUnit.auAudioUnit as? AKAudioUnitType

        }
        if let callback = midiCallback {
            self.callback = callback
        }
    }

    open override func play(noteNumber: MIDINoteNumber, velocity: MIDIVelocity, channel: MIDIChannel) {
        internalAU?.startNote(noteNumber, velocity: velocity)
    }

    open override func stop(noteNumber: MIDINoteNumber) {
        internalAU?.stopNote(noteNumber)
    }

    deinit {
        internalAU?.destroy()
    }
}
