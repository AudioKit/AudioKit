// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import Foundation

extension Node {

    public func printConnectionTree(paddedWith prefix: String = "") {
        var nodeDescription = String(describing: self).components(separatedBy: ".").last ?? "Unknown"

        if let namedSelf = self as? NamedNode {
            nodeDescription += "(\"\(namedSelf.name)\")"
        }
        print("AudioKit |\(prefix)↳\(nodeDescription)")

        for connectionNode in self.connections {
            connectionNode.printConnectionTree(paddedWith: " "+prefix)
        }
    }

}
