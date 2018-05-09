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
 scheduling of sounds, looping, fading, and reversing. Players can be locked to a common
 clock as well as video by using hostTime in the various play functions. By default the
 player will buffer audio as needed, otherwise it will play it from disk. Looping, reversing,
 or applying fades will cause the file to buffer.

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
        public static var minimumGain: Double = 0.000_2

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

    // MARK: - Private Parts

    // The underlying player node
    private let playerNode = AVAudioPlayerNode()
    private let faderNode = AKBooster()
    private let timePitchNode = AKTimePitch()
    private var mixer = AVAudioMixerNode()
    private var startingFrame: AVAudioFramePosition?
    private var endingFrame: AVAudioFramePosition?

    // these timers will go away when AudioKit is built for 10.13
    // in that case the real completion handlers of the scheduling can be used.
    // Pre 10.13 the completion handlers are inaccurate to the point of unusable.
    private var prerollTimer: Timer?
    private var completionTimer: Timer?
    private var faderTimer: Timer?

    // I've found that using the apple completion handlers for AVAudioPlayerNode can introduce some instability.
    // if you don't need them, you can disable them off here
    private var useCompletionHandler: Bool {
        return isLooping || completionHandler != nil
    }

    // startTime and endTime may be accessed from multiple thread contexts
    private let startTimeQueue = DispatchQueue(label: "io.AudioKit.AKPlayer.startTimeQueue")
    private let endTimeQueue = DispatchQueue(label: "io.AudioKit.AKPlayer.endTimeQueue")

    private var playerTime: Double {
        if let nodeTime = playerNode.lastRenderTime,
            let playerTime = playerNode.playerTime(forNodeTime: nodeTime) {
            return Double(playerTime.sampleTime) / playerTime.sampleRate
        }
        return 0
    }

    private var _startTime: Double = 0
    private var _endTime: Double = 0

    // MARK: - Public Properties

    /// Completion handler to be called when Audio is done playing. The handler won't be called if
    /// stop() is called while playing or when looping from a buffer.
    public var completionHandler: AKCallback?

    public var buffer: AVAudioPCMBuffer?

    /// Sets if the player should buffer dynamically (as needed) or always.
    /// Not buffering means streaming from disk (best for long files),
    /// buffering is playing from RAM (best for shorter sounds you might want to loop).
    /// For seamless looping you should load the sound into RAM.
    /// While this creates a perfect loop, the downside is that you can't easily scrub through the audio.
    /// If you need to be able to be able to scan around the file, keep this .dynamic and stream from disk.
    public var buffering: BufferingType = .dynamic {
        didSet {
            if buffering == .always {
                preroll()
            }
        }
    }

    /// The internal audio file
    public private(set) var audioFile: AVAudioFile?

    /// The duration of the loaded audio file
    public var duration: Double {
        guard let audioFile = audioFile else { return 0 }
        return Double(audioFile.length) / audioFile.fileFormat.sampleRate
    }

    /// Holds characteristics about the fade options.
    public var fade = Fade()

    /// Looping params
    public var loop = Loop()

    /// Volume 0.0 -> 1.0, default 1.0
    public var volume: Double {
        get {
            return Double(playerNode.volume)
        }

        set {
            playerNode.volume = Float(newValue)
        }
    }

    /// Amplification Factor, in the range of 0.0002 to 2
    public var gain: Double {
        get {
            return fade.maximumGain
        }

        set {
            // this is the value that the fader will fade to
            fade.maximumGain = newValue
            // this is the current value of the fader, set immediately
            faderNode.gain = newValue
        }
    }

    public var rate: Double {
        get {
            return timePitchNode.rate
        }

        set {
            timePitchNode.rate = newValue
            if timePitchNode.isBypassed && timePitchNode.rate != 1 {
                timePitchNode.start()
            }
        }
    }

    public var pitch: Double {
        get {
            return timePitchNode.pitch
        }

        set {
            timePitchNode.pitch = newValue
            if timePitchNode.isBypassed && timePitchNode.pitch != 0 {
                timePitchNode.start()
            }
        }
    }

    // convenience for setting both in and out fade ramp types
    public var rampType: AKSettings.RampType = .exponential {
        didSet {
            fade.inRampType = rampType
            fade.outRampType = rampType
        }
    }

    /// Left/Right balance -1.0 -> 1.0, default 0.0
    public var pan: Double {
        get {
            return Double(playerNode.pan)
        }
        set {
            playerNode.pan = Float(newValue)
        }
    }

    /// Get or set the start time of the player.
    public var startTime: Double {
        get {
            return max(0, _startTime)
        }

        set {
            startTimeQueue.sync {
                self._startTime = max(0, newValue)
            }
        }
    }

    /// Get or set the end time of the player.
    public var endTime: Double {
        get {
            return isLooping ? loop.end : _endTime
        }

        set {
            var newValue = newValue
            if newValue == 0 {
                newValue = duration
            }
            endTimeQueue.sync {
                self._endTime = min(newValue, duration)
            }
        }
    }

    /// - Returns: The total frame count that is being playing.
    /// Differs from the audioFile.length as this will be updated with the edited amount
    /// of frames based on startTime and endTime
    public private(set) var frameCount: AVAudioFrameCount = 0

    /// - Returns: The current frame while playing
    public var currentFrame: AVAudioFramePosition {
        if let nodeTime = playerNode.lastRenderTime,
            let playerTime = playerNode.playerTime(forNodeTime: nodeTime) {
            return playerTime.sampleTime
        }
        return 0
    }

    /// - Returns: Current time of the player in seconds while playing.
    public var currentTime: Double {
        let current = startTime + playerTime.truncatingRemainder(dividingBy: (endTime - startTime))
        return current
    }

    public var pauseTime: Double?

    // MARK: - Public Options
    /// true if the player is buffering audio rather than playing from disk
    public var isBuffered: Bool {
        return isNormalized || isReversed || buffering == .always
    }

    /// Will automatically normalize on buffer updates if enabled
    public var isNormalized: Bool = false {
        didSet {
            updateBuffer(force: true)
        }
    }

    /// true if any fades have been set
    public var isFaded: Bool {
        return fade.inTime > 0 || fade.outTime > 0
    }

    public var isLooping: Bool = false

    public var isPaused: Bool {
        return pauseTime != nil
    }

    /// Reversing the audio will set the player to buffering
    public var isReversed: Bool = false {
        didSet {
            if isPlaying {
                stop()
            }
            updateBuffer(force: true)
        }
    }

    public var isPlaying: Bool {
        return playerNode.isPlaying
    }

    // MARK: - Initialization

    /// Create a player from a URL
    public convenience init?(url: URL) {
        if !FileManager.default.fileExists(atPath: url.path) {
            return nil
        }
        do {
            let avfile = try AVAudioFile(forReading: url)
            self.init(audioFile: avfile)
            return
        } catch {
            AKLog("ERROR loading \(url.path) \(error)")
        }
        return nil
    }

    /// Create a player from an AVAudioFile (or AKAudioFile)
    public convenience init(audioFile: AVAudioFile) {
        self.init()
        self.audioFile = audioFile
        initialize()
    }

    public override init() {
        super.init(avAudioNode: mixer, attach: false)
    }

    private func initialize() {
        guard let audioFile = audioFile else { return }

        if playerNode.engine == nil {
            AudioKit.engine.attach(playerNode)
        }
        if mixer.engine == nil {
            AudioKit.engine.attach(mixer)
        }
        if faderNode.avAudioNode.engine == nil {
            AudioKit.engine.attach(faderNode.avAudioNode)
        }
        if faderNode.avAudioNode.engine == nil {
            AudioKit.engine.attach(faderNode.avAudioNode)
        }

        playerNode.disconnectOutput()

        let format = AVAudioFormat(standardFormatWithSampleRate: audioFile.fileFormat.sampleRate,
                                   channels: audioFile.fileFormat.channelCount)

        AudioKit.connect(playerNode, to: timePitchNode.avAudioNode, format: format)
        AudioKit.connect(timePitchNode.avAudioNode, to: faderNode.avAudioNode, format: format)
        AudioKit.connect(faderNode.avAudioNode, to: mixer, format: format)

        faderNode.gain = Fade.minimumGain
        faderNode.rampType = .linear
        timePitchNode.bypass() // bypass timePitch by default to save CPU
        loop.start = 0
        loop.end = duration
        buffer = nil
        preroll(from: 0, to: duration)
    }

    // MARK: - Loading

    /// Replace the contents of the player with this url
    public func load(url: URL) throws {
        let file = try AVAudioFile(forReading: url)
        load(audioFile: file)
    }

    public func load(audioFile: AVAudioFile) {
        self.audioFile = audioFile
        initialize()
    }

    /// Mostly applicable to buffered players, this loads the buffer and gets it ready to play.
    /// Otherwise it just sets the startTime and endTime
    public func preroll(from startingTime: Double = 0, to endingTime: Double = 0) {
        var from = startingTime
        let to = endingTime

        if from > to {
            from = 0
        }
        startTime = from
        endTime = to

        resetFader(false)

        guard isBuffered else { return }
        updateBuffer()
    }

    // MARK: - Playback

    /// Play entire file right now
    public func play() {
        play(from: startTime, to: endTime, at: nil, hostTime: nil)
    }

    /// Play segments of a file
    public func play(from startingTime: Double, to endingTime: Double = 0) {
        var to = endingTime
        if to == 0 {
            to = endTime
        }
        play(from: startingTime, to: to, at: nil, hostTime: nil)
    }

    /// Play file using previously set startTime and endTime at some point in the future
    public func play(at audioTime: AVAudioTime?) {
        play(at: audioTime, hostTime: nil)
    }

    /// Play file using previously set startTime and endTime at some point in the future with a hostTime reference
    public func play(at audioTime: AVAudioTime?, hostTime: UInt64?) {
        play(from: startTime, to: endTime, at: audioTime, hostTime: hostTime)
    }

    /// Play file using previously set startTime and endTime at some point in the future specified in seconds
    /// with a hostTime reference
    public func play(when scheduledTime: Double, hostTime: UInt64?) {
        play(from: startTime, to: endTime, when: scheduledTime, hostTime: hostTime)
    }

    public func play(from startingTime: Double,
                     to endingTime: Double,
                     when scheduledTime: Double,
                     hostTime: UInt64? = nil) {
        let refTime = hostTime ?? mach_absolute_time()
        let avTime = AVAudioTime.secondsToAudioTime(hostTime: refTime, time: scheduledTime)
        play(from: startingTime, to: endingTime, at: avTime, hostTime: refTime)
    }

    /// Play using full options. Last in the convenience play chain, all play() commands will end up here
    public func play(from startingTime: Double, to endingTime: Double, at audioTime: AVAudioTime?, hostTime: UInt64?) {
        preroll(from: startingTime, to: endingTime)
        schedule(at: audioTime, hostTime: hostTime)
        playerNode.play()

        if pitch != 0 || rate != 1 {
            timePitchNode.start()
        }

        faderNode.start()

        guard !isBuffered else {
            faderNode.gain = gain
            return
        }
        initFader(at: audioTime, hostTime: hostTime)
    }

    public func pause() {
        pauseTime = currentTime
        stop()
    }

    public func resume() {
        guard let pauseTime = pauseTime else {
            play()
            return
        }
        // clear the frame count in the player
        playerNode.stop()
        play(from: pauseTime)
    }
    /// Stop playback and cancel any pending scheduled playback or completion events
    public func stop() {
        playerNode.stop()
        resetFader(false)
        completionTimer?.invalidate()
        prerollTimer?.invalidate()
        faderTimer?.invalidate()

        // the time strecher draws a fair bit of CPU when it isn't bypassed, so auto bypass it
        timePitchNode.bypass()
        faderNode.bypass()
    }

    // MARK: - Fade Handlers

    private func initFader(at audioTime: AVAudioTime?, hostTime: UInt64?) {
        // AKLog(fade, faderNode.rampDuration, faderNode.gain, audioTime, hostTime)

        if faderTimer?.isValid ?? false {
            faderTimer?.invalidate()
        }

        guard fade.inTime != 0 || fade.outTime != 0 else {
            return
        }

        guard let hostTime = hostTime, var triggerTime = audioTime?.toSeconds(hostTime: hostTime) else {
            startFade()
            return
        }
        triggerTime /= rate
        AKLog("starting fade in", triggerTime, "seconds")

        DispatchQueue.main.async {
            self.faderTimer = Timer.scheduledTimer(timeInterval: triggerTime,
                                                   target: self,
                                                   selector: #selector(self.startFade),
                                                   userInfo: nil,
                                                   repeats: false)
        }

    }

    private func resetFader(_ state: Bool) {
        var state = state
        if fade.inTime == 0 {
            state = true
        }
        faderNode.rampType = fade.inRampType
        faderNode.rampDuration = AKSettings.rampDuration
        faderNode.gain = state ? fade.maximumGain : Fade.minimumGain
    }

    @objc private func startFade() {
        let inTime = fade.inTime - fade.inTimeOffset

        AKLog("Fading in to", fade.maximumGain)

        faderNode.rampDuration = AKSettings.rampDuration

        if inTime > 0 {
            faderNode.gain = Fade.minimumGain
            faderNode.rampDuration = inTime / rate
        }
        // set target gain and begin ramping
        faderNode.gain = fade.maximumGain
        faderTimer?.invalidate()

        guard fade.outTime > 0 else { return }

        if fade.outTimeOffset > 0 {
            // just fade now the remainder of the segment
            var midFadeDuration = duration - startTime
            if endTime < duration {
                midFadeDuration -= (duration - endTime)
            }
            fadeOutWithTime(midFadeDuration)
        } else {
            var when = (duration - startTime) - (duration - endTime) - fade.outTime
            when /= rate

            DispatchQueue.main.async {
                self.faderTimer = Timer.scheduledTimer(timeInterval: when,
                                                       target: self,
                                                       selector: #selector(self.fadeOut),
                                                       userInfo: nil,
                                                       repeats: false)
            }
        }
    }

    @objc private func fadeOut() {
        if fade.outTime > 0 {
            fadeOutWithTime(fade.outTime)
        }
    }

    private func fadeOutWithTime(_ time: Double) {
        if time > 0 {
            // at this point init the faderNode with the correct settings for fade out
            faderNode.rampType = fade.outRampType
            faderNode.rampDuration = time / rate
            faderNode.gain = Fade.minimumGain
            AKLog("Fading out to", Fade.minimumGain)
        }
    }

    // MARK: - Scheduling

    // NOTE to maintainers: these timers can be removed when AudioKit is built for 10.13.
    // in that case the AVFoundation completion handlers of the scheduling can be used.
    // Pre 10.13, the completion handlers are inaccurate to the point of unusable.

    // if the file is scheduled, start a timer to determine when to start the completion timer
    private func startPrerollTimer(_ prerollTime: Double) {
        DispatchQueue.main.async {
            self.prerollTimer = Timer.scheduledTimer(timeInterval: prerollTime,
                                                     target: self,
                                                     selector: #selector(self.startCompletionTimer),
                                                     userInfo: nil,
                                                     repeats: false)
        }
    }

    // keep this timer separate in the cases of sounds that aren't scheduled
    @objc private func startCompletionTimer() {
        var segmentDuration = endTime - startTime
        if isLooping && loop.end > 0 {
            segmentDuration = loop.end - startTime
        }

        DispatchQueue.main.async {
            self.completionTimer = Timer.scheduledTimer(timeInterval: segmentDuration,
                                                        target: self,
                                                        selector: #selector(self.handleComplete),
                                                        userInfo: nil,
                                                        repeats: false)
        }
    }

    private func schedule(at audioTime: AVAudioTime?, hostTime: UInt64?) {
        if isBuffered {
            scheduleBuffer(at: audioTime)
        } else {
            scheduleSegment(at: audioTime)
        }

        if #available(iOS 11, macOS 10.13, tvOS 11, *) {
            // nothing further is needed as the completion is specified in the scheduler
        } else {
            completionTimer?.invalidate()
            prerollTimer?.invalidate()

            if let audioTime = audioTime, let hostTime = hostTime {
                let prerollTime = audioTime.toSeconds(hostTime: hostTime)
                startPrerollTimer(prerollTime)
            } else {
                startCompletionTimer()
            }
        }
    }

    private func scheduleBuffer(at audioTime: AVAudioTime?) {
        guard let buffer = buffer else { return }

        if playerNode.outputFormat(forBus: 0) != buffer.format {
            initialize()
        }

        var bufferOptions: AVAudioPlayerNodeBufferOptions = [.interrupts] // isLooping ? [.loops, .interrupts] : [.interrupts]

        if isLooping && buffering == .always {
            bufferOptions = [.loops, .interrupts]
        }

        // AKLog("Scheduling buffer...\(startTime) to \(endTime)")
        if #available(iOS 11, macOS 10.13, tvOS 11, *) {
            playerNode.scheduleBuffer(buffer,
                                      at: audioTime,
                                      options: bufferOptions,
                                      completionCallbackType: .dataRendered,
                                      completionHandler: useCompletionHandler ? handleCallbackComplete : nil)
        } else {
            // Fallback on earlier version
            playerNode.scheduleBuffer(buffer,
                                      at: audioTime,
                                      options: bufferOptions,
                                      completionHandler: nil) // these completionHandlers are inaccurate pre 10.13
        }

        playerNode.prepare(withFrameCount: buffer.frameLength)
    }

    // play from disk rather than ram
    private func scheduleSegment(at audioTime: AVAudioTime?) {
        guard let audioFile = audioFile else { return }

        let startFrame = AVAudioFramePosition(startTime * audioFile.fileFormat.sampleRate)
        var endFrame = AVAudioFramePosition(endTime * audioFile.fileFormat.sampleRate)

        if endFrame == 0 {
            endFrame = audioFile.length
        }

        let totalFrames = (audioFile.length - startFrame) - (audioFile.length - endFrame)
        guard totalFrames > 0 else {
            AKLog("totalFrames to play is \(totalFrames). Bailing.")
            return
        }

        frameCount = AVAudioFrameCount(totalFrames)

        if #available(iOS 11, macOS 10.13, tvOS 11, *) {
            playerNode.scheduleSegment(audioFile,
                                       startingFrame: startFrame,
                                       frameCount: frameCount,
                                       at: audioTime,
                                       completionCallbackType: .dataRendered, // .dataPlayedBack,
                                       completionHandler: useCompletionHandler ? handleCallbackComplete : nil)
        } else {
            // Fallback on earlier version
            playerNode.scheduleSegment(audioFile,
                                       startingFrame: startFrame,
                                       frameCount: frameCount,
                                       at: audioTime,
                                       completionHandler: nil) // these completionHandlers are inaccurate pre 10.13
        }

        playerNode.prepare(withFrameCount: frameCount)
    }

    // MARK: - Completion Handlers

    // this will be the method in the scheduling completionHandler >= 10.13
    @available(iOS 11, macOS 10.13, tvOS 11, *)
    @objc private func handleCallbackComplete(completionType: AVAudioPlayerNodeCompletionCallbackType) {
        // AKLog("\(audioFile?.url.lastPathComponent ?? "?") currentFrame:\(currentFrame) totalFrames:\(frameCount) currentTime:\(currentTime)/\(duration)")
        // only forward the completion if is actually done playing.
        // if the user calls stop() themselves then the currentFrame will be < frameCount

        // it seems to be unstable having any outbound calls from this callback not be sent to main?
        DispatchQueue.main.async {
            // cancel any upcoming fades
            self.faderTimer?.invalidate()

            // reset the loop if user stopped it
            if self.isLooping && self.buffering == .always {
                self.startTime = self.loop.start
                self.endTime = self.loop.end
                self.pauseTime = nil
                return
            }
            if self.currentFrame >= self.frameCount {
                self.handleComplete()
            }
        }
    }

    @objc private func handleComplete() {
        stop()
        if isLooping {
            startTime = loop.start
            endTime = loop.end
            play()
            return
        }
        if pauseTime != nil {
            startTime = 0
            pauseTime = nil
        }
        completionHandler?()
    }

    // MARK: - Buffering routines

    // Fills the buffer with data read from audioFile
    private func updateBuffer(force: Bool = false) {
        if !isBuffered { return }
        guard let audioFile = audioFile else { return }

        let fileFormat = audioFile.fileFormat
        let processingFormat = audioFile.processingFormat
        var startFrame = AVAudioFramePosition(startTime * fileFormat.sampleRate)
        var endFrame = AVAudioFramePosition(endTime * fileFormat.sampleRate)

        // if we are going to be reversing the buffer, we need to think ahead a bit
        // since the edit points would be reversed as well, we swap them here:
        if isReversed {
            let revEndTime = duration - startTime
            let revStartTime = endTime > 0 ? duration - endTime : duration

            startFrame = AVAudioFramePosition(revStartTime * fileFormat.sampleRate)
            endFrame = AVAudioFramePosition(revEndTime * fileFormat.sampleRate)
        }

        let updateNeeded = (force ||
            buffer == nil ||
            startFrame != startingFrame ||
            endFrame != endingFrame
            || loop.needsUpdate
            || fade.needsUpdate)

        if !updateNeeded {
            // AKLog("No buffer update needed")
            return
        }

        guard audioFile.length > 0 else {
            AKLog("ERROR updateBuffer: Could not set PCM buffer -> " +
                "\(audioFile.fileNamePlusExtension) length = 0.")
            return
        }

        frameCount = AVAudioFrameCount(endFrame - startFrame)

        guard frameCount > 0 else {
            AKLog("totalFrames to play is \(frameCount). Bailing.")
            return
        }

        guard let pcmBuffer = AVAudioPCMBuffer(pcmFormat: processingFormat, frameCapacity: frameCount) else { return }

        do {
            audioFile.framePosition = startFrame
            // read the requested frame count from the file
            try audioFile.read(into: pcmBuffer, frameCount: frameCount)

            buffer = pcmBuffer

        } catch let err as NSError {
            AKLog("ERROR AKPlayer: Couldn't read data into buffer. \(err)")
            return
        }

        if isLooping {
            loop.needsUpdate = false
        }

        if isNormalized {
            normalizeBuffer()
        }

        // Now, we'll reverse the data in the buffer if specified
        if isReversed {
            reverseBuffer()
        }

        if isFaded {
            fadeBuffer(inTime: fade.inTime, outTime: fade.outTime)
            fade.needsUpdate = false
        }

        // these are only stored to check if the buffer needs to be updated in subsequent fills
        startingFrame = startFrame
        endingFrame = endFrame
    }

    // Read the buffer in backwards
    fileprivate func reverseBuffer() {
        guard isBuffered, let buffer = self.buffer else { return }
        if let reversededBuffer = buffer.reverse() {
            self.buffer = reversededBuffer
            AKLog("Reversed Buffer")
        }
    }

    fileprivate func normalizeBuffer() {
        guard isBuffered, let buffer = self.buffer else { return }
        if let normalizedBuffer = buffer.normalize() {
            self.buffer = normalizedBuffer
            AKLog("Normalized Buffer")
        }
    }

    /// Apply sample level fades to the internal buffer.
    ///  - Parameters:
    ///     - inTime specified in seconds, 0 if no fade
    ///     - outTime specified in seconds, 0 if no fade
    fileprivate func fadeBuffer(inTime: Double = 0, outTime: Double = 0) {
        guard isBuffered, let buffer = self.buffer else { return }
        if let fadedBuffer = buffer.fade(inTime: inTime,
                                         outTime: outTime,
                                         inRampType: fade.inRampType,
                                         outRampType: fade.outRampType) {
            self.buffer = fadedBuffer
            AKLog("Faded Buffer")
        }
    }

    /// Disconnect the node and release resources
    public override func disconnect() {
        stop()
        audioFile = nil
        buffer = nil
        AudioKit.detach(nodes: [mixer, playerNode])
    }

    deinit {
        AKLog("* deinit AKPlayer")
    }
}

extension AKPlayer: AKTiming {
    public func start(at audioTime: AVAudioTime?) {
        play(at: audioTime)
    }

    public var isStarted: Bool {
        return isPlaying
    }

    public func setPosition(_ position: Double) {
        startTime = position
        if isPlaying {
            stop()
            play()
        }
    }

    public func position(at audioTime: AVAudioTime?) -> Double {
        guard let playerTime = playerNode.playerTime(forNodeTime: audioTime ?? AVAudioTime.now()) else {
            return startTime
        }
        return startTime + Double(playerTime.sampleTime) / playerTime.sampleRate
    }

    public func audioTime(at position: Double) -> AVAudioTime? {
        let sampleRate = playerNode.outputFormat(forBus: 0).sampleRate
        let sampleTime = (position - startTime) * sampleRate
        let playerTime = AVAudioTime(sampleTime: AVAudioFramePosition(sampleTime), atRate: sampleRate)
        return playerNode.nodeTime(forPlayerTime: playerTime)
    }

    open func prepare() {
        preroll(from: startTime, to: endTime)
    }
}
