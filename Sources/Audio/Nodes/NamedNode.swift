// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import Foundation

/// Protocol to allow nice printouts for debugging connections
public protocol NamedNode where Self: Node {
    /// User-friendly name for the node
    var name: String { get set }
}
