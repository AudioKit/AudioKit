// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import Accelerate
import AVFoundation

/// FFT Calculation for any node
open class FFTTap: BaseTap {
    /// Array of FFT data
    open var fftData: [Float]
    /// Type of callback
    public typealias Handler = ([Float]) -> Void
    /// Determines if the returned FFT data is normalized
    public var isNormalized: Bool = true
    /// Determines the ratio of zeros padding the input of the FFT (default 0 = no padding)
    public var zeroPaddingFactor: UInt32 = 0
    /// Sets the number of fft bins return
    private var fftSetupForBinCount: FFTSetupForBinCount?

    private var handler: Handler = { _ in }

    /// Initialize the FFT Tap
    ///
    /// - Parameters:
    ///   - input: Node to analyze
    ///   - bufferSize: Size of buffer to analyze
    ///   - fftValidBinNumber: Valid fft bin count to return
    ///   - handler: Callback to call when FFT is calculated
    public init(_ input: Node,
                bufferSize: UInt32 = 4096,
                fftValidBinCount: FFTValidBinCount? = nil,
                callbackQueue: DispatchQueue = .main,
                handler: @escaping Handler) {
        self.handler = handler
        if let fftBinCount = fftValidBinCount {
            fftSetupForBinCount = FFTSetupForBinCount(binCount: fftBinCount)
        }

        if let binCount = fftSetupForBinCount?.binCount {
            fftData = Array(repeating: 0.0, count: binCount)
        } else {
            fftData = Array(repeating: 0.0, count: Int(bufferSize))
        }

        super.init(input, bufferSize: bufferSize, callbackQueue: callbackQueue)
    }

    /// Override this method to handle Tap in derived class
    /// - Parameters:
    ///   - buffer: Buffer to analyze
    ///   - time: Unused in this case
    override open func doHandleTapBlock(buffer: AVAudioPCMBuffer, at time: AVAudioTime) {
        guard buffer.floatChannelData != nil else { return }

        fftData = FFTTap.performFFT(buffer: buffer,
                                    isNormalized: isNormalized,
                                    zeroPaddingFactor: zeroPaddingFactor,
                                    fftSetupForBinCount: fftSetupForBinCount)
        handler(fftData)
    }

    static func performFFT(buffer: AVAudioPCMBuffer,
                           isNormalized: Bool = true,
                           zeroPaddingFactor: UInt32 = 0,
                           fftSetupForBinCount: FFTSetupForBinCount? = nil) -> [Float] {
        let frameCount = buffer.frameLength + buffer.frameLength * zeroPaddingFactor
        let log2n = determineLog2n(frameCount: frameCount, fftSetupForBinCount: fftSetupForBinCount)
        let bufferSizePOT = Int(1 << log2n) // 1 << n = 2^n
        let binCount = bufferSizePOT / 2

        let fftSetup = vDSP_create_fftsetup(log2n, Int32(kFFTRadix2))

        var output = DSPSplitComplex(repeating: 0, count: binCount)
        defer {
            output.deallocate()
        }

        let windowSize = Int(buffer.frameLength)
        var transferBuffer = [Float](repeating: 0, count: bufferSizePOT)
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
                vDSP_ctoz($0, 2, &output, 1, vDSP_Length(binCount))
            }
        }

        // Perform the FFT
        vDSP_fft_zrip(fftSetup!, &output, 1, log2n, FFTDirection(FFT_FORWARD))

        // Parseval's theorem - Scale with respect to the number of bins
        var scaledOutput = DSPSplitComplex(repeating: 0, count: binCount)
        var scaleMultiplier = DSPSplitComplex(repeatingReal: 1.0 / Float(binCount), repeatingImag: 0, count: 1)
        defer {
            scaledOutput.deallocate()
            scaleMultiplier.deallocate()
        }
        vDSP_zvzsml(&output,
                    1,
                    &scaleMultiplier,
                    &scaledOutput,
                    1,
                    vDSP_Length(binCount))

        var magnitudes = [Float](repeating: 0.0, count: binCount)
        vDSP_zvmags(&scaledOutput, 1, &magnitudes, 1, vDSP_Length(binCount))
        vDSP_destroy_fftsetup(fftSetup)

        if !isNormalized {
            return magnitudes
        }

        // normalize according to the momentary maximum value of the fft output bins
        var normalizationMultiplier: [Float] = [1.0 / (magnitudes.max() ?? 1.0)]
        var normalizedMagnitudes = [Float](repeating: 0.0, count: binCount)
        vDSP_vsmul(&magnitudes,
                   1,
                   &normalizationMultiplier,
                   &normalizedMagnitudes,
                   1,
                   vDSP_Length(binCount))
        return normalizedMagnitudes
    }

    /// Remove the tap on the input
    override public func stop() {
        super.stop()
        for i in 0 ..< fftData.count { fftData[i] = 0.0 }
    }

    /// Determines the value to use for log2n input to fft
    static func determineLog2n(frameCount: UInt32, fftSetupForBinCount: FFTSetupForBinCount?) -> UInt {
        if let setup = fftSetupForBinCount {
            if frameCount >= setup.binCount { // guard against more bins than buffer size
                return UInt(setup.log2n + 1) // +1 because we divide bufferSizePOT by two
            }
        }
        // default to frameCount (for bad input or no bin count argument)
        return UInt(round(log2(Double(frameCount))))
    }

    /// Relevant values for setting the fft bin count
    struct FFTSetupForBinCount {
        /// Initialize FFTSetupForBinCount with a valid number of fft bins
        ///
        /// - Parameters:
        ///   - binCount: enum representing a valid 2^n result where n is an integer
        init(binCount: FFTValidBinCount) {
            log2n = UInt(log2(binCount.rawValue))
            self.binCount = Int(binCount.rawValue)
        }

        /// used to set log2n in fft
        let log2n: UInt

        /// number of returned fft bins
        var binCount: Int
    }
}

/// Valid results of 2^n where n is an integer
public enum FFTValidBinCount: Double {
    case two = 2,
         four = 4,
         eight = 8,
         sixteen = 16,
         thirtyTwo = 32,
         sixtyFour = 64,
         oneHundredTwentyEight = 128,
         twoHundredFiftySix = 256,
         fiveHundredAndTwelve = 512,
         oneThousandAndTwentyFour = 1024,
         twoThousandAndFortyEight = 2048,
         fourThousandAndNintySix = 4096,
         eightThousandOneHundredAndNintyTwo = 8192
}
