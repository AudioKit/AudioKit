// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import Accelerate
import AVFoundation
import CAudioKit

/// FFT Calculation for any node
open class FFTTap: Toggleable {
//    public let fftSize: Settings.BufferLength
//    internal var bufferSize: UInt32 { fftSize.samplesCount }

    public private(set) var bufferSize: UInt32

    /// Array of FFT data
    open var fftData: [Float]

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

    private var _input: Node
    public var input: Node {
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

    public typealias Handler = ([Float]) -> Void

    private var handler: Handler = { _ in }

    /// - parameter input: Node to analyze
    public init(_ input: Node, bufferSize: UInt32 = 4_096, handler: @escaping Handler) {
        self.bufferSize = bufferSize
        self._input = input
        self.handler = handler
        self.fftData = Array(repeating: 0.0, count: Int(bufferSize))
    }

    /// Enable the tap on input
    public func start() {
        guard !isStarted else { return }
        isStarted = true

        // a node can only have one tap at a time installed on it
        // make sure any previous tap is removed.
        // We're making the assumption that the previous tap (if any)
        // was installed on the same bus as our bus var.
        removeTap()

        // just double check this here
        guard input.avAudioUnitOrNode.engine != nil else {
            Log("The tapped node isn't attached to the engine")
            return
        }

        input.avAudioUnitOrNode.installTap(onBus: bus,
                                           bufferSize: bufferSize,
                                           format: nil,
                                           block: handleTapBlock(buffer:at:))
    }

    // AVAudioNodeTapBlock - time is unused in this case
    private func handleTapBlock(buffer: AVAudioPCMBuffer, at time: AVAudioTime) {
        guard buffer.floatChannelData != nil else { return }

        // Call on the main thread so the client doesn't have to worry
        // about thread safety.
        DispatchQueue.main.sync {
            fftData = FFTTap.performFFT(buffer: buffer)
            handler(fftData)
        }
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
                let temp = UnsafePointer<Float>(transferBuffer)
                temp.withMemoryRebound(to: DSPComplex.self,
                                       capacity: transferBuffer.count) {
                    vDSP_ctoz($0, 2, &output, 1, vDSP_Length(inputCount))
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
    public func stop() {
        removeTap()
        isStarted = false
        for i in 0 ..< fftData.count { fftData[i] = 0.0 }
    }

    private func removeTap() {
        guard input.avAudioUnitOrNode.engine != nil else {
            Log("The tapped node isn't attached to the engine")
            return
        }

        input.avAudioUnitOrNode.removeTap(onBus: bus)
    }

    /// remove the tap and nil out the input reference
    /// this is important in regard to retain cycles on your input node
    public func dispose() {
        if isStarted {
            stop()
        }
    }
}
