// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import Accelerate
import AVFoundation

/// Tap to do amplitude analysis on any node.
/// start() will add the tap, and stop() will remove it.
public class AmplitudeTap: BaseTap {
    private let channelCount: Int
    private var amp: [Float]

    /// Detected amplitude (average of all channels)
    public var amplitude: Float {
        return amp.reduce(0, +) / Float(channelCount)
    }

    /// Detected left channel amplitude
    public var leftAmplitude: Float {
        return amp[0]
    }

    /// Detected right channel amplitude (returns left channel for mono sources)
    public var rightAmplitude: Float {
        return amp.count > 1 ? amp[1] : amp[0]
    }

    /// Determines if the returned amplitude value is the left, right, or average of the two
    public var stereoMode: StereoMode = .center

    /// Determines if the returned amplitude value is the rms or peak value
    public var analysisMode: AnalysisMode = .rms

    private var handler: (Float) -> Void = { _ in }
    private var stereoHandler: (Float, Float) -> Void = { _, _ in }

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
                callbackQueue: DispatchQueue = .main,
                handler: @escaping (Float) -> Void = { _ in }) {
        self.handler = handler
        self.stereoMode = stereoMode
        self.analysisMode = analysisMode
        self.channelCount = Int(input.outputFormat.channelCount)
        self.amp = Array(repeating: 0, count: channelCount)
        super.init(input, bufferSize: bufferSize, callbackQueue: callbackQueue)
    }

    /// Initialize the amplitude with stereo callback support.
    ///
    /// - Parameters:
    ///   - input: Node to analyze
    ///   - bufferSize: Size of buffer to analyze
    ///   - stereoMode: left, right, average, or stereo returned amplitudes
    ///   - analysisMode: rms or peak returned amplitudes
    ///   - stereoHandler: Code to call with new amplitudes
    public init(_ input: Node,
                bufferSize: UInt32 = 1_024,
                stereoMode: StereoMode = .center,
                analysisMode: AnalysisMode = .rms,
                callbackQueue: DispatchQueue = .main,
                stereoHandler: @escaping (_ left: Float, _ right: Float) -> Void) {
        self.stereoHandler = stereoHandler
        self.stereoMode = stereoMode
        self.analysisMode = analysisMode
        self.channelCount = Int(input.outputFormat.channelCount)
        self.amp = Array(repeating: 0, count: channelCount)
        super.init(input, bufferSize: bufferSize, callbackQueue: callbackQueue)
    }

    /// Override this method to handle Tap in derived class
    /// - Parameters:
    ///   - buffer: Buffer to analyze
    ///   - time: Unused in this case
    override public func doHandleTapBlock(buffer: AVAudioPCMBuffer, at time: AVAudioTime) {
        guard let floatData = buffer.floatChannelData else { return }

        let bufferChannelCount = Int(buffer.format.channelCount)
        let length = UInt(buffer.frameLength)

        // Clamp to the amp array size to avoid out-of-bounds if the buffer
        // has more channels than the node reported at init time.
        for n in 0 ..< min(bufferChannelCount, amp.count) {
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

        let callbackAmplitudes: (Float, Float)
        switch stereoMode {
        case .left:
            callbackAmplitudes = (leftAmplitude, leftAmplitude)
        case .right:
            callbackAmplitudes = (rightAmplitude, rightAmplitude)
        case .center:
            callbackAmplitudes = (amplitude, amplitude)
        case .stereo:
            callbackAmplitudes = (leftAmplitude, rightAmplitude)
        }

        handler(callbackAmplitudes.0)
        stereoHandler(callbackAmplitudes.0, callbackAmplitudes.1)
    }

    /// Remove the tap on the input
    override public func stop() {
        super.stop()
        for channelIndex in 0 ..< channelCount {
            amp[channelIndex] = 0
        }
    }
}

/// Type of analysis
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
    /// Use independent left and right channels
    case stereo
}
