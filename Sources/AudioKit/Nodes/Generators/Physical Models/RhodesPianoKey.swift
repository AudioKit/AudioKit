// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/
#if !os(tvOS)

import AVFoundation

/// STK Rhodes Piano
///
public class RhodesPianoKey: Node, MIDITriggerable {

    /// Connected nodes
    public var connections: [Node] { [] }
    
    /// Underlying AVAudioNode
    public var avAudioNode = instantiate(instrument: "rhds")
    
    /// Initialize the STK Rhodes Piano model
    public init() {}
}
#endif
