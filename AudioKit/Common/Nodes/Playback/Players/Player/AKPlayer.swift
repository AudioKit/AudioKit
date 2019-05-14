//
//  AKPlayer.swift
//  AudioKit
//
//  Created by Ryan Francesconi, revision history on Github.
//  Copyright © 2018 AudioKit. All rights reserved.
//

import AVFoundation

/**
 AKPlayer is meant to be a simple yet powerful audio player that just works. It supports
 scheduling of sounds, looping, fading, time-stretching, pitch-shifting and reversing.
 Players can be locked to a common clock as well as video by using hostTime in the various play functions.
 By default the player will buffer audio if needed, otherwise stream from disk. Reversing the audio will cause the
 file to buffer. For seamless looping use buffered playback.

 There are a few options for syncing to external objects.

 A locked video function would resemble:
 ```
 func videoPlay(at time: TimeInterval = 0, hostTime: UInt64 = 0 ) {
 let cmHostTime = CMClockMakeHostTimeFromSystemUnits(hostTime)
 let cmVTime = CMTimeMakeWithSeconds(time, 1000000)
 let futureTime = CMTimeAdd(cmHostTime, cmVTime)
 videoPlayer.setRate(1, time: kCMTimeInvalid, atHostTime: futureTime)
 }
 ```

 Basic usage looks like:
 ```
 guard let player = AKPlayer(url: url) else { return }
 player.completionHandler = { AKLog("Done") }

 // Loop Options
 player.loop.start = 1
 player.loop.end = 3
 player.isLooping = true
 player.buffer = true // if seamless is desired

 player.play()
 ```

 Please note that pre macOS 10.13 / iOS 11 the completionHandler isn't sample accurate. It's pretty close though.
 */
public class AKPlayer: AKNode {
    /// How the player should handle audio. If buffering, it will load the audio data into
    /// an internal buffer and play from RAM. If not, it will play the file from disk.
    /// Dynamic buffering will only load the audio if it needs to for processing reasons
    /// such as Perfect Looping or Reversing
    public enum BufferingType {
        case dynamic, always
    }

    public struct Loop {
        public var start: Double = 0 {
            willSet {
                if newValue != start { needsUpdate = true }
            }
        }

        public var end: Double = 0 {
            willSet {
                if newValue != end { needsUpdate = true }
            }
        }

        var needsUpdate: Bool = false
    }

    public struct Fade {
        public init() {}

        /// a constant
        public static var minimumGain: Double = 0.0002

        /// the value that the booster should fade to, settable
        public var maximumGain: Double = 1

        public var inTime: Double = 0 {
            willSet {
                if newValue != inTime { needsUpdate = true }
            }
        }

        public var inRampType: AKSettings.RampType = .exponential {
            willSet {
                if newValue != inRampType { needsUpdate = true }
            }
        }

        public var outRampType: AKSettings.RampType = .exponential {
            willSet {
                if newValue != outRampType { needsUpdate = true }
            }
        }

        // if you want to start midway into a fade
        public var inTimeOffset: Double = 0

        // Currently Unused
        public var inStartGain: Double = minimumGain

        public var outTime: Double = 0 {
            willSet {
                if newValue != outTime { needsUpdate = true }
            }
        }

        public var outTimeOffset: Double = 0

        // Currently Unused
        public var outStartGain: Double = 1

        // tell Booster what ramper to use when multiple curves are available
        public var type: AKSettings.RampType = .exponential

        var needsUpdate: Bool = false
    }

    /// Holds characteristics about the fade options.
    public var fade = Fade()

    /// Optional Auto-Fade to audio on stop(). Useful for eliminating clicks with a short 0.1 second fade.
    /// Default is 0, or off.
    public var stopEnvelopeTime: Double = 0 {
        didSet {
            if faderNode == nil {
                createFader()
            }
        }
    }

    // MARK: - Nodes

    /// The underlying player node
    @objc public let playerNode = AVAudioPlayerNode()

    /// The main output
    @objc public let mixer = AVAudioMixerNode()

    /// The underlying gain booster which controls fades as well. Created on demand.
    @objc public var faderNode: AKBooster?

    // MARK: - Private Parts

    internal var startingFrame: AVAudioFramePosition?
    internal var endingFrame: AVAudioFramePosition?

    // these timers will go away when AudioKit is built for 10.13
    // in that case the real completion handlers of the scheduling can be used.
    // Pre 10.13 the completion handlers are inaccurate to the point of unusable.
    internal var prerollTimer: Timer?
    internal var completionTimer: Timer?

    // fade timer
    internal var faderTimer: Timer?

    // I've found that using the apple completion handlers for AVAudioPlayerNode can introduce some instability.
    // if you don't need them, you can disable them here
    internal var useCompletionHandler: Bool {
        return (isLooping && !isBuffered) || completionHandler != nil
    }

    private var playerTime: Double {
        if let nodeTime = playerNode.lastRenderTime,
            let playerTime = playerNode.playerTime(forNodeTime: nodeTime) {
            return Double(playerTime.sampleTime) / playerTime.sampleRate
        }
        return 0
    }

    private var _startTime: Double = 0
    private var _endTime: Double = 0

    internal var _rate: Double {
        return 1.0
    }
    
    internal var _isPaused = false

    // MARK: - Public Properties

    /// Completion handler to be called when Audio is done playing. The handler won't be called if
    /// stop() is called while playing or when looping from a buffer.
    @objc public var completionHandler: AKCallback?

    /// Completion handler to be called when Audio has looped. The handler won't be called if
    /// stop() is called while playing.
    @objc public var loopCompletionHandler: AKCallback?

    /// Used with buffering players
    @objc public var buffer: AVAudioPCMBuffer?

    /// Sets if the player should buffer dynamically (as needed) or always.
    /// Not buffering means streaming from disk (best for long files),
    /// buffering is playing from RAM (best for shorter sounds you might want to loop).
    /// For seamless looping you should load the sound into RAM.
    /// While this creates a perfect loop, the downside is that you can't easily scrub through the audio.
    /// If you need to be able to be able to scan around the file, keep this .dynamic and stream from disk.
    public var buffering: BufferingType = .dynamic {
        didSet {
            if buffering == .always {
                // could respond to buffering scheme if desired. preroll etc.
            }
        }
    }

    /// The internal audio file
    @objc public private(set) var audioFile: AVAudioFile?

    /// The duration of the loaded audio file
    @objc public var duration: Double {
        guard let audioFile = audioFile else { return 0 }
        return Double(audioFile.length) / audioFile.fileFormat.sampleRate
    }

    /// Looping Parameters
    public var loop = Loop()

    /// Volume 0.0 -> 1.0, default 1.0
    @objc public var volume: Double {
        get {
            return Double(playerNode.volume)
        }

        set {
            playerNode.volume = AUValue(newValue)
        }
    }

    /// Amplification Factor, in the range of 0.0002 to ~
    @objc public var gain: Double {
        get {
            return fade.maximumGain
        }

        set {
            if newValue != 1 && faderNode == nil {
                createFader()
            }
            // this is the value that the fader will fade to
            fade.maximumGain = newValue

            // this is the current value of the fader, set immediately
            faderNode?.gain = newValue
        }
    }

    /// Left/Right balance -1.0 -> 1.0, default 0.0
    @objc public var pan: Double {
        get {
            return Double(playerNode.pan)
        }
        set {
            playerNode.pan = AUValue(newValue)
        }
    }

    // convenience for setting both in and out fade ramp types
    @objc public var rampType: AKSettings.RampType = .exponential {
        didSet {
            fade.inRampType = rampType
            fade.outRampType = rampType
        }
    }

    /// Get or set the start time of the player.
    @objc public var startTime: Double {
        get {
            // return max(0, _startTime)
            return _startTime
        }

        set {
            _startTime = max(0, newValue)
        }
    }

    /// Get or set the end time of the player.
    @objc public var endTime: Double {
        get {
            return isLooping ? loop.end : _endTime
        }

        set {
            var newValue = newValue
            if newValue == 0 {
                newValue = duration
            }
            _endTime = min(newValue, duration)
        }
    }

    /// - Returns: The total frame count that is being playing.
    /// Differs from the audioFile.length as this will be updated with the edited amount
    /// of frames based on startTime and endTime
    @objc public internal(set) var frameCount: AVAudioFrameCount = 0

    /// - Returns: The current frame while playing
    @objc public var currentFrame: AVAudioFramePosition {
        if let nodeTime = playerNode.lastRenderTime,
            let playerTime = playerNode.playerTime(forNodeTime: nodeTime) {
            return playerTime.sampleTime
        }
        return 0
    }

    /// - Returns: Current time of the player in seconds while playing.
    @objc public var currentTime: Double {
        let currentDuration = (endTime - startTime == 0) ? duration : (endTime - startTime)
        var normalisedPauseTime = 0.0
        if let pauseTime = pauseTime, pauseTime > startTime {
            normalisedPauseTime = pauseTime - startTime
        }
        let current = startTime + normalisedPauseTime + playerTime.truncatingRemainder(dividingBy: currentDuration)
        
        return current
    }
    
    public var pauseTime: Double? {
        didSet {
            _isPaused = pauseTime != nil
        }
    }

    @objc public var processingFormat: AVAudioFormat? {
        guard let audioFile = audioFile else { return nil }
        return AVAudioFormat(standardFormatWithSampleRate: audioFile.fileFormat.sampleRate,
                             channels: audioFile.fileFormat.channelCount)
    }

    // MARK: - Public Options

    /// true if the player is buffering audio rather than playing from disk
    @objc public var isBuffered: Bool {
        return isNormalized || isReversed || buffering == .always
    }

    @objc public var isNotBuffered: Bool { return !isBuffered }

    /// Will automatically normalize on buffer updates if enabled
    @objc public var isNormalized: Bool = false {
        didSet {
            updateBuffer(force: true)
        }
    }

    @objc public var isLooping: Bool = false

    @objc public var isPaused: Bool {
        return _isPaused
    }

    /// Reversing the audio will set the player to buffering
    @objc public var isReversed: Bool = false {
        didSet {
            if isPlaying {
                stop()
            }
            updateBuffer(force: true)
        }
    }

    @objc public var isPlaying: Bool {
        return playerNode.isPlaying
    }

    /// true if any fades have been set
    @objc public var isFaded: Bool {
        return fade.inTime > 0 || fade.outTime > 0
    }

    // MARK: - Initialization

    public override init() {
        super.init(avAudioNode: mixer, attach: false)
    }

    /// Create a player from a URL
    @objc public convenience init?(url: URL) {
        if FileManager.default.fileExists(atPath: url.path) == false {
            return nil
        }
        do {
            let avfile = try AVAudioFile(forReading: url)
            self.init(audioFile: avfile, reopenFile: false)
            return
        } catch {
            AKLog("ERROR loading \(url.path) \(error)")
        }
        return nil
    }

    /// Create a player from an AVAudioFile (or AKAudioFile). If a file has previously
    /// been opened for writing, you can reset it to readOnly with the reopenFile flag.
    /// This is necessary in cases where AKMicrophone may of had access to the file.
    @objc public convenience init(audioFile: AVAudioFile, reopenFile: Bool = true) {
        self.init()

        self.audioFile = audioFile

        if reopenFile, let readFile = try? AVAudioFile(forReading: audioFile.url) {
            self.audioFile = readFile
        }

        initialize(restartIfPlaying: false)
    }

    internal func initialize(restartIfPlaying: Bool = true) {
        let wasPlaying = isPlaying && restartIfPlaying
        if wasPlaying {
            pause()
        }

        if mixer.engine == nil {
            AudioKit.engine.attach(mixer)
        }

        if playerNode.engine == nil {
            AudioKit.engine.attach(playerNode)
        } else {
            playerNode.disconnectOutput()
        }

        if let faderNode = faderNode {
            if faderNode.avAudioUnitOrNode.engine == nil {
                AudioKit.engine.attach(faderNode.avAudioUnitOrNode)
            } else {
                faderNode.disconnectOutput()
            }
        }
        loop.start = 0
        loop.end = duration
        buffer = nil

        connectNodes()
        if wasPlaying {
            resume()
        }
    }

    internal func connectNodes() {
        guard let processingFormat = processingFormat else { return }
        if let faderNode = faderNode {
            AudioKit.connect(playerNode, to: faderNode.avAudioUnitOrNode, format: processingFormat)
            AudioKit.connect(faderNode.avAudioUnitOrNode, to: mixer, format: processingFormat)
        } else {
            AudioKit.connect(playerNode, to: mixer, format: processingFormat)
        }
    }

    // MARK: - Loading

    /// Replace the contents of the player with this url
    @objc public func load(url: URL) throws {
        let file = try AVAudioFile(forReading: url)
        load(audioFile: file)
    }

    @objc public func load(audioFile: AVAudioFile) {
        faderTimer?.invalidate()

        self.audioFile = audioFile
        initialize(restartIfPlaying: false)
        // will reset the stored start / end times or update the buffer
        preroll()
    }

    /// Mostly applicable to buffered players, this loads the buffer and gets it ready to play.
    /// Otherwise it just sets the startTime and endTime
    @objc public func preroll(from startingTime: Double = 0, to endingTime: Double = 0) {
        var from = startingTime
        var to = endingTime

        if to == 0 {
            to = duration
        }

        if from > to {
            from = 0
        }
        startTime = from
        endTime = to

        if isFaded {
            createFader()
            resetFader(false)
        } else {
            resetFader(true)
        }

        guard isBuffered else { return }
        updateBuffer()
    }

    // MARK: - Play

    /// Play using full options. Last in the convenience play chain, all play() commands will end up here
    /// Placed in main class to be overriden in subclasses if needed.
    public func play(from startingTime: Double, to endingTime: Double, at audioTime: AVAudioTime?, hostTime: UInt64?) {
        // AKLog(startingTime, "to", endingTime, "at", audioTime, "hostTime", hostTime)

        faderTimer?.invalidate()

        preroll(from: startingTime, to: endingTime)
        schedule(at: audioTime, hostTime: hostTime)
        playerNode.play()
        faderNode?.start()

        guard !isBuffered else {
            faderNode?.gain = gain
            return
        }
        initFader(at: audioTime, hostTime: hostTime)
        
        pauseTime = nil
    }

    // MARK: - Deinit

    /// Dispose the audio file, buffer and nodes and release resources.
    /// Only call when you are totally done with this class.
    @objc public override func detach() {
        stop()
        audioFile = nil
        buffer = nil
        AudioKit.detach(nodes: [mixer, playerNode])

        if let faderNode = faderNode {
            AudioKit.detach(nodes: [faderNode.avAudioUnitOrNode])
        }
        faderNode = nil
    }

    @objc deinit {
        AKLog("* deinit AKPlayer")
    }
}

// This used to be in a separate file but this broke setPosition

@objc extension AKPlayer: AKTiming {
    @objc public func start(at audioTime: AVAudioTime?) {
        play(at: audioTime)
    }

    @objc public var isStarted: Bool {
        return isPlaying
    }

    @objc public func setPosition(_ position: Double) {
        startTime = position
        if isPlaying {
            stop()
            play()
        }
    }

    @objc public func position(at audioTime: AVAudioTime?) -> Double {
        guard let playerTime = playerNode.playerTime(forNodeTime: audioTime ?? AVAudioTime.now()) else {
            return startTime
        }
        return startTime + Double(playerTime.sampleTime) / playerTime.sampleRate
    }

    @objc public func audioTime(at position: Double) -> AVAudioTime? {
        let sampleRate = playerNode.outputFormat(forBus: 0).sampleRate
        let sampleTime = (position - startTime) * sampleRate
        let playerTime = AVAudioTime(sampleTime: AVAudioFramePosition(sampleTime), atRate: sampleRate)
        return playerNode.nodeTime(forPlayerTime: playerTime)
    }

    @objc open func prepare() {
        preroll(from: startTime, to: endTime)
    }
}
