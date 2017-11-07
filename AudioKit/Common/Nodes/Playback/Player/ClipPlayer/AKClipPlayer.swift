//
//  AKClipPlayer.swift
//  AudioKit
//
//  Created by David O'Neill on 6/13/17.
//  Copyright © 2017 Audive Inc. All rights reserved.
//

/// Schedules multiple audio files to be played in a sequence.
open class AKClipPlayer: AKNode, AKTiming {

    private var timeAtStart: Double = 0

    /// The underlying player node
    open let playerNode = AVAudioPlayerNode()
    private var mixer = AVAudioMixerNode()
    private var scheduled = false
    private var _clips = [FileClip]()

    /// Sets the current time in seconds.
    open func setTime(_ time: Double) {
        playerNode.stop()
        timeAtStart = time
    }

    /// Time in seconds at a given audio time
    ///
    /// - parameter audioTime: A time in the audio render context.
    /// - Returns: Time in seconds in the context of the player's timeline.
    ///
    open func time(atAudioTime audioTime: AVAudioTime?) -> Double {
        guard let playerTime = playerNode.playerTime(forNodeTime: audioTime ?? AVAudioTime.now()) else {
            return timeAtStart
        }
        return timeAtStart + Double(playerTime.sampleTime) / playerTime.sampleRate
    }

    /// Audio time for a given time.
    ///
    /// - Parameter time: Time in seconds in the context of the player's timeline.
    /// - Returns: A time in the audio render context.
    ///
    open func audioTime(atTime time: Double) -> AVAudioTime? {
        let sampleRate = playerNode.outputFormat(forBus: 0).sampleRate
        let sampleTime = (time - timeAtStart) * sampleRate
        let playerTime = AVAudioTime(sampleTime: AVAudioFramePosition(sampleTime), atRate: sampleRate)
        return playerNode.nodeTime(forPlayerTime: playerTime)
    }

    /// Current time of the player in seconds.
    open var currentTime: Double {
        get { return time(atAudioTime: nil) }
        set { setTime(newValue) }
    }

    /// True is play, flase if not.
    open var isPlaying: Bool {
        return playerNode.isPlaying
    }

    // swiftlint:disable force_cast

    /// Sets the clips sequence, throws if clips are invalid.
    ///
    /// In order for a clip sequence to be valid, they must be ordered by time, and
    /// time + duration must not exceed the following clip in sequence's time.  It's
    /// recommended to use A clip merger like AKFileClipSequence to build and modify
    /// the clips sequence.
    ///
    /// - Parameter clips: a validated array of Objects conforming to the FileClip protocol,
    /// use AKFileClips if you don't need custom behavior.
    /// - Throws: ClipMergeError if clips aren't valid.
    ///
    open func setClips(clips: [FileClip]) throws {
        try _clips = AKClipMerger.validateClips(clips) as! [FileClip]
        self.stop()
        scheduled = false
    }
    // swiftlint:enable force_cast

    /// A valid clip sequence.
    open var clips: [FileClip] {
        get {
            return _clips
        }
        set {
            do {
                try setClips(clips: newValue)
            } catch {
                print(error)
            }
        }
    }

    // Offsets clips' time and duration when starting mid clip before scheduling
    private func scheduleClips(at offset: Double) {
        self.stop()

        for clip in clips {
            if clip.time < offset {
                if offset < clip.endTime {
                    let diff = offset - clip.time

                    scheduleFile(audioFile: clip.audioFile,
                                 time: 0,
                                 offset: clip.offset + diff,
                                 duration: clip.duration - diff,
                                 completion: nil)
                }

            } else {
                scheduleFile(audioFile: clip.audioFile,
                             time: clip.time - offset,
                             offset: clip.offset,
                             duration: clip.duration,
                             completion: nil)
            }
        }
        scheduled = true
    }

    // swiftlint:disable force_cast

    /// Initializes a clipPlayer with clips.
    ///
    /// See setClips for discussion of clips validation
    ///
    /// - Parameter clips: a validated array of Objects conforming to the FileClip protocol,
    /// use AKFileClips if you don't need custom behavior.
    /// - Returns: A new player with clips if clips are valid, nil if not.
    ///
    public convenience init?(clips: [FileClip]) {
        do {
            let validatedClips = try AKClipMerger.validateClips(clips) as! [FileClip]
            self.init()
            _clips = validatedClips
        } catch {
            print(error)
            return nil
        }

    }
    // swiftlint:enable force_cast

    public override init() {
        AudioKit.engine.attach(playerNode)
        AudioKit.engine.attach(mixer)
        AudioKit.engine.connect(playerNode, to: mixer)
        super.init(avAudioNode: mixer, attach: false)
    }

    // Converts clip's parameters into sample times, and schedules the internal player to play them.
    private func scheduleFile(audioFile: AKAudioFile,
                              time: Double,
                              offset: Double,
                              duration: Double,
                              completion: (() -> Void)?) {
        let outputSamplerate = playerNode.outputFormat(forBus: 0).sampleRate
        let offsetFrame = AVAudioFramePosition(round(offset * audioFile.processingFormat.sampleRate))
        let frameCount = AVAudioFrameCount(round(duration * audioFile.processingFormat.sampleRate))

        let startTime = AVAudioTime(sampleTime: AVAudioFramePosition(round(time * outputSamplerate)),
                                    atRate: outputSamplerate)
        playerNode.scheduleSegment(audioFile,
                                   startingFrame: offsetFrame,
                                   frameCount: frameCount,
                                   at: startTime,
                                   completionHandler: completion)
    }

    /// Prepares previously scheduled file regions or buffers for playback.
    ///
    /// - Parameter frameCount: The number of sample frames of data to be prepared before returning.
    ///
    open func prepare(withFrameCount frameCount: AVAudioFrameCount) {
        if !scheduled {
            scheduleClips(at: currentTime)
        }
        playerNode.prepare(withFrameCount: frameCount)
    }

    /// Starts playback at next render cycle, AVAudioEngine must be running.
    open func play() {
        play(at: nil)
    }

    /// Starts playback at time
    ///
    /// - Parameter audioTime: A time in the audio render context.  If non-nil, the player's current
    /// current time will align with this time when playback starts.
    ///
    open func play(at audioTime: AVAudioTime?) {
        if !scheduled {
            scheduleClips(at: currentTime)
        }
        playerNode.play(at: audioTime)
        scheduled = false
    }

    /// Stops playback.
    open func stop() {
        timeAtStart = time(atAudioTime: nil)
        playerNode.stop()
        scheduled = false
    }

    /// Volume 0.0 -> 1.0, default 1.0
    open var volume: Float {
        get { return playerNode.volume }
        set { playerNode.volume = newValue }
    }

    /// Left/Right balance -1.0 -> 1.0, default 0.0
    open var pan: Float {
        get { return playerNode.pan }
        set { playerNode.pan = newValue }
    }
}
