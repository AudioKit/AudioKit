//
//  AKRollingOutputPlot.swift
//  AudioKitUI
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright © 2018 AudioKit. All rights reserved.
//

/// Wrapper class for plotting audio from the final mix in a rolling plot
@IBDesignable
open class AKRollingOutputPlot: AKNodeOutputPlot {

    /// Initialize the plot in a frame with a different buffer size
    ///
    /// - Parameters:
    ///   - frame: CGRect in which to draw the plot
    ///   - bufferSize: size of the buffer - raise this number if the device struggles with generating the waveform
    ///
    @objc public init(frame: CGRect, bufferSize: Int = 1_024) {
        super.init(frame: frame)
        self.bufferSize = UInt32(bufferSize)

        plotType = .rolling
        backgroundColor = AKColor.white
        color = AKColor.green
        shouldFill = true
        shouldMirror = true
        shouldCenterYAxis = true
    }

    /// Required coder-based initialization (for use with Interface Builder)
    ///
    /// - parameter coder: NSCoder
    ///
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)

        plotType = .rolling
        backgroundColor = AKColor.black
        color = AKColor.green
        shouldFill = true
        shouldMirror = true
        shouldCenterYAxis = true
    }

    /// Create a View with the plot (usually for playgrounds)
    ///
    /// - Parameters:
    ///   - width: Width of the view
    ///   - height: Height of the view
    ///
    public static func createView(width: CGFloat = 440, height: CGFloat = 200.0) -> AKView {

        let frame = CGRect(x: 0.0, y: 0.0, width: width, height: height)
        let plot = AKRollingOutputPlot(frame: frame)

        plot.plotType = .rolling
        plot.backgroundColor = AKColor.black
        plot.color = AKColor.green
        plot.shouldFill = true
        plot.shouldMirror = true
        plot.shouldCenterYAxis = true

        let containerView = AKView(frame: frame)
        containerView.addSubview(plot)
        return containerView
    }
}
