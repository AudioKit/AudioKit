// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import AVFoundation
import CAudioKit

/// Wrapper for AVAudioPlayerNode with a simplified API. The player exists in two interchangeable modes
/// either playing from memory (isBuffered) or streamed from disk. Longer files are recommended to be
/// played from disk. If you want seamless looping then buffer it. You can still loop from disk, but the
/// loop may not be totally seamless.

public class AudioPlayer: Node {
    /// The underlying player node
    public private(set) var playerNode = AVAudioPlayerNode()

    /// The output of the AudioPlayer and provides sample rate conversion if needed
    public private(set) var mixerNode = AVAudioMixerNode()

    /// Just the playerNode's property
    public var volume: AUValue {
        get { playerNode.volume }
        set { playerNode.volume = newValue }
    }

    public private(set) var isPlaying: Bool = false
    public private(set) var isPaused: Bool = false

    /// Will be true if there is an existing scheduled event
    public var isScheduled: Bool {
        scheduleTime != nil
    }

    /// The current sample rate of the buffer or file
    public var sampleRate: Double {
        return (isBuffered ? buffer?.format.sampleRate : file?.processingFormat.sampleRate) ?? 0
    }

    /// The duration of the buffer or file
    public var duration: TimeInterval {
        bufferDuration ?? file?.duration ?? 0
    }

    /// If the player is currently using a buffer as an audio source
    public internal(set) var isBuffered: Bool = false

    /// When buffered this should be called before scheduling events. For disk streaming
    /// this could be called at any time before a file is done playing
    public var isLooping: Bool = false {
        didSet {
            bufferOptions = isLooping ? .loops : .interrupts
        }
    }

    /// Used to get the correct current time, after seeking
    private var elapsedTimeOffset: Double = 0
    public var currentTime: TimeInterval {
        if isPlaying {
            if let nodeTime = playerNode.lastRenderTime,
               let playerTime = playerNode.playerTime(forNodeTime: nodeTime) {
                return Double(elapsedTimeOffset) + (Double(playerTime.sampleTime) / playerTime.sampleRate)
            }
        }
        return 0
    }

    /// Completion handler to be called when file or buffer is done playing.
    /// This also will be called when looping from disk,
    /// but no completion is called when looping seamlessly with a buffer
    public var completionHandler: AVAudioNodeCompletionHandler?

    #if !os(macOS)
    /// Progress block to be called via a CADisplayLink.
    /// Use this method to update your UI with info like progress bars, times, etc.
    public var progressBlock: AVAudioNodeCompletionHandler?
    private var displayLink: DisplayLink?
    #endif

    /// The file to use with the player. This can be set while the player is playing.
    public var file: AVAudioFile? {
        didSet {
            scheduleTime = nil
            let wasPlaying = isPlaying
            if wasPlaying { stop() }

            isBuffered = false

            if wasPlaying {
                play()
            }
        }
    }

    /// The buffer to use with the player. This can be set while the player is playing
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

    // MARK: - Internal properties

    // the last time scheduled. Only used to check if play() should schedule()
    var scheduleTime: AVAudioTime?

    var bufferOptions: AVAudioPlayerNodeBufferOptions = .interrupts

    var bufferDuration: TimeInterval?

    var engine: AVAudioEngine? { mixerNode.engine }

    // MARK: - Internal functions

    func internalCompletionHandler() {
        guard isPlaying, !isPaused, engine?.isInManualRenderingMode == false else { return }

        scheduleTime = nil
        isPlaying = false
        elapsedTimeOffset = 0

        DispatchQueue.main.async { [weak self] in
            self?.completionHandler?()
        }

        if !isBuffered, isLooping, engine?.isRunning == true {
            Log("Playing loop...")
            play()
            return
        }
    }

    // called in the connection chain to attach the playerNode
    override func makeAVConnections() {
        guard let engine = mixerNode.engine else {
            Log("Engine is nil", type: .error)
            return
        }
        engine.attach(playerNode)
        engine.connect(playerNode, to: mixerNode, format: nil)
    }

    // MARK: - Init

    /// Create an AudioPlayer with default properties and nothing pre-loaded
    public init() {
        super.init(avAudioNode: mixerNode)
    }

    /// Create an AudioPlayer from file, optionally choosing to buffer it
    public init?(file: AVAudioFile, buffered: Bool = false) {
        super.init(avAudioNode: mixerNode)

        do {
            try load(file: file, buffered: buffered)
        } catch let error as NSError {
            Log(error, type: .error)
            return nil
        }
    }

    /// Create an AudioPlayer from URL, optionally choosing to buffer it
    public convenience init?(url: URL, buffered: Bool = false) {
        self.init()
        do {
            try load(url: url, buffered: buffered)
        } catch let error as NSError {
            Log(error, type: .error)
            return nil
        }
    }

    /// Create an AudioPlayer from an existing buffer
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
        if buffered, let buffer = try AVAudioPCMBuffer(file: file) {
            load(buffer: buffer)
        } else {
            self.file = file
        }
    }

    public func load(buffer: AVAudioPCMBuffer) {
        self.buffer = buffer
    }

    // MARK: - Playback

    /// Play now or at a future time
    /// - Parameters:
    ///   - when: What time to schedule for. A value of nil means now or will
    ///   use a pre-existing scheduled time.
    public func play(at when: AVAudioTime? = nil) {
        guard !isPlaying || isPaused else { return }

        guard playerNode.engine != nil else {
            Log("🛑 Error: AudioPlayer must be attached before playback.")
            return
        }

        if when != nil { scheduleTime = nil }

        if !isScheduled {
            schedule(at: when)
        }

        #if !os(macOS)
        displayLink = DisplayLink {
            DispatchQueue.main.async { [weak self] in
                self?.progressBlock?()
            }
        }
        #endif

        playerNode.play()
        isPlaying = true
        isPaused = false
    }

    /// Pauses audio player. Calling play() will resume from the paused time.
    public func pause() {
        guard isPlaying, !isPaused else { return }

        playerNode.pause()
        isPaused = true
    }
}

extension AudioPlayer: Toggleable {
    /// Synonym for isPlaying
    public var isStarted: Bool { isPlaying }

    /// Synonym for play()
    public func start() {
        play()
    }

    /// Stop audio player. This won't generate a callback event
    public func stop() {
        guard isPlaying else { return }
        isPlaying = false
        playerNode.stop()
        scheduleTime = nil
        elapsedTimeOffset = 0
    }
}

// Just to provide compability with previous AudioPlayer
extension AudioPlayer {
    /// Schedule a file or buffer. You can call this to schedule playback in the future
    /// or the player will call it when play() is called to load the audio data
    /// - Parameters:
    ///   - when: What time to schedule for

    public func schedule(at when: AVAudioTime? = nil) {
        if isBuffered, let buffer = buffer {
            playerNode.scheduleBuffer(buffer,
                                      at: nil,
                                      options: bufferOptions,
                                      completionCallbackType: .dataPlayedBack) { _ in
                self.internalCompletionHandler()
            }
            scheduleTime = when ?? AVAudioTime.now()

        } else if let file = file {
            playerNode.scheduleFile(file,
                                    at: when,
                                    completionCallbackType: .dataPlayedBack) { _ in
                self.internalCompletionHandler()
            }
            scheduleTime = when ?? AVAudioTime.now()

        } else {
            Log("The player needs a file or a valid buffer to schedule", type: .error)
            scheduleTime = nil
        }
    }

    @available(*, deprecated, renamed: "schedule(at:)")
    public func scheduleBuffer(_ buffer: AVAudioPCMBuffer,
                               at when: AVAudioTime?,
                               options: AVAudioPlayerNodeBufferOptions = []) {
        self.buffer = buffer
        isLooping = options == .loops
        schedule(at: when)
    }

    @available(*, deprecated, renamed: "schedule(at:)")
    public func scheduleBuffer(url: URL,
                               at when: AVAudioTime?,
                               options: AVAudioPlayerNodeBufferOptions = []) {
        guard let buffer = try? AVAudioPCMBuffer(url: url) else {
            Log("Failed to create buffer", type: .error)
            return
        }
        scheduleBuffer(buffer, at: when, options: options)
    }

    @available(*, deprecated, renamed: "schedule(at:)")
    public func scheduleFile(_ file: AVAudioFile,
                             at when: AVAudioTime?) {
        self.file = file
        schedule(at: when)
    }
}

// Extension for seeking to a specific AVAudioTime
extension AudioPlayer {
    /// Play the audio player from a specific time
    /// - Parameters:
    ///   - time: The time at which the player will seek to
    public func seek(time: Double) {
        elapsedTimeOffset = time

        if isBuffered {
            Log("Seeking a buffer is not yet supported :(", type: .error)
            return

        } else if let file = file {
            let playLength: Double = duration - time
            let startFrame = AVAudioFramePosition(sampleRate * time)
            let frameLength = AVAudioFrameCount(sampleRate * playLength)

            if playLength <= 0 {
                return
            }

            isPaused = true
            playerNode.stop()
            playerNode.scheduleSegment(file,
                                       startingFrame: startFrame,
                                       frameCount: frameLength,
                                       at: nil,
                                       completionCallbackType: .dataPlayedBack) { _ in
                self.internalCompletionHandler()
            }
            playerNode.play()
            isPlaying = true
            isPaused = false
        } else {
            Log("The player needs a file or a valid buffer to seek", type: .error)
        }
    }
}
