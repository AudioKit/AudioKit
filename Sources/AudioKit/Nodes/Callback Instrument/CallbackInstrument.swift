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
open class CallbackInstrument: PolyphonicNode, AudioUnitContainer {

    /// Four letter unique description "clbk"
    public static let ComponentDescription = AudioComponentDescription(instrument: "clbk")

    /// Internal audio unit type
    public typealias AudioUnitType = InternalAU

    /// Internal audio unit
    public private(set) var internalAU: AudioUnitType?

    // MARK: - Internal Audio Unit

    /// Internal audio unit for callback instrument
    public class InternalAU: AudioUnitBase {

        /// Create the DSP Refence for this node
        /// - Returns: DSP Reference
        public override func createDSP() -> DSPRef {
            akCreateDSP("CallbackInstrumentDSP")
        }

        /// Set callback for the instrument
        /// - Parameter callback: MIDI Callback
        public func setCallback(_ callback: MIDICallback?) {
            akCallbackInstrumentSetCallback(dsp, callback)
        }
    }

    // MARK: - Initialization

    /// Initialize the callback instrument
    /// - Parameter midiCallback: Optional MIDI Callback
    public init(midiCallback: MIDICallback? = nil) {

        super.init(avAudioNode: AVAudioNode())

        instantiateAudioUnit { avAudioUnit in
            self.avAudioUnit = avAudioUnit
            self.avAudioNode = avAudioUnit
            self.midiInstrument = avAudioUnit as? AVAudioUnitMIDIInstrument
            self.internalAU = avAudioUnit.auAudioUnit as? AudioUnitType

        }
        if let callback = midiCallback {
            self.internalAU?.setCallback(callback)
        }
    }

}
#endif
