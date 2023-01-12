// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import Accelerate
import Audio
import AVFoundation

/// Determines the value to use for log2n input to fft
func determineLog2n(frameCount: UInt32, binCount: FFTValidBinCount?) -> UInt {
    if let setup = binCount {
        if frameCount >= setup.binCount { // guard against more bins than buffer size
            return UInt(setup.log2n + 1) // +1 because we divide bufferSizePOT by two
        }
    }
    // default to frameCount (for bad input or no bin count argument)
    return UInt(round(log2(Double(frameCount))))
}

public func performFFT(data: [Float],
                       isNormalized: Bool,
                       zeroPaddingFactor: UInt32 = 0,
                       binCount: FFTValidBinCount? = nil) -> [Float]
{
    var data = data
    let frameCount = UInt32(data.count) * (zeroPaddingFactor + 1)
    let log2n = determineLog2n(frameCount: frameCount, binCount: binCount)
    let bufferSizePOT = Int(1 << log2n) // 1 << n = 2^n
    let binCount = bufferSizePOT / 2

    let fftSetup = vDSP_create_fftsetup(log2n, Int32(kFFTRadix2))

    var output = DSPSplitComplex(repeating: 0, count: binCount)
    defer {
        output.deallocate()
    }

    let windowSize = data.count
    var transferBuffer = [Float](repeating: 0, count: bufferSizePOT)
    var window = [Float](repeating: 0, count: windowSize)

    // Hann windowing to reduce the frequency leakage
    vDSP_hann_window(&window, vDSP_Length(windowSize), Int32(vDSP_HANN_NORM))
    vDSP_vmul(&data, 1, window,
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

    var binCount: UInt {
        UInt(rawValue)
    }

    var log2n: UInt {
        UInt(log2(rawValue))
    }
}
