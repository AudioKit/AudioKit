// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import AVFoundation

/// STK Flute
///
public class Flute: Node, MIDITriggerable {
    
    /// Connected nodes
    public var connections: [Node] { [] }
    
    /// Underlying AVAudioNode
    public var avAudioNode = instantiate(instrument: "flut")

    /// Initialize the STK Flute model
    public init() {}
}
