//
//  AKOutputWaveformPlot
//  AudioKitUI
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright © 2018 AudioKit. All rights reserved.
//

/// Wrapper class for plotting audio from the final mix in a waveform plot
@IBDesignable
open class AKOutputWaveformPlot: AKNodeOutputPlot {

    /// Create a View with the plot (usually for playgrounds)
    ///
    /// - Parameters:
    ///   - width: Width of the view
    ///   - height: Height of the view
    ///
    public static func createView(width: CGFloat = 440, height: CGFloat = 200.0) -> AKView {

        let frame = CGRect(x: 0.0, y: 0.0, width: width, height: height)
        let plot = AKOutputWaveformPlot(frame: frame)

        plot.plotType = .buffer
        plot.backgroundColor = AKColor.clear
        plot.shouldCenterYAxis = true

        let containerView = AKView(frame: frame)
        containerView.addSubview(plot)
        return containerView
    }
}
