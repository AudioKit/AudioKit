//
//  AKNodeFFTPlot.swift
//  AudioKit
//
//  Created by Aurelius Prochazka on 12/12/15.
//  Copyright © 2015 AudioKit. All rights reserved.
//

import Foundation

/// Plot the FFT output from any node in an signal processing graph
@objc public class AKNodeFFTPlot: NSObject, EZAudioFFTDelegate {
    
    internal let bufferSize: UInt32 = 512
    
    /// EZAudioPlot containing actual plot
    public var plot: EZAudioPlot?
    
    /// EZAudioFFT container
    internal var fft: EZAudioFFT?
    
    /// View with the plot
    public var containerView: AKView?
    
    /// Initialize the plot with the output from a given node and optional plot size
    ///
    /// - parameter input: AKNode from which to get the plot data
    /// - parameter width: Width of the view
    /// - parameter height: Height of the view
    ///
    public init(_ input: AKNode, width: CGFloat = 1000.0, height: CGFloat = 500.0) {
        super.init()
        fft = EZAudioFFT.fftWithMaximumBufferSize(vDSP_Length(bufferSize), sampleRate: 44100.0, delegate: self)
        let frame = CGRect(x: 0.0, y: 0.0, width: width, height: height)
        plot = EZAudioPlot(frame: frame)
        plot!.plotType = .Buffer
        plot!.backgroundColor = AKColor.whiteColor()
        plot!.shouldCenterYAxis = true
        
        containerView = AKView(frame: frame)
        containerView!.addSubview(plot!)
        
        input.avAudioNode.installTapOnBus(0, bufferSize: bufferSize, format: AKManager.format) { [weak self] (buffer, time) -> Void in
            if let strongSelf = self {
                buffer.frameLength = strongSelf.bufferSize;
                let offset: Int = Int(buffer.frameCapacity - buffer.frameLength);
                let tail = buffer.floatChannelData[0];
                strongSelf.fft!.computeFFTWithBuffer(&tail[offset], withBufferSize: strongSelf.bufferSize)
            }
        }
        
    }
    
    /// Callback function for FFT data:
    ///
    /// - parameter fft: EZAudioFFT Reference
    /// - parameter updatedWithFFTData: A pointer to a c-style array of floats
    /// - parameter bufferSize: Number of elements in the FFT Data array
    ///
    @objc public func fft(fft: EZAudioFFT!, updatedWithFFTData fftData: UnsafeMutablePointer<Float>, bufferSize: vDSP_Length) {
        dispatch_async(dispatch_get_main_queue()) { () -> Void in
            self.plot!.updateBuffer(fftData, withBufferSize: self.bufferSize)
        }
    }
}
