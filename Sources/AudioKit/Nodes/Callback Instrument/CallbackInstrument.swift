// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import AVFoundation
import CAudioKit

public typealias AKCallback = () -> Void

#if !os(tvOS)
import Foundation

/// Function type for MIDI callbacks
public typealias AKMIDICallback = (MIDIByte, MIDIByte, MIDIByte) -> Void

/// New sample-accurate version of AKCallbackInstrument
/// Old AKCallbackInstrument renamed to AKMIDICallbackInstrument
/// If you have used this before, you should be able to simply switch to AKMIDICallbackInstrument
open class AKCallbackInstrument: AKPolyphonicNode, AKComponent {

    public typealias AKAudioUnitType = InternalAU
    /// Four letter unique description of the node
    public static let ComponentDescription = AudioComponentDescription(instrument: "clbk")

    // MARK: - Properties

    public private(set) var internalAU: AKAudioUnitType?

    public class InternalAU: AKAudioUnitBase {

        public override func createDSP() -> AKDSPRef {
            akCreateDSP("AKCallbackInstrumentDSP")
        }
        
        public func setCallback(_ callback: AKMIDICallback?) {
            akCallbackInstrumentSetCallback(dsp, callback)
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
            self.internalAU?.setCallback(callback)
        }
    }

}
#endif
