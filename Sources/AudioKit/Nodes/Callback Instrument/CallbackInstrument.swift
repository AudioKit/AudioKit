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

    public typealias AudioUnitType = InternalAU
    /// Four letter unique description of the node
    public static let ComponentDescription = AudioComponentDescription(instrument: "clbk")

    // MARK: - Properties

    public private(set) var internalAU: AudioUnitType?

    public class InternalAU: AudioUnitBase {

        public override func createDSP() -> DSPRef {
            akCreateDSP("CallbackInstrumentDSP")
        }
        
        public func setCallback(_ callback: MIDICallback?) {
            akCallbackInstrumentSetCallback(dsp, callback)
        }
    }

    // MARK: - Initialization

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
