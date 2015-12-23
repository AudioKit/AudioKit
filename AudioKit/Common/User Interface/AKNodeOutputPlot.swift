//
//  AKNodeOutputPlot.swift
//  AudioKit For iOS
//
//  Created by Aurelius Prochazka on 12/12/15.
//  Copyright © 2015 AudioKit. All rights reserved.
//

import Foundation

@objc public class AKNodeOutputPlot: EZAudioPlot {
    public var node: AKNode? {
        didSet {
            node!.avAudioNode.installTapOnBus(0, bufferSize: bufferSize, format: AKManager.format) { [weak self] (buffer, time) -> Void in
                if let strongSelf = self {
                    buffer.frameLength = strongSelf.bufferSize;
                    let offset: Int = Int(buffer.frameCapacity - buffer.frameLength);
                    let tail = buffer.floatChannelData[0];
                    strongSelf.updateBuffer(&tail[offset],
                        withBufferSize: strongSelf.bufferSize);
                }
            }
        }
    }

    
    let bufferSize: UInt32 = 512
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
    }
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
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
    
}
