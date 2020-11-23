// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import Foundation

extension AudioEngine {
    
    public func printConnectionTree() {
        if let startNode = mainMixerNode {
            startNode.printConnectionTree()
        } else {
            print("AudioKit | mainMixerNode is nil")
        }
    }
    
}
