//
//  AKNodeFFTPlot.swift
//  AudioKit For iOS
//
//  Created by Aurelius Prochazka on 12/12/15.
//  Copyright © 2015 AudioKit. All rights reserved.
//

import Foundation

@objc public class AKNodeFFTPlot: NSObject, EZAudioFFTDelegate {
    
    let bufferSize: UInt32 = 512
    public var plot: EZAudioPlot?
    public var fft: EZAudioFFT?
    public var containerView: AKView?
    
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
    
    @objc public func fft(fft: EZAudioFFT!, updatedWithFFTData fftData: UnsafeMutablePointer<Float>, bufferSize: vDSP_Length) {
        dispatch_async(dispatch_get_main_queue()) { () -> Void in
            self.plot!.updateBuffer(fftData, withBufferSize: self.bufferSize)
        }
    }
}
