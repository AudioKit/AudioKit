//
//  AKTiming.swift
//  AudioKit
//
//  Created by David O'Neill on 5/8/17.
//  Copyright © 2017 Audive Inc. All rights reserved.
//

/// A timing protocol used for syncronizing different audio sources.
@objc protocol AKTiming {

    /// Starts playback at a specific time.
    /// - Parameter audioTime: A time in the audio render context.
    ///
    func play(at audioTime: AVAudioTime?)

    /// Stops playback immediately.
    func stop()

    /// Start playback immediately.
    func play()

    /// Set time in playback timeline (seconds).
    func setTime(_ time: Double)

    /// Timeline time at an audio time
    /// - Parameter audioTime: A time in the audio render context.
    /// - Return: Time in the timeline context (seconds).
    ///
    func time(atAudioTime audioTime: AVAudioTime?) -> Double

    /// Audio time at timeline time
    /// - Parameter time: Time in the timeline context (seconds).
    /// - Return: A time in the audio render context.
    ///
    func audioTime(atTime time: Double) -> AVAudioTime?

}

/// An AKTiming implementation that uses a node for it's render time info.
class AKNodeTiming: NSObject, AKTiming {

    /// An output node used for tming info.
    weak var node: AKOutput?

    // Used to hold current time when not playing.
    private var idleTime = Double()

    // When playback begins, this is set to a time in the past that represent "time zero" in 
    // the timeline.
    private var baseTime: AVAudioTime?

    /// The current time in the timeline (seconds).
    public var currentTime: Double {
        get { return time(atAudioTime: nil) }
        set { setTime(newValue) }
    }

    /// Sets the current time in the timeline (seconds).
    func setTime(_ time: Double) {
        stop()
        idleTime = time
    }

    /// Timeline time at an audio time
    /// - Parameter audioTime: A time in the audio render context.
    /// - Return: Time in the timeline context (seconds).
    ///
    func time(atAudioTime audioTime: AVAudioTime?) -> Double {
        guard let baseTime = baseTime else {
            return idleTime
        }
        let refTime = audioTime ?? AVAudioTime.now()
        return refTime.timeIntervalSince(otherTime: baseTime) ?? idleTime
    }

    /// Audio time at timeline time
    /// - Parameter time: Time in the timeline context (seconds).
    /// - Return: A time in the audio render context.
    ///
    func audioTime(atTime time: Double) -> AVAudioTime? {
        return baseTime?.offset(seconds: time)
    }

    /// Starts playback at a specific time.
    /// - Parameter audioTime: A time in the audio render context.
    ///
    func play(at audioTime: AVAudioTime?) {
        guard !isPlaying,
            let lastRenderTime = node?.outputNode.lastRenderTime else {
                return
        }
        baseTime = audioTime?.offset(seconds: -idleTime).extrapolateTimeShimmed(fromAnchor: lastRenderTime)
        baseTime = baseTime ?? lastRenderTime.offset(seconds: AKSettings.ioBufferDuration)
    }
    var isPlaying: Bool {
        return baseTime != nil
    }

    /// Start playback immediately.
    func play() {
        play(at: nil)
    }

    /// Stops playback immediately.
    func stop() {
        guard let baseTime = baseTime else {
            return
        }
        idleTime = AVAudioTime.now().timeIntervalSince(otherTime: baseTime) ?? idleTime
        self.baseTime = nil
    }

    /// Initialize with a node to be used for timing info.
    /// - Parameter node: A node to be used for timing information.
    init(node: AKOutput) {
        self.node = node
    }
}
