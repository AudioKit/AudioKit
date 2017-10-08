//
//  AKAudioPlayer.swift
//  AudioKit
//
//  Created by Aurelius Prochazka, Laurent Veliscek & Ryan Francesconi, revision history on Github.
//  Copyright © 2017 Aurelius Prochazka. All rights reserved.
//

/// Not so simple audio playback class
open class AKAudioPlayer: AKNode, AKToggleable {

    // MARK: - Private variables
    fileprivate var internalAudioFile: AKAudioFile
    fileprivate var internalPlayer = AVAudioPlayerNode()
    fileprivate var internalMixer = AVAudioMixerNode()
    fileprivate var totalFrameCount: UInt32 = 0
    fileprivate var startingFrame: UInt32 = 0
    fileprivate var endingFrame: UInt32 = 0
    fileprivate var framesToPlayCount: UInt32 = 0
    fileprivate var lastCurrentTime: Double = 0
    fileprivate var paused = false
    fileprivate var playing = false
    fileprivate var internalStartTime: Double = 0
    fileprivate var internalEndTime: Double = 0
    fileprivate var scheduledStopAction: AKScheduledAction?

    // MARK: - Properties

    /// Buffer to be played
    @objc fileprivate var _audioFileBuffer: AVAudioPCMBuffer?
    @objc open dynamic var audioFileBuffer: AVAudioPCMBuffer? {
        get {
            if _audioFileBuffer == nil { updatePCMBuffer() }
            return _audioFileBuffer
        }
        set {
            _audioFileBuffer = newValue
        }
    }

    /// Will be triggered when AKAudioPlayer has finished to play.
    /// (will not as long as loop is on)
    @objc open dynamic var completionHandler: AKCallback?

    private var _looping: Bool = false {
        didSet {
            updateBufferLooping()
        }
    }

    /// Boolean indicating whether or not to loop the playback (Default false)
    @objc open dynamic var looping: Bool {
        set {
            guard  newValue != _looping else {
                return
            }
            _looping = newValue
        }
        get { return _looping }
    }

    /// Boolean indicating to play the buffer in reverse
    @objc open dynamic var reversed: Bool = false {
        didSet {
            updatePCMBuffer()
        }
    }

    /// Fade in duration
    @objc open dynamic var fadeInTime: Double = 0 {
        didSet {
            updatePCMBuffer()
        }
    }

    /// Fade out duration
    @objc open dynamic var fadeOutTime: Double = 0 {
        didSet {
            updatePCMBuffer()
        }
    }

    /// The current played AKAudioFile
    @objc open dynamic var audioFile: AKAudioFile {
        return internalAudioFile
    }

    /// Path to the currently loaded AKAudioFile
    @objc open dynamic var path: String {
        return audioFile.url.path
    }

    /// Total duration of one loop through of the file
    @objc open dynamic var duration: Double {
        return Double(totalFrameCount) / Double(internalAudioFile.sampleRate)
    }

    /// Output Volume (Default 1)
    @objc open dynamic var volume: Double = 1.0 {
        didSet {
            volume = max(volume, 0)
            internalPlayer.volume = Float(volume)
        }
    }

    /// Whether or not the audio player is currently started
    @objc open dynamic var isStarted: Bool {
        return  internalPlayer.isPlaying
    }

    /// Current playback time (in seconds)
    @objc open dynamic var currentTime: Double {
        if playing {
            if let nodeTime = internalPlayer.lastRenderTime,
                let playerTime = internalPlayer.playerTime(forNodeTime: nodeTime) {
                return Double(playerTime.sampleTime) / playerTime.sampleRate
            }

        }
        return lastCurrentTime
    }

    /// Time within the audio file at the current time
    @objc open dynamic var playhead: Double {

        let endTime = Double(endingFrame) / internalAudioFile.sampleRate
        let startTime = Double(startingFrame) / internalAudioFile.sampleRate

        if endTime > startTime {

            if looping {
                return  startTime + currentTime.truncatingRemainder(dividingBy: (endTime - startTime))
            } else {
                if currentTime > endTime {
                    return (startTime + currentTime).truncatingRemainder(dividingBy: (endTime - startTime))
                } else {
                    return (startTime + currentTime)
                }
            }
        } else {
            return 0
        }
    }

    /// Pan (Default Center = 0)
    @objc open dynamic var pan: Double = 0.0 {
        didSet {
            pan = (-1...1).clamp(pan)
            internalPlayer.pan = Float(pan)
        }
    }

    /// sets the start time, If it is playing, player will
    /// restart playing from the start time each time end time is set
    @objc open dynamic var startTime: Double {
        get {
            return Double(startingFrame) / internalAudioFile.sampleRate

        }
        set {
            // since setting startTime will fill the buffer again, we only want to do this if the
            // data really needs to be updated
            if newValue > Double(endingFrame) / internalAudioFile.sampleRate && endingFrame > 0 {
                AKLog("ERROR: AKAudioPlayer cannot set a startTime bigger than the endTime: " +
                    "\(Double(endingFrame) / internalAudioFile.sampleRate) seconds")

            } else {
                startingFrame = UInt32(newValue * internalAudioFile.sampleRate)

                AKLog("AKAudioPlayer.startTime = \(newValue), startingFrame: \(startingFrame)")

                // now update the buffer
                updatePCMBuffer()

                // remember this value for ease of checking redundancy later
                internalStartTime = newValue
            }

        }
    }

    /// sets the end time, If it is playing, player will
    /// restart playing from the start time each time end time is set
    @objc open dynamic var endTime: Double {
        get {
            return Double(endingFrame) / internalAudioFile.sampleRate

        }
        set {
            // since setting startTime will fill the buffer again, we only want to do this if the
            // data really needs to be updated
            if newValue == internalEndTime {
                //AKLog("endTime is the same, so returning: \(newValue)")
                return

            } else if newValue == 0 {
                endingFrame = totalFrameCount

            } else if newValue < Double(startingFrame) / internalAudioFile.sampleRate
                || newValue > Double(Double(totalFrameCount) / internalAudioFile.sampleRate) {
                AKLog("ERROR: AKAudioPlayer cannot set an endTime more than file's duration: \(duration) seconds or " +
                    "less than startTime: \(Double(startingFrame) / internalAudioFile.sampleRate) seconds")
            } else {
                endingFrame = UInt32(newValue * internalAudioFile.sampleRate)

                AKLog("AKAudioPlayer.endTime = \(newValue), endingFrame: \(endingFrame)")

                // now update the buffer
                updatePCMBuffer()

                // remember this value for ease of checking redundancy later
                internalEndTime = newValue
            }
        }
    }

    /// Sets the time in the future when playback will commence. Recommend using play(from:to:avTime) instead.
    /// this will be deprecated
    @objc open dynamic var scheduledTime: Double = 0 {
        didSet {
            let hostTime = mach_absolute_time()
            scheduledAVTime = AKAudioPlayer.secondsToAVAudioTime(hostTime: hostTime, time: scheduledTime)
        }
    }

    /// Sheduled time
    @objc open dynamic var scheduledAVTime: AVAudioTime?

    // MARK: - Initialization

    /// Initialize the audio player
    ///
    ///
    /// Notice that completionCallBack will be triggered from a
    /// background thread. Any UI update should be made using:
    ///
    /// ```
    /// Dispatch.main.async {
    ///    // UI updates...
    /// }
    /// ```
    ///
    /// - Parameters:
    ///   - file: the AKAudioFile to play
    ///   - looping: will loop play if set to true, or stop when play ends, so it can trig the 
    ///              completionHandler callback. Default is false (non looping)
    ///   - completionHandler: AKCallback that will be triggered when the player end playing (useful for refreshing 
    ///                        UI so we're not playing anymore, we stopped playing...)
    ///
    /// - Returns: an AKAudioPlayer if init succeeds, or nil if init fails. If fails, errors may be caught.
    ///
    @objc public init(file: AKAudioFile,
                      looping: Bool = false,
                      lazyBuffering: Bool = false,
                      completionHandler: AKCallback? = nil) throws {

        let readFile: AKAudioFile

        // Open the file for reading to avoid a crash when setting frame position
        // if the file was instantiated for writing
        do {
            readFile = try AKAudioFile(forReading: file.url)

        } catch let error as NSError {
            AKLog("AKAudioPlayer Error: cannot open file \(file.fileNamePlusExtension) for reading")
            AKLog("Error: \(error)")
            throw error
        }
        internalAudioFile = readFile
        self.completionHandler = completionHandler

        super.init()
        self.looping = looping
        AudioKit.engine.attach(internalPlayer)
        AudioKit.engine.attach(internalMixer)
        let format = AVAudioFormat(standardFormatWithSampleRate: internalAudioFile.sampleRate,
                                   channels: internalAudioFile.channelCount)
        AudioKit.engine.connect(internalPlayer, to: internalMixer, format: format)
        avAudioNode = internalMixer
        internalPlayer.volume = 1.0

        initialize(lazyBuffering: lazyBuffering)
    }

    fileprivate var defaultBufferOptions: AVAudioPlayerNodeBufferOptions {
        return looping ? [.loops, .interrupts] : [.interrupts]
    }

    // MARK: - Methods

    /// Start playback
    @objc open func start() {
        play(at:nil)
    }

    open func play(at when: AVAudioTime?) {

        if ❗️playing {
            if audioFileBuffer != nil {
                // schedule it at some point in the future / or immediately if 0
                // don't schedule the buffer if it is paused as it will overwrite what is in it
                if ❗️paused {
                    scheduleBuffer(atTime: scheduledAVTime, options: defaultBufferOptions)
                }

                internalPlayer.play(at: when)

                playing = true
                paused = false

            } else {
                AKLog("AKAudioPlayer Warning: cannot play an empty buffer")
            }
        } else {
            AKLog("AKAudioPlayer Warning: already playing")
        }
    }

    /// Stop playback
    @objc open func stop() {
        scheduledStopAction = nil

        if ❗️playing {
            return
        }

        lastCurrentTime = Double(startTime / internalAudioFile.sampleRate)
        playing = false
        paused = false

        internalPlayer.stop()
    }

    /// Pause playback
    open func pause() {
        if playing {
            if ❗️paused {
                lastCurrentTime = currentTime
                playing = false
                paused = true
                internalPlayer.pause()
            } else {
                AKLog("AKAudioPlayer Warning: already paused")
            }
        } else {
            AKLog("AKAudioPlayer Warning: Cannot pause when not playing")
        }
    }

    /// Restart playback from current position
    open func resume() {
        if paused {
            self.play()
        }
    }

    /// resets in and out times for playing
    open func reloadFile() throws {
        let wasPlaying = playing
        if wasPlaying {
            stop()
        }
        var newAudioFile: AKAudioFile?

        do {
            newAudioFile = try AKAudioFile(forReading: internalAudioFile.url)
        } catch let error as NSError {
            AKLog("AKAudioPlayer Error: Couldn't reLoadFile")
            AKLog("Error: \(error)")
            throw error
        }

        if let newFile = newAudioFile {
            internalAudioFile = newFile
        }
        internalPlayer.reset()

        let format = AVAudioFormat(standardFormatWithSampleRate: internalAudioFile.sampleRate, channels: internalAudioFile.channelCount)
        AudioKit.engine.connect(internalPlayer, to: internalMixer, format: format)

        initialize()

        if wasPlaying {
            start()
        }
    }

    /// Replace player's file with a new AKAudioFile file
    @objc open func replace(file: AKAudioFile) throws {
        internalAudioFile = file
        do {
            try reloadFile()
        } catch let error as NSError {
            AKLog("AKAudioPlayer Error: Couldn't reload replaced File: \"\(file.fileNamePlusExtension)\"")
            AKLog("Error: \(error)")
        }
        AKLog("AKAudioPlayer -> File with \"\(internalAudioFile.fileNamePlusExtension)\" Reloaded")
    }

    /// Default play that will use the previously set startTime and endTime properties or the full file if both are 0
    open func play() {
        play(from: self.startTime, to: self.endTime, avTime: nil)
    }

    /// Play from startTime to endTime
    @objc open func play(from startTime: Double, to endTime: Double) {
        play(from: startTime, to: endTime, avTime: nil)
    }

    /// Play the file back from a certain time, to an end time (if set).
    /// You can optionally set a scheduled time to play (in seconds).
    ///
    ///  - Parameters:
    ///    - startTime: Time into the file at which to start playing back
    ///    - endTime: Time into the file at which to playing back will stop / Loop
    ///    - scheduledTime: use this when scheduled playback doesn't need to be in sync with other players
    ///         otherwise use the avTime signature.
    ///
    open func play(from startTime: Double, to endTime: Double, when scheduledTime: Double) {
        let hostTime = mach_absolute_time()
        let avTime = AKAudioPlayer.secondsToAVAudioTime(hostTime: hostTime, time: scheduledTime)
        play(from: startTime, to: endTime, avTime: avTime)
    }

    /// Play the file back from a certain time, to an end time (if set). You can optionally set a scheduled time 
    /// to play (in seconds).
    ///
    ///  - Parameters:
    ///    - startTime: Time into the file at which to start playing back
    ///    - endTime: Time into the file at which to playing back will stop / Loop
    ///    - avTime: an AVAudioTime object specifying when to schedule the playback. You can create this using the 
    ///              helper function AKAudioPlayer.secondToAVAudioTime(hostTime:time). hostTime is a call to 
    ///              mach_absolute_time(). When you have a group of players which you want to sync together it's 
    ///              important that this value be the same for all of them as a reference point.
    ///
    open func play(from startTime: Double, to endTime: Double, avTime: AVAudioTime? ) {
        schedule(from: startTime, to: endTime, avTime: avTime)
        if endingFrame > startingFrame {
            start()
        } else {
            AKLog("ERROR AKaudioPlayer: cannot play, \(internalAudioFile.fileNamePlusExtension) " +
                "is empty or segment is too short")
        }
    }

    open func schedule(from startTime: Double, to endTime: Double, avTime: AVAudioTime? ) {
        stop()

        if endTime > 0 {
            self.endTime = endTime
        }
        self.startTime = startTime
        scheduledAVTime = avTime
    }

    /// return the peak time in the currently loaded buffer
    open func getPeakTime() -> Double {
        guard let buffer = audioFileBuffer else { return 0 }
        return AKAudioFile.findPeak(pcmBuffer: buffer)
    }

    // MARK: - Static Methods

    /// Convert to AVAudioTime
    open class func secondsToAVAudioTime(hostTime: UInt64, time: Double) -> AVAudioTime {
        // Find the conversion factor from host ticks to seconds
        var timebaseInfo = mach_timebase_info()
        mach_timebase_info(&timebaseInfo)
        let hostTimeToSecFactor = Double(timebaseInfo.numer) / Double(timebaseInfo.denom) / Double(NSEC_PER_SEC)

        let out = AVAudioTime(hostTime: hostTime + UInt64(time / hostTimeToSecFactor))
        return out
    }

    // MARK: - Private Methods

    fileprivate func initialize(lazyBuffering: Bool = false) {
        audioFileBuffer = nil
        totalFrameCount = UInt32(internalAudioFile.length)
        startingFrame = 0
        endingFrame = totalFrameCount

        if !lazyBuffering {
            updatePCMBuffer()
        }
    }

    fileprivate func scheduleBuffer(atTime: AVAudioTime?, options: AVAudioPlayerNodeBufferOptions) {
        scheduledStopAction = nil

        if let buffer = audioFileBuffer {
            scheduledStopAction = nil
            internalPlayer.scheduleBuffer(buffer,
                                          at: atTime,
                                          options: options,
                                          completionHandler: looping ? nil : internalCompletionHandler)

            if atTime != nil {
                internalPlayer.prepare(withFrameCount: framesToPlayCount)
            }
        }
    }

    fileprivate func updateBufferLooping() {
        guard playing else {
            return
        }
        if looping {
            // Looping is toggled on: schedule the buffer to loop at the next loop interval.
            let options: AVAudioPlayerNodeBufferOptions = [.loops, .interruptsAtLoop]
            scheduleBuffer(atTime: nil, options: options)
        } else {
            // Looping is toggled off: schedule to stop at the end of the current loop.
            stopAtNextLoopEnd()
        }
    }

    /// Stop playback after next loop completes
    @objc open func stopAtNextLoopEnd() {
        guard playing else {
            return
        }
        scheduledStopAction = AKScheduledAction(interval: endTime - currentTime) {
            self.stop()
            self.completionHandler?()
        }
    }

    /// Fills the buffer with data read from internalAudioFile
    fileprivate func updatePCMBuffer() {

        guard internalAudioFile.length > 0 else {
            AKLog("AKAudioPlayer Warning:  \"\(internalAudioFile.fileNamePlusExtension)\" is an empty file")
            return
        }

        var theStartFrame = startingFrame
        var theEndFrame = endingFrame

        // if we are going to be reversing the buffer, we need to think ahead a bit
        // since the edit points would be reversed as well, we swap them here:
        if reversed {
            let revEndTime = duration - startTime
            let revStartTime = endTime > 0 ? duration - endTime : duration

            theStartFrame = UInt32(revStartTime * internalAudioFile.sampleRate)
            theEndFrame = UInt32(revEndTime * internalAudioFile.sampleRate)
        }

        if internalAudioFile.samplesCount > 0 {
            internalAudioFile.framePosition = Int64(theStartFrame)
            framesToPlayCount = theEndFrame - theStartFrame

            //AKLog("framesToPlayCount: \(framesToPlayCount) frameCapacity \(totalFrameCount)")

            audioFileBuffer = AVAudioPCMBuffer(
                pcmFormat: internalAudioFile.processingFormat,
                frameCapacity: AVAudioFrameCount(totalFrameCount) )

            do {
                // read the requested frame count from the file
                try internalAudioFile.read(into: audioFileBuffer!, frameCount: framesToPlayCount)

                AKLog("read \(audioFileBuffer?.frameLength ?? 0) frames into buffer")

            } catch {
                AKLog("ERROR AKaudioPlayer: Could not read data into buffer.")
                return
            }

            // Now, we'll reverse the data in the buffer if desired...
            if reversed {
                reverseBuffer()
            }

            if fadeInTime > 0 || fadeOutTime > 0 {
                fadeBuffer(inTime: fadeInTime, outTime: fadeOutTime)
            }

        } else {
            AKLog("ERROR updatePCMBuffer: Could not set PCM buffer -> " +
                "\(internalAudioFile.fileNamePlusExtension) samplesCount = 0.")
        }
    }

    /// Turn the buffer around!
    fileprivate func reverseBuffer() {
        guard let buffer = audioFileBuffer else {
            AKLog("Unable to create buffer in reverseBuffer")
            return
        }

        let reverseBuffer = AVAudioPCMBuffer(
            pcmFormat: internalAudioFile.processingFormat,
            frameCapacity: buffer.frameCapacity
        )

        var j: Int = 0
        let length = buffer.frameLength
        //AKLog("reverse() preparing \(length) frames")

        // i represents the normal buffer read in reverse
        for i in (0 ..< Int(length)).reversed() {
            // n is the channel
            for n in 0 ..< Int(buffer.format.channelCount) {
                // we write the reverseBuffer via the j index
                reverseBuffer?.floatChannelData?[n][j] = buffer.floatChannelData?[n][i] ?? 0.0
            }
            j += 1
        }
        // set the buffer now to be the reverse one
        audioFileBuffer = reverseBuffer
        // update this to the new value
        audioFileBuffer?.frameLength = length
    }

    /// Apply sample level fades to the internal buffer.
    ///  - Parameters:
    ///     - inTime specified in seconds, 0 if no fade
    ///     - outTime specified in seconds, 0 if no fade
    fileprivate func fadeBuffer(inTime: Double = 0, outTime: Double = 0) {
        guard audioFileBuffer != nil else {
            AKLog("audioFileBuffer is nil")
            return
        }

        // do nothing in this case
        if inTime == 0 && outTime == 0 {
            AKLog("no fades specified.")
            return
        }

        let fadeBuffer = AVAudioPCMBuffer(
            pcmFormat: internalAudioFile.processingFormat,
            frameCapacity: audioFileBuffer!.frameCapacity )

        let length: UInt32 = audioFileBuffer!.frameLength
        AKLog("fadeBuffer() inTime: \(inTime) outTime: \(outTime)")

        // initial starting point for the gain, if there is a fade in, start it at .01 otherwise at 1
        var gain: Double = inTime > 0 ? 0.01 : 1

        let sampleTime: Double = 1.0 / internalAudioFile.processingFormat.sampleRate

        // from -20db?
        let fadeInPower: Double = exp(log(10) * sampleTime / inTime)

        // for decay to x% amplitude (-dB) over the given decay time
        let fadeOutPower: Double = exp(-log(25) * sampleTime / outTime)

        // where in the buffer to end the fade in
        let fadeInSamples = Int(internalAudioFile.processingFormat.sampleRate * inTime)
        // where in the buffer to start the fade out
        let fadeOutSamples = Int(Double(length) - (internalAudioFile.processingFormat.sampleRate * outTime))

        //Swift.print("fadeInPower \(fadeInPower) fadeOutPower \(fadeOutPower)")

        // i is the index in the buffer
        for i in 0 ..< Int(length) {
            // n is the channel
            for n in 0 ..< Int(audioFileBuffer!.format.channelCount) {

                if i < fadeInSamples && inTime > 0 {
                    gain *= fadeInPower
                } else if i > fadeOutSamples && outTime > 0 {
                    gain *= fadeOutPower
                } else {
                    gain = 1.0
                }

                //sanity check
                if gain > 1 {
                    gain = 1
                }

                let sample = audioFileBuffer!.floatChannelData![n][i] * Float(gain)
                fadeBuffer?.floatChannelData?[n][i] = sample
            }
        }
        // set the buffer now to be the faded one
        audioFileBuffer = fadeBuffer
        // update this
        audioFileBuffer?.frameLength = length
    }

    /// Triggered when the player reaches the end of its playing range
    fileprivate func internalCompletionHandler() {
        DispatchQueue.main.async {
            if self.isPlaying {
                self.stop()
                self.completionHandler?()
            }
        }
    }

    // Disconnect the node
    override open func disconnect() {
        AudioKit.detach(nodes: [self.avAudioNode])
        AudioKit.engine.detach(self.internalPlayer)
    }
}
