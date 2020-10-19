// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import Accelerate
import AVFoundation
import CAudioKit

/// FFT Calculation for any node
open class FFTTap: BaseTap {

    /// Array of FFT data
    open var fftData: [Float]
    /// Type of callback
    public typealias Handler = ([Float]) -> Void

    private var handler: Handler = { _ in }

    /// Initialize the FFT Tap
    /// 
    /// - parameter input: Node to analyze
    /// - parameter bufferSize: Size of buffer to analyze
    /// - parameter handler: Callback to call when FFT is calculated
    public init(_ input: Node, bufferSize: UInt32 = 4_096, handler: @escaping Handler) {
        self.handler = handler
        self.fftData = Array(repeating: 0.0, count: Int(bufferSize))
        super.init(input, bufferSize: bufferSize)
    }

    // AVAudioNodeTapBlock - time is unused in this case
    internal override func doHandleTapBlock(buffer: AVAudioPCMBuffer, at time: AVAudioTime) {
        guard buffer.floatChannelData != nil else { return }

        fftData = FFTTap.performFFT(buffer: buffer)
        handler(fftData)
    }

    static func performFFT(buffer: AVAudioPCMBuffer) -> [Float] {
        let frameCount = buffer.frameLength
        let log2n = UInt(round(log2(Double(frameCount))))
        let bufferSizePOT = Int(1 << log2n)
        let inputCount = bufferSizePOT / 2
        let fftSetup = vDSP_create_fftsetup(log2n, Int32(kFFTRadix2))

        var realp = [Float](repeating: 0, count: inputCount)
        var imagp = [Float](repeating: 0, count: inputCount)

        return realp.withUnsafeMutableBufferPointer { realPointer in
            imagp.withUnsafeMutableBufferPointer { imagPointer in
                var output = DSPSplitComplex(realp: realPointer.baseAddress!,
                                             imagp: imagPointer.baseAddress!)

                let windowSize = bufferSizePOT
                var transferBuffer = [Float](repeating: 0, count: windowSize)
                var window = [Float](repeating: 0, count: windowSize)

                // Hann windowing to reduce the frequency leakage
                vDSP_hann_window(&window, vDSP_Length(windowSize), Int32(vDSP_HANN_NORM))
                vDSP_vmul((buffer.floatChannelData?.pointee)!, 1, window,
                          1, &transferBuffer, 1, vDSP_Length(windowSize))

                // Transforming the [Float] buffer into a UnsafePointer<Float> object for the vDSP_ctoz method
                // And then pack the input into the complex buffer (output)
                transferBuffer.withUnsafeBufferPointer { pointer in
                    pointer.baseAddress!.withMemoryRebound(to: DSPComplex.self,
                                                         capacity: transferBuffer.count) {
                        vDSP_ctoz($0, 2, &output, 1, vDSP_Length(inputCount))
                    }
                }

                // Perform the FFT
                vDSP_fft_zrip(fftSetup!, &output, 1, log2n, FFTDirection(FFT_FORWARD))

                var magnitudes = [Float](repeating: 0.0, count: inputCount)
                vDSP_zvmags(&output, 1, &magnitudes, 1, vDSP_Length(inputCount))

                // Normalising
                var normalizedMagnitudes = [Float](repeating: 0.0, count: inputCount)
                vDSP_vsmul(&magnitudes,
                           1,
                           [1.0 / (magnitudes.max() ?? 1.0)],
                           &normalizedMagnitudes,
                           1,
                           vDSP_Length(inputCount))

                vDSP_destroy_fftsetup(fftSetup)
                return normalizedMagnitudes
            }
        }
    }

    /// Remove the tap on the input
    override public func stop() {
        super.stop()
        for i in 0 ..< fftData.count { fftData[i] = 0.0 }
    }
}

