// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import Foundation

public protocol NamedNode where Self: Node {
    var name: String? { get set }
}
