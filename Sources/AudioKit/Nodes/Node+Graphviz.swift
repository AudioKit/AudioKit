// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import Foundation

extension ObjectIdentifier {
    var addressString: String {
        String(debugDescription.dropFirst(17).dropLast(1))
    }
}

extension Node {
    
    /// Generates Graphviz (.dot) format for a chain of AudioKit nodes.
    ///
    /// Instructions for use:
    ///
    /// 1. `brew install graphviz` (if not already installed)
    /// 2. Save output to `.dot` file (e.g. `effects.dot`)
    /// 2. `dot -Tpdf effects.dot > effects.pdf`
    var graphviz: String {

        var str = "digraph patch {\n"
        str += "  graph [rankdir = \"LR\"];\n"

        var seen = Set<ObjectIdentifier>()
        printDotAux(seen: &seen, str: &str)

        str += "}"
        return str
    }
    
    /// Auxiliary function to print out the graph of AudioKit nodes.
    private func printDotAux(seen: inout Set<ObjectIdentifier>, str: inout String) {

        let id = ObjectIdentifier(self)
        if seen.contains(id) {
            return
        }

        seen.insert(id)

        // Print connections.
        for connection in connections {

            let connectionAddress = ObjectIdentifier(connection).addressString
            str += "  \(type(of:connection))_\(connectionAddress) -> \(type(of: self))_\(id.addressString);\n"

            connection.printDotAux(seen: &seen, str: &str)
        }
    }
}
