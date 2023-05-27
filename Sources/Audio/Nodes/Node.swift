// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import AVFoundation

/// Node in an audio graph.
public protocol Node: AnyObject {
    /// Nodes providing audio input to this node.
    var connections: [Node] { get }

    /// Tells whether the node is processing (ie. started, playing, or active)
    var isStarted: Bool { get }

    /// The underlying audio unit.
    var au: AUAudioUnit { get }
}
