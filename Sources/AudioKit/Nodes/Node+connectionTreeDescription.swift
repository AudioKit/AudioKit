// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import Foundation

public let connectionTreeLinePrefix = "AudioKit | "

extension Node {
    /// Nice printout of all the node connections
    public var connectionTreeDescription: String {
        return String(createConnectionTreeDescription().dropLast())
    }

    private func createConnectionTreeDescription(paddedWith indentation: String = "") -> String {
        var nodeDescription = String(describing: self).components(separatedBy: ".").last ?? "Unknown"

        if let namedSelf = self as? NamedNode {
            nodeDescription += "(\"\(namedSelf.name)\")"
        }

        var connectionTreeDescription = "\(connectionTreeLinePrefix)\(indentation)↳\(nodeDescription)\n"
        for connectionNode in connections {
            connectionTreeDescription += connectionNode.createConnectionTreeDescription(paddedWith: " " + indentation)
        }
        return connectionTreeDescription
    }
}
