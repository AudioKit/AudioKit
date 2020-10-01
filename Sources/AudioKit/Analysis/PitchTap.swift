// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import AVFoundation
import CAudioKit

/// Tap to do pitch tracking on any node.
/// start() will add the tap, and stop() will remove it.
public class PitchTap: Toggleable {
    private var pitch: [Float] = [0, 0]
    private var amp: [Float] = [0, 0]
    private var trackers: [PitchTrackerRef] = []

    /// Size of buffer to analyze
    public private(set) var bufferSize: UInt32

    /// Tells whether the node is processing (ie. started, playing, or active)
    public private(set) var isStarted: Bool = false

    /// The bus to install the tap onto
    public var bus: Int = 0 {
        didSet {
            if isStarted {
                stop()
                start()
            }
        }
    }

    private var _input: Node

    /// Input node to analyze
    public var input: Node {
        get {
            return _input
        }
        set {
            guard newValue !== _input else { return }
            let wasStarted = isStarted

            // if the input changes while it's on, stop and start the tap
            if wasStarted {
                stop()
            }

            _input = newValue

            // if the input changes while it's on, stop and start the tap
            if wasStarted {
                start()
            }
        }
    }

    /// Detected amplitude (average of left and right channels)
    public var amplitude: Float {
        return amp.reduce(0, +) / 2
    }

    /// Detected frequency of left channel
    public var leftPitch: Float {
        return pitch[0]
    }

    /// Detected frequency of right channel
    public var rightPitch: Float {
        return pitch[1]
    }

    /// Callback type
    public typealias Handler = ([Float], [Float]) -> Void

    private var handler: Handler = { _, _ in }

    /// Initialize the pitch tap
    /// 
    /// - parameter input: Node to analyze
    /// - parameter bufferSize: Size of buffer to analyze
    /// - parameter handler: Callback to call on each analysis pass
    public init(_ input: Node, bufferSize: UInt32 = 4_096, handler: @escaping Handler) {
        self.bufferSize = bufferSize
        self._input = input
        self.handler = handler
    }

    deinit {
        for tracker in trackers {
            akPitchTrackerDestroy(tracker)
        }
    }

    /// Enable the tap on input
    public func start() {
        guard !isStarted else { return }
        isStarted = true

        // a node can only have one tap at a time installed on it
        // make sure any previous tap is removed.
        // We're making the assumption that the previous tap (if any)
        // was installed on the same bus as our bus var.
        removeTap()

        // just double check this here
        guard input.avAudioUnitOrNode.engine != nil else {
            Log("The tapped node isn't attached to the engine")
            return
        }

        input.avAudioUnitOrNode.installTap(onBus: bus,
                                           bufferSize: bufferSize,
                                           format: nil,
                                           block: handleTapBlock(buffer:at:))
    }

    // AVAudioNodeTapBlock - time is unused in this case
    private func handleTapBlock(buffer: AVAudioPCMBuffer, at time: AVAudioTime) {
        guard let floatData = buffer.floatChannelData else { return }

        let channelCount = Int(buffer.format.channelCount)
        let length = UInt(buffer.frameLength)

        // Call on the main thread so the client doesn't have to worry
        // about thread safety.
        DispatchQueue.main.sync {
            // Create trackers as needed.
            while self.trackers.count < channelCount {
                self.trackers.append(akPitchTrackerCreate(UInt32(Settings.audioFormat.sampleRate), 4_096, 20))
            }

            while self.amp.count < channelCount {
                self.amp.append(0)
                self.pitch.append(0)
            }

            // n is the channel
            for n in 0 ..< channelCount {
                let data = floatData[n]

                akPitchTrackerAnalyze(trackers[n], data, UInt32(length))

                var a: Float = 0
                var f: Float = 0
                akPitchTrackerGetResults(trackers[n], &a, &f)
                self.amp[n] = a
                self.pitch[n] = f
            }
            self.handler(pitch, amp)
        }
    }

    /// Remove the tap on the input
    public func stop() {
        removeTap()
        isStarted = false
        for i in 0 ..< pitch.count {
            pitch[i] = 0.0
        }
    }

    private func removeTap() {
        guard input.avAudioUnitOrNode.engine != nil else {
            Log("The tapped node isn't attached to the engine")
            return
        }

        input.avAudioUnitOrNode.removeTap(onBus: bus)
    }

    /// remove the tap and nil out the input reference
    /// this is important in regard to retain cycles on your input node
    public func dispose() {
        if isStarted {
            stop()
        }
    }
}
