// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import AVFAudio

/// Describes a way to connect a node to another node
public enum ConnectStrategy {
    /// Traverses all existing connections of target node
    case complete
    /// Traverses only newly added node and connects it
    case incremental
}
