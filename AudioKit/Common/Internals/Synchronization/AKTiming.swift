//
//  AKTiming.swift
//  AudioKit
//
//  Created by David O'Neill on 5/8/17.
//  Copyright © 2017 Audive Inc. All rights reserved.
//

/// A timing protocol used for syncronizing different audio sources.
@objc public protocol AKTiming {

    /// Starts playback at a specific time.
    /// - Parameter audioTime: A time in the audio render context.
    ///
    func start(at audioTime: AVAudioTime?)

    /// Stops playback immediately.
    func stop()

    /// Set position in playback timeline (seconds).
    func setPosition(_ position: Double)

    /// Timeline time at an audio time
    /// - Parameter audioTime: A time in the audio render context.
    /// - Return: Position in the timeline context (seconds).
    ///
    @objc(positionAtAudioTime:)
    func position(at audioTime: AVAudioTime?) -> Double

    /// Audio time at timeline time
    /// - Parameter time: Time in the timeline context (seconds).
    /// - Return: A time in the audio render context.
    ///
    @objc(audioTimeAtPosition:)
    func audioTime(at position: Double) -> AVAudioTime?

}

/// An AKTiming implementation that uses a node for it's render time info.
open class AKNodeTiming: NSObject, AKTiming {

    /// An output node used for tming info.
    open weak var node: AKOutput?

    // Used to hold current time when not playing.
    private var idleTime = Double()

    // When playback begins, this is set to a time in the past that represent "time zero" in
    // the timeline.
    private var baseTime: AVAudioTime?

    /// The current time in the timeline (seconds).
    open var currentTime: Double {
        get { return position(at: nil) }
        set { setPosition(newValue) }
    }

    /// Sets the current time in the timeline (seconds).
    open func setPosition(_ position: Double) {
        stop()
        idleTime = position
    }

    /// Timeline time at an audio time
    /// - Parameter audioTime: A time in the audio render context.
    /// - Return: Time in the timeline context (seconds).
    ///
    open func position(at audioTime: AVAudioTime?) -> Double {
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
    open func audioTime(at position: Double) -> AVAudioTime? {
        return baseTime?.offset(seconds: position)
    }

    /// Starts playback at a specific time.
    /// - Parameter audioTime: A time in the audio render context.
    ///
    open func start(at audioTime: AVAudioTime?) {
        guard !isPlaying,
            let lastRenderTime = node?.outputNode.lastRenderTime else {
                return
        }
        baseTime = audioTime?.offset(seconds: -idleTime).extrapolateTimeShimmed(fromAnchor: lastRenderTime)
        baseTime = baseTime ?? lastRenderTime.offset(seconds: AKSettings.ioBufferDuration)
    }
    open var isPlaying: Bool {
        return baseTime != nil
    }

    /// Start playback immediately.
    open func start() {
        start(at: nil)
    }

    /// Stops playback immediately.
    open func stop() {
        guard let baseTime = baseTime else {
            return
        }
        idleTime = AVAudioTime.now().timeIntervalSince(otherTime: baseTime) ?? idleTime
        self.baseTime = nil
    }

    /// Initialize with a node to be used for timing info.
    /// - Parameter node: A node to be used for timing information.
    public init(node: AKOutput) {
        self.node = node
    }

}

