// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/
#if !os(tvOS)

import AVFoundation

/// STK Mandole
///
public class MandolinString: Node, MIDITriggerable {

    /// Connected nodes
    public var connections: [Node] { [] }
    
    /// Underlying AVAudioNode
    public var avAudioNode = instantiate(instrument: "mand")
    
    /// Initialize the STK Mandolin model
    public init() {}
}
#endif
