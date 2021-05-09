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
open class CallbackInstrument: NodeBase {

    /// Initialize the callback instrument
    /// - Parameter midiCallback: Optional MIDI Callback
    public init(midiCallback: MIDICallback? = nil) {

        super.init(avAudioNode: AVAudioNode())
        
        avAudioNode = instantiate(instrument: "clbk")
        
        if let callback = midiCallback, let audioUnit = avAudioNode.auAudioUnit as? AudioUnitBase {
            akCallbackInstrumentSetCallback(audioUnit.dsp, callback)
        }
    }

}
#endif
