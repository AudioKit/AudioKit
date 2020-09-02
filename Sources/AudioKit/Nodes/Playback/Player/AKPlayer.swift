// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import AVFoundation
import CAudioKit

public class AKPlayer: AKNode {

    /// The underlying player node
    public var playerNode = AVAudioPlayerNode()

    /// If sample rate conversion is needed
    public var mixerNode = AVAudioMixerNode()

    public init() {
        super.init(avAudioNode: mixerNode)
    }

    override func makeAVConnections() {
        if let engine = mixerNode.engine {
            engine.attach(playerNode)
            engine.connect(playerNode, to: mixerNode)
        }
    }

    public func scheduleFile(_ file: AVAudioFile, at when: AVAudioTime?, completionHandler: AVAudioNodeCompletionHandler? = nil) {
        playerNode.scheduleFile(file, at: when, completionHandler: completionHandler)
    }

    public func play() {
        playerNode.play()
    }

}
