//
//  AKRollingOutputPlot.swift
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright © 2016 AudioKit. All rights reserved.
//

import Foundation

/// Wrapper class for plotting audio from the final mix in a rolling plot
@IBDesignable
public class AKRollingOutputPlot: EZAudioPlot {
    internal func setupNode() {
        AudioKit.engine.outputNode.installTap(onBus: 0, bufferSize: bufferSize, format: nil) { [weak self] (buffer, time) -> Void in
            if let strongSelf = self {
                buffer.frameLength = strongSelf.bufferSize
                let offset = Int(buffer.frameCapacity - buffer.frameLength)
                let tail = (buffer.floatChannelData?[0])!
                strongSelf.updateBuffer(&tail[offset], withBufferSize: strongSelf.bufferSize)
            }
        }
    }
    
    internal var bufferSize: UInt32 = 1024
    
    deinit {
        AudioKit.engine.outputNode.removeTap(onBus: 0)
    }
    
    /// Initialize the plot in a frame
    ///
    /// - parameter frame: CGRect in which to draw the plot
    ///
    override public init(frame: CGRect) {
        super.init(frame: frame)
        setupNode()
    }
    
    /// Initialize the plot in a frame with a different buffer size
    ///
    /// - parameter frame: CGRect in which to draw the plot
    /// - parameter bufferSize: size of the buffer - raise this number if the device struggles with generating the waveform
    ///
    public init(frame: CGRect, bufferSize: Int) {
        super.init(frame: frame)
        self.bufferSize = UInt32(bufferSize)
        setupNode()
    }

    /// Required coder-based initialization (for use with Interface Builder)
    ///
    /// - parameter coder: NSCoder
    ///
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupNode()
    }

    /// Create a View with the plot (usually for playgrounds)
    ///
    /// - returns: AKView
    /// - parameter width: Width of the view
    /// - parameter height: Height of the view
    ///
    public static func createView(_ width: CGFloat = 1000.0, height: CGFloat = 500.0) -> AKView {
        
        let frame = CGRect(x: 0.0, y: 0.0, width: width, height: height)
        let plot = AKRollingOutputPlot(frame: frame)
        
        plot.plotType = .rolling
        plot.backgroundColor = AKColor.white()
        plot.color = AKColor.green()
        plot.shouldFill = true
        plot.shouldMirror = true
        plot.shouldCenterYAxis = true
        
        let containerView = AKView(frame: frame)
        containerView.addSubview(plot)
        return containerView
    }
}
