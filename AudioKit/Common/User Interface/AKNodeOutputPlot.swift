//
//  AKNodeOutputPlot.swift
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright © 2016 AudioKit. All rights reserved.
//

import Foundation

/// Plot the output from any node in an signal processing graph
@IBDesignable
public class AKNodeOutputPlot: EZAudioPlot {

    internal func setupNode(input: AKNode?) {
        input?.avAudioNode.installTapOnBus(0, bufferSize: bufferSize, format: AudioKit.format) { [weak self] (buffer, time) -> Void in
            if let strongSelf = self {
                buffer.frameLength = strongSelf.bufferSize
                let offset = Int(buffer.frameCapacity - buffer.frameLength)
                let tail = buffer.floatChannelData[0]
                strongSelf.updateBuffer(&tail[offset], withBufferSize: strongSelf.bufferSize)
            }
        }
    }
    
    internal var bufferSize: UInt32 = 1024
    
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
    
}
