// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

#if !os(tvOS)
import AVFoundation

/// STK Tubuluar Bells
///
public class TubularBells: Node, MIDITriggerable {
    
    /// Connected nodes
    public var connections: [Node] { [] }
    
    /// Underlying AVAudioNode
    public var avAudioNode = instantiate(instrument: "tbel")

    /// Initialize the STK Tubular Bells model
    public init() { }
}
#endif
