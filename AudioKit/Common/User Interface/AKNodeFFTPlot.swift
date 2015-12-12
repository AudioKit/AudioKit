//
//  AKNodeFFTPlot.swift
//  AudioKit For iOS
//
//  Created by Aurelius Prochazka on 12/12/15.
//  Copyright © 2015 AudioKit. All rights reserved.
//

import Foundation

@objc public class AKNodeFFTPlot: EZAudioPlot, EZAudioFFTDelegate {
    
    public var fft: EZAudioFFTRolling?
    public var node: AKNode? {
        didSet {
            node!.output!.installTapOnBus(0, bufferSize: bufferSize, format: AKManager.format) { [weak self] (buffer, time) -> Void in
                if let strongSelf = self {
                    buffer.frameLength = strongSelf.bufferSize;
                    let offset: Int = Int(buffer.frameCapacity - buffer.frameLength);
                    let tail = buffer.floatChannelData[0];
                    strongSelf.fft!.computeFFTWithBuffer(&tail[offset], withBufferSize: strongSelf.bufferSize)
                }
            }
        }
    }
    
    
    let bufferSize: UInt32 = 512
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        fft = EZAudioFFTRolling.fftWithWindowSize(4096, sampleRate: 44100, delegate: self)
    }
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        fft = EZAudioFFTRolling.fftWithWindowSize(4096, sampleRate: 44100, delegate: self)
    }
    
    #if os(OSX)
    public typealias AKView = NSView
    typealias AKColor = NSColor
    #else
    public typealias AKView = UIView
    typealias AKColor = UIColor
    #endif
    
    public static func createView(width: CGFloat = 1000.0, height: CGFloat = 500.0) -> AKView {
        
        let frame = CGRect(x: 0.0, y: 0.0, width: width, height: height)
        let plot = AKNodeOutputPlot(frame: frame)
        
        plot.plotType = .Buffer
        plot.backgroundColor = AKColor.whiteColor()
        plot.shouldCenterYAxis = true
        
        let containerView = AKView(frame: frame)
        containerView.addSubview(plot)
        return containerView
    }
    
    @objc public func fft(fft: EZAudioFFT!, updatedWithFFTData fftData: UnsafeMutablePointer<Float>, bufferSize: vDSP_Length) {
        dispatch_async(dispatch_get_main_queue()) { () -> Void in
            self.updateBuffer(fftData, withBufferSize: self.bufferSize)
        }
    }
}
