//
//  AKTiming.swift
//  AudioKit
//
//  Created by David O'Neill, revision history on GitHub.
//  Copyright © 2017 Audive Inc. All rights reserved.
//

/// A timing protocol used for syncronizing different audio sources.
@objc public protocol AKTiming {

    /// Starts playback at a specific time.
    /// - Parameter audioTime: A time in the audio render context.
    ///
    @objc func start(at audioTime: AVAudioTime?)

    /// Stops playback immediately.
    @objc func stop()

    var isStarted: Bool { get }

    /// Set position in playback timeline (seconds).
    @objc func setPosition(_ position: Double)

    /// Timeline time at an audio time
    /// - Parameter audioTime: A time in the audio render context.
    /// - Return: Position in the timeline context (seconds).
    ///
    @objc(positionAtAudioTime:)
    func position(at audioTime: AVAudioTime?) -> Double

    /// Audio time at timeline time
    /// - Parameter position: Time in the timeline context (seconds).
    /// - Return: A time in the audio render context.
    ///
    @objc(audioTimeAtPosition:)
    func audioTime(at position: Double) -> AVAudioTime?

    /// Prepare for playback.  After prepare has been called, the node should be ready to begine playback immediately.
    /// Any time consuming operations necessary for playback (eg. disk reads) should be complete once prepare has been called.
    ///
    @objc optional func prepare()

}

extension AKTiming {
    /**
     Starts an array of AKTimings at a position.

     Nodes are stopped, positions are set, then prepare is called (optional) on each node to allow
     for time consuming activities like reading from disk or buffering. Then, a future time is
     calculated using the last render timestamp (or now) + 2 render cycles to ensure synchronous start.

     - Parameter nodes: The nodes that will be synchronously started.
     - Parameter position: The position of the nodes when started.
     - Returns: The audioTime (in the future) that the nodes will be started at.
     */
    public static func syncStart(_ nodes: [AKTiming], at position: Double = 0) -> AVAudioTime {
        for node in nodes {
            node.stop()
            node.setPosition(position)
            node.prepare?()
        }

        let bufferDuration = AKSettings.ioBufferDuration
        let referenceTime = AKManager.engine.outputNode.lastRenderTime ?? AVAudioTime.now()
        let startTime = referenceTime + bufferDuration
        for node in nodes {
            node.start(at: startTime)
        }

        return startTime
    }

    /**
     Starts playback with position synchronized to an already running node.
     - Parameter other: An already started AKTiming that position will be synchronized with.
     - Parameter audioTime: Future time in the audio render context that playback should begin.
     */
    public func synchronizeWith(other: AKTiming, at audioTime: AVAudioTime? = nil) {
        stop()
        guard other.isStarted else {
            return
        }

        // If audioTime is nil, start playback 2 render cycles in the future.
        var startTime = audioTime
        if startTime == nil {
            let bufferDuration = AKSettings.ioBufferDuration
            let referenceTime = AKManager.engine.outputNode.lastRenderTime ?? AVAudioTime.now()
            startTime = referenceTime + bufferDuration
        }

        setPosition(other.position(at: startTime))
        start(at: startTime)
    }

}

/// An AKTiming implementation that uses a node for it's render time info.
open class AKNodeTiming: NSObject {

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

extension AKNodeTiming: AKTiming {
    public var isStarted: Bool {
        return baseTime != nil
    }

    public var isNotStarted: Bool { return !isStarted }

    open func position(at audioTime: AVAudioTime?) -> Double {
        guard let baseTime = baseTime else {
            return idleTime
        }
        let refTime = audioTime ?? AVAudioTime.now()
        return refTime.timeIntervalSince(otherTime: baseTime) ?? idleTime
    }

    open func audioTime(at position: Double) -> AVAudioTime? {
        return baseTime?.offset(seconds: position)
    }
    open func start(at audioTime: AVAudioTime?) {
        guard !isStarted,
            let lastRenderTime = node?.outputNode.lastRenderTime else {
                return
        }
        baseTime = audioTime?.offset(seconds: -idleTime).extrapolateTimeShimmed(fromAnchor: lastRenderTime)
        baseTime = baseTime ?? lastRenderTime.offset(seconds: AKSettings.ioBufferDuration)
    }
    open func setPosition(_ position: Double) {
        stop()
        idleTime = position
    }
}
