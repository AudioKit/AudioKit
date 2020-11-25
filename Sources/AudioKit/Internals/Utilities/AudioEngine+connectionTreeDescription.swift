// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import Foundation

extension AudioEngine {

    public var connectionTreeDescription: String {
        if let rootNode = mainMixerNode {
            return rootNode.connectionTreeDescription
        } else {
            return "\(Node.connectionTreeLinePrefix)mainMixerNode is nil"
        }
    }

}
