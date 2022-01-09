// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

/// Keep track of a node status
public enum NodeStatus {
    /// Node status for a playback node
    public enum Playback {
        /// The player node is stopped.
        case stopped
        /// The player node is playing.
        case playing
        /// The player node is paused.
        case paused
        /// The player node is scheduling.
        case scheduling
    }
}
