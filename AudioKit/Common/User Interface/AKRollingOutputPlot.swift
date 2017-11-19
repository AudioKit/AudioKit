//
//  AKRollingOutputPlot.swift
//  AudioKitUI
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright © 2017 Aurelius Prochazka. All rights reserved.
//
#if !JAZZY_HACK
    import AudioKit
#endif

/// Wrapper class for plotting audio from the final mix in a rolling plot
@IBDesignable
open class AKRollingOutputPlot: EZAudioPlot {
    internal func setupNode() {
        AudioKit.engine.outputNode.installTap(onBus: 0,
                                              bufferSize: bufferSize,
                                              format: nil) { [weak self] (buffer, _) in
                                                guard let strongSelf = self else {
                                                    AKLog("Unable to create strong reference to self")
                                                    return
                                                }
                                                buffer.frameLength = strongSelf.bufferSize
                                                let offset = Int(buffer.frameCapacity - buffer.frameLength)
                                                if let tail = buffer.floatChannelData?[0] {
                                                    strongSelf.updateBuffer(&tail[offset],
                                                                            withBufferSize: strongSelf.bufferSize)
                                                }
        }
    }

    /// Useful to reconnect after connecting to Audiobus or IAA
    @objc public func reconnect() {
        AudioKit.engine.outputNode.removeTap(onBus: 0)
        setupNode()
    }

    func setupReconnection() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(reconnect),
                                               name: NSNotification.Name(rawValue: "IAAConnected"),
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(reconnect),
                                               name: NSNotification.Name(rawValue: "IAADisconnected"),
                                               object: nil)
    }

    internal var bufferSize: UInt32 = 1_024

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
        setupReconnection()
    }

    /// Initialize the plot in a frame with a different buffer size
    ///
    /// - Parameters:
    ///   - frame: CGRect in which to draw the plot
    ///   - bufferSize: size of the buffer - raise this number if the device struggles with generating the waveform
    ///
    @objc public init(frame: CGRect, bufferSize: Int) {
        super.init(frame: frame)
        self.bufferSize = UInt32(bufferSize)
        setupNode()
        setupReconnection()
    }

    /// Required coder-based initialization (for use with Interface Builder)
    ///
    /// - parameter coder: NSCoder
    ///
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupNode()
        setupReconnection()

        plotType = .rolling
        backgroundColor = AKColor.white
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
    open static func createView(width: CGFloat = 440, height: CGFloat = 200.0) -> AKView {

        let frame = CGRect(x: 0.0, y: 0.0, width: width, height: height)
        let plot = AKRollingOutputPlot(frame: frame)

        plot.plotType = .rolling
        plot.backgroundColor = AKColor.white
        plot.color = AKColor.green
        plot.shouldFill = true
        plot.shouldMirror = true
        plot.shouldCenterYAxis = true

        let containerView = AKView(frame: frame)
        containerView.addSubview(plot)
        return containerView
    }
}
