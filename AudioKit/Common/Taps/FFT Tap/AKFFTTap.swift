//
//  AKFFTTap.swift
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright © 2018 AudioKit. All rights reserved.
//

/// FFT Calculation for any node
@objc open class AKFFTTap: NSObject, EZAudioFFTDelegate {

    internal let bufferSize: UInt32 = 1_024
    internal var fft: EZAudioFFT?

    /// Array of FFT data
    open var fftData = [Double](zeros: 512)

    /// Initialze the FFT calculation on a given node
    ///
    /// - parameter input: Node on whose output the FFT will be computed
    ///
    @objc public init(_ input: AKNode) {
        super.init()
        fft = EZAudioFFT(maximumBufferSize: vDSP_Length(bufferSize),
                         sampleRate: Float(AKSettings.sampleRate),
                         delegate: self)
        input.avAudioNode.installTap(onBus: 0,
                                     bufferSize: bufferSize,
                                     format: AudioKit.format) { [weak self] (buffer, _) -> Void in
                                        guard let strongSelf = self else {
                                            AKLog("Unable to create strong reference to self")
                                            return
                                        }
                                        buffer.frameLength = strongSelf.bufferSize
                                        let offset = Int(buffer.frameCapacity - buffer.frameLength)
                                        if let tail = buffer.floatChannelData?[0], let existingFFT = strongSelf.fft {
                                            existingFFT.computeFFT(withBuffer: &tail[offset],
                                                                   withBufferSize: strongSelf.bufferSize)
                                        }
        }
    }

    /// Callback function for FFT computation
    @objc open func fft(_ fft: EZAudioFFT!,
                        updatedWithFFTData fftData: UnsafeMutablePointer<Float>,
                        bufferSize: vDSP_Length) {
        DispatchQueue.main.async { () -> Void in
            for i in 0..<512 {
                self.fftData[i] = Double(fftData[i])
            }
        }
    }
}
