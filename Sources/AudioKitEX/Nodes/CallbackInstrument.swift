// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import AVFoundation
import CAudioKitEX
import AudioKit

#if !os(tvOS)
import Foundation

/// New sample-accurate version of CallbackInstrument
/// Old CallbackInstrument renamed to MIDICallbackInstrument
/// If you have used this before, you should be able to simply switch to MIDICallbackInstrument
open class CallbackInstrument: Node {
    
    /// Connected nodes
    public var connections: [Node] { [] }

    /// Underlying AVAudioNode
    public var avAudioNode = instantiate(instrument: "clbk")

    /// Initialize the callback instrument
    /// - Parameter midiCallback: Optional MIDI Callback
    public init(midiCallback: MIDICallback? = nil) {
        
        if let callback = midiCallback {
            akCallbackInstrumentSetCallback(au.dsp, callback)
        }
    }

}
#endif
