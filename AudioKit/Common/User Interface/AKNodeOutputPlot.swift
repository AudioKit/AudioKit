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

/// Plot the output from any node in an signal processing graph
public class AKNodeOutputPlot {

    internal let bufferSize: UInt32 = 512
    
    /// EZAudioPlot containing actual plot
    public var plot: EZAudioPlot?
    
    /// View with the plot
    public var containerView: AKView?
    
    /** Initialize the plot with the output from a given node and optional plot size
     
     - parameter input: AKNode from which to get the plot data
     - parameter width: Width of the view
     - parameter height: Height of the view
     */
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
