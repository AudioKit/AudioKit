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

    /// Just the playerNode's property, values above 1 will have gain applied
    public var volume: AUValue {
        get { playerNode.volume }
        set { playerNode.volume = newValue }
    }

    /// Whether or not the playing is playing
    public private(set) var isPlaying: Bool = false

    /// Whether or not the playing is paused
    public private(set) var isPaused: Bool = false

    /// Will be true if there is an existing scheduled event
    public var isScheduled: Bool {
        scheduleTime != nil
    }

    private var _isBuffered: Bool = false
    /// If the player is currently using a buffer as an audio source
    public var isBuffered: Bool {
        get { _isBuffered }
        set {
            guard newValue != _isBuffered else { return }
            _isBuffered = newValue
            
            if newValue {
                updateBuffer()
            } else {
                buffer = nil
            }
        }
    }

    private var _isReversed: Bool = false
    public var isReversed: Bool {
        get { _isReversed }
        set {
            guard newValue != isReversed else { return }

            if isPlaying { stop() }

            if newValue && !isBuffered {
                isBuffered = true
                updateBuffer(force: true)
            }
        }
    }

    /// When buffered this should be called before scheduling events. For disk streaming
    /// this could be called at any time before a file is done playing
    public var isLooping: Bool = false {
        didSet {
            bufferOptions = isLooping ? .loops : .interrupts
        }
    }

    /// Length of the audio file in seconds
    public var duration: TimeInterval {
        file?.duration ?? bufferDuration
    }

    /// Time in audio file where track was started (allows retrieval of playback time after playerNode is seeked)
    private var segmentStartTime: TimeInterval = 0.0

    /// Time in audio file where track was stopped (allows retrieval of playback time after playerNode is paused)
    private var pausedTime: TimeInterval = 0.0

    /// Completion handler to be called when file or buffer is done playing.
    /// This also will be called when looping from disk,
    /// but no completion is called when looping seamlessly with a buffer
    public var completionHandler: AVAudioNodeCompletionHandler?

    /// The file to use with the player. This can be set while the player is playing.
    public var file: AVAudioFile? {
        didSet {
            scheduleTime = nil
            let wasPlaying = isPlaying
            if wasPlaying { stop() }

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

            if wasPlaying {
                play()
            }
        }
    }

    // MARK: - Internal properties

    // the last time scheduled. Only used to check if play() should schedule()
    var scheduleTime: AVAudioTime?

    var bufferOptions: AVAudioPlayerNodeBufferOptions = .interrupts

    var bufferDuration: TimeInterval {
        guard let buffer = buffer else { return 0 }
        return TimeInterval(buffer.frameLength) / buffer.format.sampleRate
    }

    private var _editStartTime: TimeInterval = 0
    /// Get or set the edit start time of the player.
    public var editStartTime: TimeInterval {
        get { _editStartTime }
        set { _editStartTime = max(0, newValue) }
    }

    private var _editEndTime: TimeInterval = 0
    /// Get or set the edit end time of the player.
    public var editEndTime: TimeInterval {
        get {
            _editEndTime
        }

        set {
            var newValue = newValue
            if newValue == 0 {
                newValue = duration
            }
            _editEndTime = min(newValue, duration)
        }
    }

    /// - Returns: The total frame count that is being playing.
    /// Differs from the audioFile.length as this will be updated with the edited amount
    /// of frames based on startTime and endTime
    var frameCount: AVAudioFrameCount = 0
    var startingFrame: AVAudioFramePosition?
    var endingFrame: AVAudioFramePosition?

    var engine: AVAudioEngine? { mixerNode.engine }

    // MARK: - Internal functions

    func internalCompletionHandler() {
        guard isPlaying, engine?.isInManualRenderingMode == false else { return }

        scheduleTime = nil
        completionHandler?()
        isPlaying = false

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

    /// Load file at a URL, optionally buffered
    /// - Parameters:
    ///   - url: URL of the audio file
    ///   - buffered: Boolean of whether you want the audio buffered
    public func load(url: URL, buffered: Bool = false) throws {
        let file = try AVAudioFile(forReading: url)
        try load(file: file, buffered: buffered)
    }

    /// Load an AVAudioFIle, optionally buffered
    /// - Parameters:
    ///   - file: File to play
    ///   - buffered: Boolean of whether you want the audio buffered
    public func load(file: AVAudioFile, buffered: Bool = false) throws {
        self.file = file
        isBuffered = buffered

        if buffered {
            updateBuffer()
        }
    }

    /// Load a buffer for playing directly
    /// - Parameter buffer: Buffer to play
    public func load(buffer: AVAudioPCMBuffer) {
        self.buffer = buffer

//        startingFrame = 0
//        if let file = file {
//            endingFrame = AVAudioFramePosition(duration * file.fileFormat.sampleRate)
//        }
    }

    // MARK: - Playback

    /// Play now or at a future time
    /// - Parameters:
    ///   - when: What time to schedule for. A value of nil means now or will
    ///   use a pre-existing scheduled time.
    ///   - completionCallbackType: Constants that specify when the completion handler must be invoked.
    public func play(from startTime: TimeInterval? = nil,
                     to endTime: TimeInterval? = nil,
                     at when: AVAudioTime? = nil,
                     completionCallbackType: AVAudioPlayerNodeCompletionCallbackType = .dataPlayedBack) {
        guard !isPlaying || isPaused else { return }

        guard let engine = playerNode.engine else {
            Log("🛑 Error: AudioPlayer must be attached before playback.", type: .error)
            return
        }

        guard engine.isRunning else {
            Log("🛑 Error: AudioPlayer's engine must be running before playback.", type: .error)
            return
        }

        if when != nil { scheduleTime = nil }

        editStartTime = startTime ?? 0
        editEndTime = endTime ?? duration

        if !isScheduled {
            schedule(at: when,
                     completionCallbackType: completionCallbackType)
        }

        playerNode.play()
        isPlaying = true
        isPaused = false
    }

    /// Pauses audio player. Calling play() will resume from the paused time.
    public func pause() {
        guard isPlaying, !isPaused else { return }
        pausedTime = getCurrentTime()
        playerNode.pause()
        isPaused = true
    }

    /// Gets the accurate playhead time regardless of seeking and pausing
    /// Can't be relied on if playerNode has its playstate modified directly
    public func getCurrentTime() -> TimeInterval {
        if let nodeTime = playerNode.lastRenderTime,
           nodeTime.isSampleTimeValid && nodeTime.isHostTimeValid,
           let playerTime = playerNode.playerTime(forNodeTime: nodeTime) {
            return (Double(playerTime.sampleTime) / playerTime.sampleRate) + segmentStartTime
        }
        return pausedTime
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
        pausedTime = getCurrentTime()
        isPlaying = false
        playerNode.stop()
        scheduleTime = nil
    }
}

// Just to provide compability with previous AudioPlayer
extension AudioPlayer {
    /// Sets the player's audio file to a certain time in the track (in seconds)
    /// and respects the players current play state
    /// - Parameters:
    ///   - time seconds into the audio file to set playhead
    public func seek(time: Float) {
        let wasPlaying = isPlaying
        playerNode.stop()

        // Note: this needs to take into account buffered players

        if let file = file {
            let sampleLength = file.length

            let sampleRate = Float(file.fileFormat.sampleRate)
            let startSample = floor(time * sampleRate)
            let lengthSamples = Float(sampleLength) - startSample

            playerNode.scheduleSegment(file,
                                       startingFrame: AVAudioFramePosition(startSample),
                                       frameCount: AVAudioFrameCount(lengthSamples),
                                       at: nil,
                                       completionHandler: {
                                           self.playerNode.pause()
                                       })
            segmentStartTime = TimeInterval(time)
        }

        if wasPlaying && !isPaused {
            playerNode.play()
        } else {
            pausedTime = TimeInterval(time)
        }
    }
}
