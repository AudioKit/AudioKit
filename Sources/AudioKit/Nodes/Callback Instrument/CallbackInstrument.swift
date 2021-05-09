// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import AVFoundation
import CAudioKit

#if !os(tvOS)
import Foundation

/// Function type for MIDI callbacks
public typealias MIDICallback = (MIDIByte, MIDIByte, MIDIByte) -> Void

/// New sample-accurate version of CallbackInstrument
/// Old CallbackInstrument renamed to MIDICallbackInstrument
/// If you have used this before, you should be able to simply switch to MIDICallbackInstrument
open class CallbackInstrument: NodeBase, AudioUnitContainer {

    /// Four letter unique description "clbk"
    public static let ComponentDescription = AudioComponentDescription(instrument: "clbk")

    /// Internal audio unit type
    public typealias AudioUnitType = AudioUnitBase

    /// Internal audio unit
    public private(set) var internalAU: AudioUnitType?

    // MARK: - Initialization

    /// Initialize the callback instrument
    /// - Parameter midiCallback: Optional MIDI Callback
    public init(midiCallback: MIDICallback? = nil) {

        super.init(avAudioNode: AVAudioNode())

        instantiateAudioUnit { avAudioUnit in
            self.avAudioNode = avAudioUnit
            self.internalAU = avAudioUnit.auAudioUnit as? AudioUnitType

        }
        if let callback = midiCallback, let audioUnit = internalAU {
            akCallbackInstrumentSetCallback(audioUnit.dsp, callback)
        }
    }

}
#endif
