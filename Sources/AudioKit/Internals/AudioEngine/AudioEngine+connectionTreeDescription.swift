// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import Foundation

public extension AudioEngine {
    /// Nice printout of all the node connections
    var connectionTreeDescription: String {
        if let rootNode = mainMixerNode {
            return rootNode.connectionTreeDescription
        } else {
            return "\(connectionTreeLinePrefix)mainMixerNode is nil"
        }
    }
}
