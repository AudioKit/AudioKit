//
//  AKNodeFFTPlot.swift
//  AudioKitUI
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright © 2017 Aurelius Prochazka. All rights reserved.
//
#if !JAZZY_HACK
    import AudioKit
#endif

/// Plot the FFT output from any node in an signal processing graph
@IBDesignable
open class AKNodeFFTPlot: EZAudioPlot, EZAudioFFTDelegate {

    internal func setupNode(_ input: AKNode?) {
        if fft == nil {
            fft = EZAudioFFT(maximumBufferSize: vDSP_Length(bufferSize),
                             sampleRate: Float(AKSettings.sampleRate),
                             delegate: self)
        }
        input?.avAudioNode.installTap(onBus: 0,
                                      bufferSize: bufferSize,
                                      format: nil) { [weak self] (buffer, _) in
                                        if let strongSelf = self {
                                            buffer.frameLength = strongSelf.bufferSize
                                            let offset = Int(buffer.frameCapacity - buffer.frameLength)
                                            if let tail = buffer.floatChannelData?[0], let existingFFT = strongSelf.fft {
                                                existingFFT.computeFFT(withBuffer: &tail[offset],
                                                                       withBufferSize: strongSelf.bufferSize)
                                            }
                                        }
        }

    }

    internal var bufferSize: UInt32 = 1_024

    /// EZAudioFFT container
    fileprivate var fft: EZAudioFFT?

    /// The node whose output to graph
    open var node: AKNode? {
        willSet {
            node?.avAudioNode.removeTap(onBus: 0)
        }
        didSet {
            setupNode(node)
        }
    }

    deinit {
        node?.avAudioNode.removeTap(onBus: 0)
    }

    /// Required coder-based initialization (for use with Interface Builder)
    ///
    /// - parameter coder: NSCoder
    ///
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupNode(nil)
    }

    /// Initialize the plot with the output from a given node and optional plot size
    ///
    /// - Parameters:
    ///   - input: AKNode from which to get the plot data
    ///   - width: Width of the view
    ///   - height: Height of the view
    ///
    @objc public init(_ input: AKNode?, frame: CGRect, bufferSize: Int = 1_024) {
        super.init(frame: frame)
        self.plotType = .buffer
        self.backgroundColor = AKColor.white
        self.shouldCenterYAxis = true
        self.bufferSize = UInt32(bufferSize)
        setupNode(input)

    }

    /// Callback function for FFT data:
    ///
    /// - Parameters:
    ///   - fft: EZAudioFFT Reference
    ///   - updatedWithFFTData: A pointer to a c-style array of floats
    ///   - bufferSize: Number of elements in the FFT Data array
    ///
    open func fft(_ fft: EZAudioFFT!,
                  updatedWithFFTData fftData: UnsafeMutablePointer<Float>,
                  bufferSize: vDSP_Length) {
        DispatchQueue.main.async { () -> Void in
            self.updateBuffer(fftData, withBufferSize: self.bufferSize)
        }
    }
}
