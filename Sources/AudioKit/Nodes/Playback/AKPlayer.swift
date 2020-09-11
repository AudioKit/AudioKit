// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import AVFoundation
import CAudioKit

/// Wrapper for AVAudioPlayerNode.
public class AKPlayer: AKNode, AKToggleable {
    public var isStarted: Bool {
        playerNode.isPlaying
    }

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
            engine.connect(playerNode, to: mixerNode, format: nil)
        }
    }

    public func scheduleFile(_ file: AVAudioFile,
                             at when: AVAudioTime?,
                             completionHandler: AVAudioNodeCompletionHandler? = nil) {
        if playerNode.engine == nil {
            AKLog("🛑 Error: AKPlayer must be attached before scheduling playback.")
            return
        }
        playerNode.scheduleFile(file, at: when, completionHandler: completionHandler)
    }

    public func scheduleBuffer(_ buffer: AVAudioPCMBuffer,
                               at when: AVAudioTime?,
                               options: AVAudioPlayerNodeBufferOptions = [],
                               completionHandler: AVAudioNodeCompletionHandler? = nil) {
        if playerNode.engine == nil {
            AKLog("🛑 Error: AKPlayer must be attached before scheduling playback.")
            return
        }
        playerNode.scheduleBuffer(buffer,
                                  at: when,
                                  options: options,
                                  completionHandler: completionHandler)
    }

    public func play() {
        playerNode.play()
    }

    public func start() {
        playerNode.play()
    }

    public func stop() {
        playerNode.stop()
    }

    public func pause() {
        playerNode.pause()
    }

}
