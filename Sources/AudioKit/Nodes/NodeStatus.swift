// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

/// An Enum which keeps track of Node states (i.e. is it playing, is it paused, etc.).
/// Can be used with various Node classes as needed.

public enum NodeStatus {
    case stopped, playing, paused, running
}
