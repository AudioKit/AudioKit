// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import Accelerate
import AVFoundation

/// Tap to do amplitude analysis on any node.
/// start() will add the tap, and stop() will remove it.
public class AmplitudeTap: BaseTap {
    private var amp: [Float] = Array(repeating: 0, count: 2)

    /// Detected amplitude (average of left and right channels)
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

    /// Determines if the returned amplitude value is the left, right, or average of the two
    public var stereoMode: StereoMode = .center

    /// Determines if the returned amplitude value is the rms or peak value
    public var analysisMode: AnalysisMode = .rms

    private var handler: (Float) -> Void = { _ in }

    /// Initialize the amplitude
    ///
    /// - Parameters:
    ///   - input: Node to analyze
    ///   - bufferSize: Size of buffer to analyze
    ///   - stereoMode: left, right, or average returned amplitudes
    ///   - analysisMode: rms or peak returned amplitudes
    ///   - handler: Code to call with new amplitudes
    public init(_ input: Node,
                bufferSize: UInt32 = 1_024,
                stereoMode: StereoMode = .center,
                analysisMode: AnalysisMode = .rms,
                handler: @escaping (Float) -> Void = { _ in }) {
        self.handler = handler
        self.stereoMode = stereoMode
        self.analysisMode = analysisMode
        super.init(input, bufferSize: bufferSize)
    }

    /// Overide this method to handle Tap in derived class
    /// - Parameters:
    ///   - buffer: Buffer to analyze
    ///   - time: Unused in this case
    override public func doHandleTapBlock(buffer: AVAudioPCMBuffer, at time: AVAudioTime) {
        guard let floatData = buffer.floatChannelData else { return }

        let channelCount = Int(buffer.format.channelCount)
        let length = UInt(buffer.frameLength)

        // n is the channel
        for n in 0 ..< channelCount {
            let data = floatData[n]

            if analysisMode == .rms {
                var rms: Float = 0
                vDSP_rmsqv(data, 1, &rms, UInt(length))
                amp[n] = rms
            } else {
                var peak: Float = 0
                var index: vDSP_Length = 0
                vDSP_maxvi(data, 1, &peak, &index, UInt(length))
                amp[n] = peak
            }
        }

        switch stereoMode {
        case .left:
            handler(leftAmplitude)
        case .right:
            handler(rightAmplitude)
        case .center:
            handler(amplitude)
        }
    }

    /// Remove the tap on the input
    override public func stop() {
        super.stop()
        amp[0] = 0
        amp[1] = 0
    }
}

/// Tyep of analysis
public enum AnalysisMode {
    /// Root Mean Squared
    case rms
    /// Peak
    case peak
}

/// How to deal with stereo signals
public enum StereoMode {
    /// Use left channel
    case left
    /// Use right channel
    case right
    /// Use combined left and right channels
    case center
}
