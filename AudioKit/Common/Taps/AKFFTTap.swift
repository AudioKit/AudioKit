//
//  AKFFTTap.swift
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright © 2016 AudioKit. All rights reserved.
//

import Foundation

/// FFT Calculation for any node
@objc public class AKFFTTap: NSObject, EZAudioFFTDelegate {
    
    internal let bufferSize: UInt32 = 512
    internal var fft: EZAudioFFT?
    
    /// Array of FFT data
    public var fftData = [Double](zeroes: 512)
    
    /// Initialze the FFT calculation on a given node
    ///
    /// - parameter input: Node on whose output the FFT will be computed
    ///
    public init(_ input: AKNode) {
        super.init()
        fft = EZAudioFFT(maximumBufferSize: vDSP_Length(bufferSize), sampleRate: Float(AKSettings.sampleRate), delegate: self)
        input.avAudioNode.installTap(onBus: 0, bufferSize: bufferSize, format: AudioKit.format) { [weak self] (buffer, time) -> Void in
            guard let strongSelf = self else { return }
            buffer.frameLength = strongSelf.bufferSize
            let offset = Int(buffer.frameCapacity - buffer.frameLength)
            let tail = buffer.floatChannelData?[0]
            var t: Float? = tail?[offset]
            strongSelf.fft!.computeFFT(withBuffer: &t!, withBufferSize: strongSelf.bufferSize)
            tail?[offset] = t!
        }
    }
    
    /// Callback function for FFT computation
    @objc public func fft(_ fft: EZAudioFFT!, updatedWithFFTData fftData: UnsafeMutablePointer<Float>, bufferSize: vDSP_Length) {
        DispatchQueue.main.async { () -> Void in
            for i in 0...511 {
                self.fftData[i] = Double(fftData[i])
            }
        }
    }
}
