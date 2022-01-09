// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

/// Keep track of a node status
public enum NodeStatus {
    /// Node status for a playback node
    public enum Playback {
        /// The node is stopped
        case stopped
        /// The node is playing
        case playing
        /// The node is paused
        case paused
        /// The node is scheduling
        case scheduling
    }
}
