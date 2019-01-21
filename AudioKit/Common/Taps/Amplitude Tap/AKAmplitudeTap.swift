//
//  AKAmplitudeTap.swift
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright © 2018 AudioKit. All rights reserved.
//

import Accelerate

/// Tap to do return amplitude analysis on any node
public class AKAmplitudeTap: AKToggleable {
    private let bufferSize: UInt32 = 2_048
    private var amp: [Float] = Array(repeating: 0, count: 2)

    /// Tells whether the node is processing (ie. started, playing, or active)
    public private(set) var isStarted: Bool = false

    /// The bus to install the tap onto
    public var bus: Int = 0

    public var input: AKNode? {
        willSet {
            if isStarted {
                stop()
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

    /// - parameter input: Node to analyze
    @objc public init(_ input: AKNode?) {
        self.input = input
    }

    /// Enable the tap on input
    public func start() {
        isStarted = true
        input?.avAudioUnitOrNode.installTap(onBus: bus,
                                            bufferSize: bufferSize,
                                            format: AudioKit.format,
                                            block: handleTapBlock(buffer:at:))
    }

    // AVAudioNodeTapBlock - time is currently unused
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
    }

    /// Remove the tap on input
    public func stop() {
        isStarted = false
        removeTap()
        amp[0] = 0
        amp[1] = 0
    }

    private func removeTap() {
        input?.avAudioUnitOrNode.removeTap(onBus: 0)
    }

    public func dispose() {
        if isPlaying {
            removeTap()
        }
        input = nil
    }
}
