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
    /// 1. `brew install graphviz` (if not already isntalled)
    /// 2. Save output to `.dot` file (e.g. `effects.dot`)
    /// 2. `dot -Tpdf effects.dot > effects.pdf`
    var graphviz: String {
        
        var s = "digraph patch {\n"
        s += "  graph [rankdir = \"LR\"];\n"
        
        var seen = Set<ObjectIdentifier>()
        printDotAux(seen: &seen, str: &s)
        
        s += "}"
        return s
    }
    
    /// Auxiliary function to print out the graph of AudioKit nodes.
    private func printDotAux(seen: inout Set<ObjectIdentifier>, str: inout String) {
        
        let id = ObjectIdentifier(self)
        if seen.contains(id) {
            return
        }
        
        seen.insert(id)
        
        // Print connections.
        for c in connections {
            
            str += "  \(type(of:c))_\(ObjectIdentifier(c).addressString) -> \(type(of: self))_\(id.addressString);\n"
            
            c.printDotAux(seen: &seen, str: &str)
        }
    }
    
}
