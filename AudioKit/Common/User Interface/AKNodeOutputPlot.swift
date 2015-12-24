//
//  AKNodeOutputPlot.swift
//  AudioKit For iOS
//
//  Created by Aurelius Prochazka on 12/12/15.
//  Copyright © 2015 AudioKit. All rights reserved.
//

import Foundation

#if os(OSX)
    public typealias AKView = NSView
    typealias AKColor = NSColor
#else
    public typealias AKView = UIView
    typealias AKColor = UIColor
#endif

public class AKNodeOutputPlot {

    let bufferSize: UInt32 = 512
    public var plot: EZAudioPlot?
    public var containerView: AKView?
    
    public init(_ input: AKNode, width: CGFloat = 1000.0, height: CGFloat = 500.0) {
        print("fdsa")
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
                strongSelf.plot!.updateBuffer(&tail[offset],
                    withBufferSize: strongSelf.bufferSize);
            }
        }
        
    }
    
}
