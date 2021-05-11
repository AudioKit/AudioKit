// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/
#if !os(tvOS)

import AVFoundation

/// STK Clarinet
///
public class Clarinet: Node, MIDITriggerable {

    /// Connected nodes
    public var connections: [Node] { [] }
    
    /// Underlying AVAudioNode
    public var avAudioNode = instantiate(instrument: "clar")
    
    /// Initialize the STK Clarinet model
    public init() {}
}
#endif
