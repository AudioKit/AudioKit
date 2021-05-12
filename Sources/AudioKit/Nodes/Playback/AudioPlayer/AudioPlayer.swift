// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import AVFoundation
import CAudioKit

/// Wrapper for AVAudioPlayerNode with a simplified API. The player exists in two interchangeable modes
/// either playing from memory (isBuffered) or streamed from disk. Longer files are recommended to be
/// played from disk. If you want seamless looping then buffer it. You can still loop from disk, but the
/// loop will not be totally seamless.

public class AudioPlayer: Node {

    /// Nodes providing input to this node.
    public var connections: [Node] { [] }

    /// The underlying player node
    public private(set) var playerNode = AVAudioPlayerNode()

    /// The output of the AudioPlayer and provides sample rate conversion if needed
    public private(set) var mixerNode = AVAudioMixerNode()

    /// The internal AVAudioEngine AVAudioNode
    public var avAudioNode: AVAudioNode { return mixerNode }

    /// Just the playerNode's property, values above 1 will have gain applied
    public var volume: AUValue {
        get { playerNode.volume }
        set { playerNode.volume = newValue }
    }

    /// Whether or not the playing is playing
    public internal(set) var isPlaying: Bool = false

    /// Whether or not the playing is paused
    public internal(set) var isPaused: Bool = false

    /// Will be true if there is an existing schedule event
    public var isScheduled: Bool { scheduleTime != nil }

    private var _isBuffered: Bool = false
    /// If the player is currently using a buffer as an audio source
    public var isBuffered: Bool {
        get { _isBuffered }
        set {
            guard newValue != _isBuffered else { return }
            _isBuffered = newValue

            if !newValue {
                buffer = nil
            }
        }
    }

    private var _isReversed: Bool = false

    /// Will reverse the file and convert to a buffered format if it's not already
    public var isReversed: Bool {
        get { _isReversed }
        set {
            guard newValue != isReversed else { return }
            _isReversed = newValue

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

    /// Indicates the player is in the midst of a seek operation
    public internal(set) var isSeeking: Bool = false

    /// Length of the audio file in seconds
    public var duration: TimeInterval {
        file?.duration ?? bufferDuration
    }

    /// Completion handler to be called when file or buffer is done playing.
    /// This also will be called when looping from disk,
    /// but no completion is called when looping seamlessly when buffered
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

    private var _editStartTime: TimeInterval = 0
    /// Get or set the edit start time of the player.
    public var editStartTime: TimeInterval {
        get { _editStartTime }
        set {
            _editStartTime = (0 ... duration).clamp(newValue)
        }
    }

    private var _editEndTime: TimeInterval = 0
    /// Get or set the edit end time of the player. Setting to 0 will effectively remove
    /// the edit and set to the duration of the player
    public var editEndTime: TimeInterval {
        get {
            _editEndTime
        }

        set {
            var newValue = newValue
            if newValue == 0 {
                newValue = duration
            }
            _editEndTime = (0 ... duration).clamp(newValue)
        }
    }

    // MARK: - Internal properties

    // Time in audio file where track was stopped (allows retrieval of playback time after playerNode is paused)
    var pausedTime: TimeInterval = 0.0

    // the last time scheduled. Only used to check if play() should schedule()
    var scheduleTime: AVAudioTime?

    var bufferOptions: AVAudioPlayerNodeBufferOptions = .interrupts

    var bufferDuration: TimeInterval {
        guard let buffer = buffer else { return 0 }
        return TimeInterval(buffer.frameLength) / buffer.format.sampleRate
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
        guard !isSeeking,
              isPlaying,
              engine?.isInManualRenderingMode == false else { return }

        scheduleTime = nil
        completionHandler?()
        isPlaying = false

        if !isBuffered, isLooping, engine?.isRunning == true {
            play()
            return
        }
    }
    
    // MARK: - Init

    /// Create an AudioPlayer with default properties and nothing pre-loaded
    public init() { }

    /// Create an AudioPlayer from file, optionally choosing to buffer it
    public init?(file: AVAudioFile, buffered: Bool = false) {
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

    deinit {
        buffer = nil
        file = nil
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
    }
}

extension AudioPlayer: HasInternalConnections {

    /// called in the connection chain to attach the playerNode
    public func makeInternalConnections() {
        guard let engine = mixerNode.engine else {
            Log("Engine is nil", type: .error)
            return
        }
        engine.attach(playerNode)
        engine.connect(playerNode, to: mixerNode, format: file?.processingFormat)
    }

}
