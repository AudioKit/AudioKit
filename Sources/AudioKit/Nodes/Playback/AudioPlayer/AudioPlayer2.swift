// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import AVFoundation
import CAudioKit

/// Wrapper for AVAudioPlayerNode with extended features
public class AudioPlayer2: Node {
    public private(set) var isPlaying: Bool = false
    public private(set) var isPaused: Bool = false

    public var volume: AUValue {
        get { playerNode.volume }
        set { playerNode.volume = newValue }
    }

    /// The underlying player node
    public private(set) var playerNode = AVAudioPlayerNode()

    /// The output of the AudioPlayer and provides sample rate conversion if needed
    public private(set) var mixerNode = AVAudioMixerNode()

    public var buffered: Bool = false

    public internal(set) var duration: TimeInterval = 0

    public var file: AVAudioFile? {
        didSet {
            duration = file?.duration ?? 0
        }
    }

    public var buffer: AVAudioPCMBuffer? {
        didSet {
            let wasPlaying = isPlaying
            if wasPlaying { stop() }

            guard let strongBuffer = buffer else { return }

            // load buffer
            duration = TimeInterval(strongBuffer.frameLength) / strongBuffer.format.sampleRate

            if wasPlaying {
                playerNode.scheduleBuffer(strongBuffer, at: nil, options: .interrupts)
                play()
            }
        }
    }

    override func makeAVConnections() {
        guard let engine = mixerNode.engine else {
            Log("Engine is nil", type: .error)
            return
        }
        engine.attach(playerNode)
        engine.connect(playerNode, to: mixerNode, format: nil)
    }

    /// Initialize audio player
    public init() {
        super.init(avAudioNode: mixerNode)
    }

    public init?(file: AVAudioFile, buffered: Bool = false) {
        super.init(avAudioNode: mixerNode)

        do {
            try load(file: file, buffered: buffered)
        } catch let error as NSError {
            Log(error, type: .error)
            return nil
        }
    }

    convenience init?(url: URL, buffered: Bool = false) {
        self.init()
        do {
            try load(url: url, buffered: buffered)
        } catch let error as NSError {
            Log(error, type: .error)
            return nil
        }
    }

    // MARK: - Loading

    public func load(url: URL, buffered: Bool = false) throws {
        let file = try AVAudioFile(forReading: url)
        try load(file: file, buffered: buffered)
    }

    public func load(file: AVAudioFile, buffered: Bool = false) throws {
        self.file = file
        self.buffered = buffered

        if buffered, let buffer = try? AVAudioPCMBuffer(file: file) {
            load(buffer: buffer)
        }
    }

    public func load(buffer: AVAudioPCMBuffer) {
        self.buffer = buffer
    }

    // MARK: - Playback

    /// Play audio player
    public func play() {
        guard playerNode.engine != nil else {
            Log("🛑 Error: AudioPlayer must be attached before playback.")
            return
        }

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

extension AudioPlayer2: Toggleable {
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
