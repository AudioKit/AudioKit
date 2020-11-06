// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import AVFoundation
import CAudioKit

/// Wrapper for AVAudioPlayerNode with extended features
public class AudioPlayer2: Node {
    public private(set) var isPlaying: Bool = false
    public private(set) var isPaused: Bool = false

    public internal(set) var duration: TimeInterval = 0

    public var volume: AUValue {
        get { playerNode.volume }
        set { playerNode.volume = newValue }
    }

    /// The underlying player node
    public private(set) var playerNode = AVAudioPlayerNode()

    /// The output of the AudioPlayer and provides sample rate conversion if needed
    public private(set) var mixerNode = AVAudioMixerNode()

    public var buffered: Bool = true

    /// Initialize audio player
    public init() {
        super.init(avAudioNode: mixerNode)
    }

    public init(url: URL, buffered: Bool = true) {
        super.init(avAudioNode: mixerNode)
        self.buffered = buffered
    }

    public init(file: AVAudioFile, buffered: Bool = true) {
        super.init(avAudioNode: mixerNode)
        self.buffered = buffered
    }


    override func makeAVConnections() {
        guard let engine = mixerNode.engine else {
            Log("Engine is nil", type: .error)
            return
        }
        engine.attach(playerNode)
        engine.connect(playerNode, to: mixerNode, format: nil)
    }

    /// Play audio player
    public func play() {
        playerNode.play()
        isPlaying = true
        isPaused = false
    }

    /// Pause audio player
    public func pause() {
        // pauseTime = currentTime
        playerNode.pause()
        isPaused = true
    }
}

extension AudioPlayer: Toggleable {
    public var isStarted: Bool { isPlaying }

    /// Start audio player
    public func start() {
        play()
    }

    /// Stop audio player
    public func stop() {
        playerNode.stop()
        isPlaying = false
    }
}
