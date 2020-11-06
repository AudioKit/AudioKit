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

    public var duration: TimeInterval {
        bufferDuration ?? file?.duration ?? 0
    }

    /// Completion handler to be called when file or buffer is done
    public var completionHandler: AVAudioNodeCompletionHandler?

    var scheduleTime: AVAudioTime?

    var bufferOptions: AVAudioPlayerNodeBufferOptions = .interrupts

    public var isLooping: Bool = false {
        didSet {
            bufferOptions = isLooping ? .loops : .interrupts
        }
    }

    public var isScheduled: Bool {
        scheduleTime != nil
    }

    public var file: AVAudioFile? {
        didSet {
            scheduleTime = nil
            isBuffered = false
            let wasPlaying = isPlaying
            if wasPlaying { stop() }

            if wasPlaying {
                play()
            }
        }
    }

    var bufferDuration: TimeInterval?

    public internal(set) var isBuffered: Bool = false

    public var buffer: AVAudioPCMBuffer? {
        didSet {
            isBuffered = buffer != nil
            scheduleTime = nil

            let wasPlaying = isPlaying
            if wasPlaying { stop() }

            guard let strongBuffer = buffer else { return }

            bufferDuration = TimeInterval(strongBuffer.frameLength) / strongBuffer.format.sampleRate

            if wasPlaying {
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

    public convenience init?(url: URL, buffered: Bool = false) {
        self.init()
        do {
            try load(url: url, buffered: buffered)
        } catch let error as NSError {
            Log(error, type: .error)
            return nil
        }
    }

    public convenience init?(buffer: AVAudioPCMBuffer) {
        self.init()
        load(buffer: buffer)
    }

    // MARK: - Loading

    public func load(url: URL, buffered: Bool = false) throws {
        let file = try AVAudioFile(forReading: url)
        try load(file: file, buffered: buffered)
    }

    public func load(file: AVAudioFile, buffered: Bool = false) throws {
        if buffered, let buffer = try? AVAudioPCMBuffer(file: file) {
            load(buffer: buffer)
        } else {
            self.file = file
        }
    }

    public func load(buffer: AVAudioPCMBuffer) {
        self.buffer = buffer
    }

    // MARK: - Playback

    /// Play audio player
    public func play(at when: AVAudioTime? = nil) {
        guard !isPlaying else { return }

        guard playerNode.engine != nil else {
            Log("🛑 Error: AudioPlayer must be attached before playback.")
            return
        }

        if when != nil { scheduleTime = nil }

        if !isScheduled {
            schedule(at: when)
        }

        playerNode.play()
        isPlaying = true
        isPaused = false
    }

    /// Pauses audio player. Calling play() will resume from the paused time.
    public func pause() {
        guard isPlaying else { return }

        playerNode.pause()
        isPaused = true
    }

    func internalCompletionHandler() {
        scheduleTime = nil
        isPlaying = false
        completionHandler?()

        if !isBuffered, isLooping {
            DispatchQueue.main.async {
                self.play()
            }
        }
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
        guard isPlaying else { return }
        playerNode.stop()
        isPlaying = false
        scheduleTime = nil
    }
}
