// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

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

 Please note that pre macOS 10.13 / iOS 11 you will need to provide your own completionHandler if needed.
 */
public class AKPlayer: AKAbstractPlayer {
    /// How the player should handle audio. If buffering, it will load the audio data into
    /// an internal buffer and play from RAM. If not, it will play the file from disk.
    /// Dynamic buffering will only load the audio if it needs to for processing reasons
    /// such as Perfect Looping or Reversing

    public enum BufferingType {
        case dynamic, always
    }

    // MARK: - Nodes

    /// The underlying player node
    @objc public var playerNode = AVAudioPlayerNode()

    /// If sample rate conversion is needed
    @objc public var mixerNode: AVAudioMixerNode?

    // MARK: - Private Parts

    internal var startingFrame: AVAudioFramePosition?
    internal var endingFrame: AVAudioFramePosition?

    private var playerTime: Double {
        if let nodeTime = playerNode.lastRenderTime,
            let playerTime = playerNode.playerTime(forNodeTime: nodeTime) {
            return Double(playerTime.sampleTime) / playerTime.sampleRate
        }
        return 0
    }

    // MARK: - Public Properties

    /// Completion handler to be called when Audio is done playing. The handler won't be called if
    /// stop() is called while playing or when looping from a buffer. Requires iOS 11, macOS 10.13.
    @objc public var completionHandler: AKCallback? {
        didSet {
            if #available(iOS 11, macOS 10.13, tvOS 11, *) {
            } else {
                AKLog("Sorry, this completionHandler now requires iOS 11, macOS 10.13, tvOS 11. " +
                    "Legacy Timer based callbacks have been removed from AKPlayer, but " +
                    "you can implement on your end using a Timer.")
            }
        }
    }

    /// Completion handler to be called when Audio has looped. The handler won't be called if
    /// stop() is called while playing.
    @objc public var loopCompletionHandler: AKCallback?

    /// Used with buffering players
    @objc public var buffer: AVAudioPCMBuffer?

    /// Sets if the player should buffer dynamically (as needed) or always.
    /// Not buffering means streaming from disk (best for long files),
    /// buffering is playing from RAM (best for shorter sounds you might want to loop).
    /// For seamless looping you should load the sound into RAM, but...
    /// While this creates a perfect loop, the downside is that you can't easily scrub through the audio.
    /// If you need to be able to be able to scan around the file, keep this .dynamic and stream from disk.
    public var buffering: BufferingType = .dynamic {
        didSet {
            if buffering == .always {
                // could respond to buffering scheme if desired. preroll etc.
            }
        }
    }

    /// Will return whether the engine is rendering offline or realtime
    /// Requires iOS 11, macOS 10.13 for offline rendering
    public override var renderingMode: RenderingMode {
        if #available(iOS 11, macOS 10.13, tvOS 11, *) {
            // AVAudioEngineManualRenderingMode
            if playerNode.engine?.manualRenderingMode == .offline {
                return .offline
            }
        }
        return .realtime
    }

    /// The internal audio file
    @objc public internal(set) var audioFile: AVAudioFile?

    /// The duration of the loaded audio file
    @objc public override var duration: Double {
        guard let audioFile = audioFile else { return 0 }
        return Double(audioFile.length) / audioFile.fileFormat.sampleRate
    }

    @objc public override var sampleRate: Double {
        return playerNode.outputFormat(forBus: 0).sampleRate
    }

    /// Volume 0.0 -> 1.0, default 1.0
    /// This is different than gain
    @objc public var volume: AUValue {
        get {
            return playerNode.volume
        }

        set {
            playerNode.volume = newValue
        }
    }

    /// Left/Right balance -1.0 -> 1.0, default 0.0
    @objc public var pan: AUValue {
        get {
            return playerNode.pan
        }
        set {
            playerNode.pan = newValue
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
        var normalizedPauseTime = 0.0
        if let pauseTime = pauseTime, pauseTime > startTime {
            normalizedPauseTime = pauseTime - startTime
        }
        let current = startTime + normalizedPauseTime + playerTime.truncatingRemainder(dividingBy: currentDuration)

        return current
    }

    public var pauseTime: Double? {
        didSet {
            isPaused = pauseTime != nil
        }
    }

    /// Returns the audioFile's internal processingFormat
    @objc public var processingFormat: AVAudioFormat? {
        return audioFile?.processingFormat
    }

    // MARK: - Public Options

    /// true if the player is buffering audio rather than playing from disk
    @objc public var isBuffered: Bool {
        return isNormalized || isReversed || buffering == .always
    }

    /// Will automatically normalize on buffer updates if enabled
    @objc public var isNormalized: Bool = false {
        didSet {
            updateBuffer(force: true)
        }
    }

    /// returns if the player is currently paused
    @objc public internal(set) var isPaused: Bool = false

    /// Reversing the audio will set the player to buffering
    @objc public var isReversed: Bool = false {
        didSet {
            if isPlaying {
                stop()
            }
            if isFaded {
                fade.needsUpdate = true
            }
            updateBuffer(force: true)
        }
    }

    // When buffered this will indicate if the buffer will be faded.
    // Fading the actual buffer data is necessary as loops when buffered don't fire
    // a callback on loop restart
    @objc public var isBufferFaded: Bool {
        return buffering == .always && isLooping
    }

    // MARK: - Initialization

    public init() {
        let output = AKFader()
        super.init(avAudioNode: output.avAudioUnitOrNode, attach: false)
        faderNode = output

        // start this bypassed
        faderNode?.bypass()

        // AKLog("Fader input format:", faderNode?.avAudioUnitOrNode.inputFormat(forBus: 0))
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

        if mixerNode == nil, processingFormat != AKSettings.audioFormat {
            AKLog("⚠️ Warning: This file is a different format than AKSettings. A mixer is being placed in line.")
            AKLog("processingFormat:", processingFormat, "AKSettings.audioFormat:", AKSettings.audioFormat)
            let strongMixer = AVAudioMixerNode()
            mixerNode = strongMixer
        }

        initialize(restartIfPlaying: false)
    }

    open override func initialize(restartIfPlaying: Bool = true) {
        let wasPlaying = isPlaying && restartIfPlaying
        if wasPlaying {
            pause()
        }

        if playerNode.engine == nil {
            AKManager.engine.attach(playerNode)
        } else {
            playerNode.disconnectOutput()
        }

        if let strongMixer = mixerNode {
            if strongMixer.engine == nil {
                AKManager.engine.attach(strongMixer)
            } else {
                // intermediate nodes get disconnected and re-connected
                strongMixer.disconnectOutput()
            }
        }

        if let faderNode = super.faderNode {
            if faderNode.avAudioUnitOrNode.engine == nil {
                AKManager.engine.attach(faderNode.avAudioUnitOrNode)
            }
            // but, don't disconnect the main output!
            // faderNode stays plugged in
        }
        loop.start = 0
        loop.end = duration
        buffer = nil

        connectNodes()
        if wasPlaying {
            resume()
        }
    }

    // override in subclasses that have more complex signal chains
    // see AKDynamicPlayer
    internal func connectNodes() {
        guard let processingFormat = processingFormat else {
            AKLog("Error: the audioFile processingFormat is nil, so nothing can be connected.")
            return
        }

        var connectionFormat = processingFormat
        var playerOutput: AVAudioNode = playerNode

        // if there is a mixer that was creating, insert it in line
        // this is used only for dynamic sample rate conversion to
        // AKSettings.audioFormat if needed
        if let mixerNode = mixerNode {
            AKManager.connect(playerNode, to: mixerNode, format: processingFormat)
            connectionFormat = AKSettings.audioFormat
            playerOutput = mixerNode
        }

        if let faderNode = faderNode {
            AKManager.connect(playerOutput, to: faderNode.avAudioUnitOrNode, format: connectionFormat)
        }

        faderNode?.bypass()
    }

    // MARK: - Play

    /// Play entire file right now
    @objc public override func play() {
        play(from: startTime, to: endTime, at: nil, hostTime: nil)
    }

    /// Play using full options. Last in the convenience play chain, all play() commands will end up here
    // Placed in main class to be overriden in subclasses if needed.
    public func play(from startingTime: Double, to endingTime: Double, at audioTime: AVAudioTime?, hostTime: UInt64?) {
        let refTime = hostTime ?? mach_absolute_time()
        let audioTime = audioTime ?? AVAudioTime.now()

        isPlaying = true

        preroll(from: startingTime, to: endingTime)
        schedulePlayer(at: audioTime, hostTime: refTime)

        // prepare the fader
        if isFaded, !isBufferFaded {
            scheduleFader()
            faderNode?.parameterAutomation?.startPlayback(at: audioTime, offset: offsetTime)
        }

        // and play
        playerNode.play()
        pauseTime = nil
    }

    /// Stop playback and cancel any pending scheduled playback or completion events
    @objc public override func stop() {
        stopCompletion()
    }

    // MARK: - Deinit

    /// Dispose the audio file, buffer and nodes and release resources.
    /// Only call when you are totally done with this class.
    @objc public override func detach() {
        stop()
        super.detach() // get rid of the faderNode
        audioFile = nil
        buffer = nil
        AKManager.detach(nodes: [playerNode])

        if let mixerNode = self.mixerNode {
            AKManager.detach(nodes: [mixerNode])
            self.mixerNode = nil
        }
    }

    @objc deinit {
        AKLog("* { AKPlayer }")
    }
}
