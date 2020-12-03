// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import Foundation

extension Node {

    static let connectionTreeLinePrefix = "AudioKit | "

    public var connectionTreeDescription: String {
        return String(createConnectionTreeDescription().dropLast())
    }

    private func createConnectionTreeDescription(paddedWith indentation: String = "") -> String {
        var nodeDescription = String(describing: self).components(separatedBy: ".").last ?? "Unknown"

        if let namedSelf = self as? NamedNode, let name = namedSelf.name {
            nodeDescription += "(\"\(name)\")"
        }

        var connectionTreeDescription = "\(Node.connectionTreeLinePrefix)\(indentation)↳\(nodeDescription)\n"
        for connectionNode in self.connections {
            connectionTreeDescription += connectionNode.createConnectionTreeDescription(paddedWith: " "+indentation)
        }
        return connectionTreeDescription
    }

}
