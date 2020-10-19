// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import Accelerate
import AVFoundation

/// Tap to do amplitude analysis on any node.
/// start() will add the tap, and stop() will remove it.
public class AmplitudeTap: BaseTap {
    private var amp: [Float] = Array(repeating: 0, count: 2)
    
    /// Detected amplitude (average of left and right channels
    public var amplitude: Float {
        return amp.reduce(0, +) / 2
    }

    /// Detected left channel amplitude
    public var leftAmplitude: Float {
        return amp[0]
    }

    /// Detected right channel amplitude
    public var rightAmplitude: Float {
        return amp[1]
    }

    private var handler: (Float) -> Void = { _ in }

    /// Initialize the amplitude
    ///
    /// - parameter input: Node to analyze
    /// - parameter bufferSize: Size of buffer to analyze
    /// - parameter handler: Code to call with new amplitudes
    public init(_ input: Node, bufferSize: UInt32 = 1_024, handler: @escaping (Float) -> Void = { _ in }) {
        self.handler = handler
        super.init(input, bufferSize: bufferSize)
    }

    // AVAudioNodeTapBlock - time is unused in this case
    internal override func doHandleTapBlock(buffer: AVAudioPCMBuffer, at time: AVAudioTime) {
        guard let floatData = buffer.floatChannelData else { return }

        let channelCount = Int(buffer.format.channelCount)
        let length = UInt(buffer.frameLength)

        // n is the channel
        for n in 0 ..< channelCount {
            let data = floatData[n]

            var rms: Float = 0
            vDSP_rmsqv(data, 1, &rms, UInt(length))
            self.amp[n] = rms
        }

        self.handler(self.amplitude)
    }

    /// Remove the tap on the input
    public override func stop() {
        super.stop()
        amp[0] = 0
        amp[1] = 0
    }
}
