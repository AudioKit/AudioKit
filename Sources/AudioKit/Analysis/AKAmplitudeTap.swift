// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import Accelerate
import AVFoundation

/// Tap to do amplitude analysis on any node.
/// start() will add the tap, and stop() will remove it.
public class AKAmplitudeTap: AKToggleable {
    private var amp: [Float] = Array(repeating: 0, count: 2)
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

    private var _input: AKNode?
    public var input: AKNode? {
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

    public var amplitude: Float {
        return amp.reduce(0, +) / 2
    }

    public var leftAmplitude: Float {
        return amp[0]
    }

    public var rightAmplitude: Float {
        return amp[1]
    }

    private var handler: (Float) -> Void = { _ in }

    /// - parameter input: Node to analyze
    public init(_ input: AKNode, bufferSize: UInt32 = 1_024, handler: @escaping (Float) -> Void = { _ in }) {
        self.bufferSize = bufferSize
        self.input = input
        self.handler = handler
    }

    /// Enable the tap on input
    public func start() {
        guard let input = input, !isStarted else { return }
        isStarted = true

        // a node can only have one tap at a time installed on it
        // make sure any previous tap is removed.
        // We're making the assumption that the previous tap (if any)
        // was installed on the same bus as our bus var.
        removeTap()

        // just double check this here
        guard input.avAudioUnitOrNode.engine != nil else {
            AKLog("The tapped node isn't attached to the engine")
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

        // n is the channel
        for n in 0 ..< channelCount {
            let data = floatData[n]

            var rms: Float = 0
            vDSP_rmsqv(data, 1, &rms, UInt(length))
            amp[n] = rms
        }
        handler(amplitude)
    }

    /// Remove the tap on the input
    public func stop() {
        removeTap()
        isStarted = false
        amp[0] = 0
        amp[1] = 0
    }

    private func removeTap() {
        guard input?.avAudioUnitOrNode.engine != nil else {
            AKLog("The tapped node isn't attached to the engine")
            return
        }

        input?.avAudioUnitOrNode.removeTap(onBus: bus)
    }

    /// remove the tap and nil out the input reference
    /// this is important in regard to retain cycles on your input node
    public func dispose() {
        if isStarted {
            stop()
        }
        input = nil
    }
}
