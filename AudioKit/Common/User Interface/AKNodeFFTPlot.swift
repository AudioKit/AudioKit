//
//  AKNodeFFTPlot.swift
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright © 2016 AudioKit. All rights reserved.
//

import Foundation

/// Plot the FFT output from any node in an signal processing graph
@IBDesignable
public class AKNodeFFTPlot: EZAudioPlot, EZAudioFFTDelegate {
    
    internal func setupNode(input: AKNode?) {
        if fft == nil {
            fft = EZAudioFFT.fftWithMaximumBufferSize(vDSP_Length(bufferSize), sampleRate: Float(AKSettings.sampleRate), delegate: self)
        }
        input?.avAudioNode.installTapOnBus(0, bufferSize: bufferSize, format: AudioKit.format) { [weak self] (buffer, time) -> Void in
            if let strongSelf = self {
                buffer.frameLength = strongSelf.bufferSize
                let offset = Int(buffer.frameCapacity - buffer.frameLength)
                let tail = buffer.floatChannelData[0]
                strongSelf.fft!.computeFFTWithBuffer(&tail[offset], withBufferSize: strongSelf.bufferSize)
            }
        }
    }
    
    internal var bufferSize: UInt32 = 1024
    
    /// EZAudioFFT container
    private var fft: EZAudioFFT?
    
    /// The node whose output to graph
    public var node: AKNode? {
        willSet {
            node?.avAudioNode.removeTapOnBus(0)
        }
        didSet {
            setupNode(node)
        }
    }
    
    deinit {
        node?.avAudioNode.removeTapOnBus(0)
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
    /// - parameter input: AKNode from which to get the plot data
    /// - parameter width: Width of the view
    /// - parameter height: Height of the view
    ///
    public init(_ input: AKNode, frame: CGRect, bufferSize:Int = 1024) {
        super.init(frame: frame)
        self.plotType = .Buffer
        self.backgroundColor = AKColor.whiteColor()
        self.shouldCenterYAxis = true
        self.bufferSize = UInt32(bufferSize)
        setupNode(input)
        
    }
    
    /// Callback function for FFT data:
    ///
    /// - parameter fft: EZAudioFFT Reference
    /// - parameter updatedWithFFTData: A pointer to a c-style array of floats
    /// - parameter bufferSize: Number of elements in the FFT Data array
    ///
    public func fft(fft: EZAudioFFT!, updatedWithFFTData fftData: UnsafeMutablePointer<Float>, bufferSize: vDSP_Length) {
        dispatch_async(dispatch_get_main_queue()) { () -> Void in
            self.updateBuffer(fftData, withBufferSize: self.bufferSize)
        }
    }
}
