// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import QuartzCore

/// Container CALayer based class for multiple CAWaveformLayers
public class Waveform: CALayer {
    private var halfWidth: Int = 0
    private var reverseDirection: CGFloat = 1
    private var plotSize = CGSize(width: 200, height: 20)

    /// controls whether to use the default CoreAnimation actions or not for property transitions
    public var allowActions: Bool = true

    /// Array of waveform layers
    public private(set) var plots = [WaveformLayer]()
    /// Number of samples per pixel
    public private(set) var samplesPerPixel: Int = 0
    /// Number of channels
    public private(set) var channels: Int = 2

    /// Minimum height when in stereo
    public var minimumStereoHeight: CGFloat = 50

    /// Whether or not to display as stereo
    public var showStereo: Bool = true {
        didSet { updateLayer() }
    }

    /// show the negative view as well. false saves space
    public var isMirrored: Bool = true {
        didSet {
            for plot in plots {
                plot.isMirrored = isMirrored
            }
        }
    }

    /// Opacity
    public var waveformOpacity: Float = 1 {
        didSet {
            for plot in plots {
                plot.opacity = waveformOpacity
            }
        }
    }

    /// Color
    public var waveformColor: CGColor = CGColor(red: 0, green: 0, blue: 0, alpha: 1) {
        didSet {
            for plot in plots {
                plot.fillColor = waveformColor
            }
        }
    }

    /// Reverse the waveform
    public var isReversed: Bool = false {
        didSet {
            updateReverse()
        }
    }

    /// display channels backwards, so Right first
    public var flipStereo: Bool = false {
        didSet {
            updateLayer()
        }
    }

    /// Whether or not to mix down to a mono view
    public var mixToMono: Bool = false {
        didSet {
            updateLayer()
        }
    }

    // MARK: - Initialization

    /// Initialize with parameters
    /// - Parameters:
    ///   - channels: Channel count
    ///   - size: Rectangular size
    ///   - waveformColor: Foreground color
    ///   - backgroundColor: Background color
    public convenience init(channels: Int = 2,
                            size: CGSize? = nil,
                            waveformColor: CGColor? = nil,
                            backgroundColor: CGColor? = nil) {
        self.init()
        self.channels = channels
        self.backgroundColor = backgroundColor

        if let size = size {
            plotSize = size
        }
        // make a default size
        frame = CGRect(origin: CGPoint(), size: plotSize)
        self.waveformColor = waveformColor ?? CGColor(red: 0, green: 0, blue: 0, alpha: 1) 
        self.backgroundColor = backgroundColor
        isOpaque = false
        initPlots()
    }

    deinit {
        // Log("* { Waveform \(name ?? "") } *")
    }

    // MARK: - Private functions

    // creates plots without data
    private func initPlots() {
        let color = waveformColor

        let leftPlot = createPlot(data: [], color: color)
        plots.insert(leftPlot, at: 0)
        addSublayer(leftPlot)

        // guard !displayAsMono else { return }

        if channels == 2 {
            let rightPlot = createPlot(data: [], color: color)
            plots.insert(rightPlot, at: 1)
            addSublayer(rightPlot)
        }
    }

    private func updateReverse() {
        guard !plots.isEmpty else {
            Log("Waveform isn't ready to be reversed yet. No data.", type: .error)
            return
        }
        let direction: CGFloat = isReversed ? -1.0 : 1.0

        // Log("Current Direction:", reverseDirection, "proposed direction:", direction)

        guard direction != reverseDirection else { return }

        var xf: CGAffineTransform = .identity
        xf = xf.scaledBy(x: direction, y: 1)

        for plot in plots {
            plot.setAffineTransform(xf)
        }

        reverseDirection = direction
        // Log("REVERSING:", reverseDirection)
    }

    private func fillPlots(with data: FloatChannelData, completionHandler: (() -> Void)? = nil) {
        // just setting the table data here
        if !plots.isEmpty {
            if let left = data.first {
                // Log("** Updating table data", left.count, "points")
                plots[0].table = left
                samplesPerPixel = left.count
            }

            if data.count > 1, let right = data.last, plots.count > 1 {
                plots[1].table = right
            }
            completionHandler?()
            return
        }

        // create the plots
        // Log("** Creating plots... channels:", data.count)

        if let left = data.first {
            let leftPlot = createPlot(data: left, color: waveformColor)
            plots.insert(leftPlot, at: 0)
            addSublayer(leftPlot)
            samplesPerPixel = left.count
        }

        // if the file is stereo add a second plot for the right channel
        if data.count > 1, let right = data.last {
            let rightPlot = createPlot(data: right, color: waveformColor)
            plots.insert(rightPlot, at: 1)
            addSublayer(rightPlot)
        }

        completionHandler?()
    }

    private func createPlot(data: [Float], color: CGColor) -> WaveformLayer {
        // Log(data.count, "plotSize", plotSize)

        let plot = WaveformLayer(table: data,
                                   size: plotSize,
                                   fillColor: color,
                                   strokeColor: nil,
                                   backgroundColor: nil,
                                   opacity: waveformOpacity,
                                   isMirrored: isMirrored)
        plot.allowActions = false
        return plot
    }

    // MARK: - Public functions

    /// controls whether to use the default CoreAnimation actions or not for property transitions
    override public func action(forKey event: String) -> CAAction? {
        return allowActions ? super.action(forKey: event) : nil
    }

    /// Upodate layers
    public func updateLayer() {
        guard plots.isNotEmpty else {
            Log("Plots are empty... nothing to layout.", type: .error)
            return
        }
        let width = frame.size.width
        let height = frame.size.height
        let floatChannels = CGFloat(channels)
        var heightDivisor = floatChannels

        if (!showStereo || height < minimumStereoHeight) || mixToMono {
            heightDivisor = 1
        }

        let adjustedHeight = height / heightDivisor
        let size = CGSize(width: width, height: adjustedHeight)

        plotSize = CGSize(width: round(size.width), height: round(size.height))

        let leftFrame = CGRect(origin: CGPoint(x: 0, y: heightDivisor == 1 ? 0 : adjustedHeight),
                               size: plotSize)
        let rightFrame = CGRect(origin: CGPoint(), size: plotSize)

        plots.first?.frame = flipStereo && plots.count > 1 ? rightFrame : leftFrame
        plots.first?.updateLayer(with: plotSize)

        if floatChannels > 1, plots.count > 1 {
            plots.last?.frame = flipStereo ? leftFrame : rightFrame
            plots.last?.updateLayer(with: plotSize)
        }
    }

    /// Fill with new data, can be called from any thread
    /// - Parameter data: Float channel data
    public func fill(with data: FloatChannelData) {
        fillPlots(with: data) {
            DispatchQueue.main.async {
                if self.isReversed {
                    self.updateReverse()
                }
                self.updateLayer()
            }
        }
    }

    /// Create a copy
    /// - Returns: New waveform
    public func duplicate() -> Waveform? {
        let waveform = Waveform(channels: channels,
                                  size: plotSize,
                                  waveformColor: waveformColor,
                                  backgroundColor: backgroundColor)

        var data = FloatChannelData(repeating: [], count: plots.count)
        if let value = plots.first?.table {
            data[0] = value
        }
        if let value = plots.last?.table {
            data[1] = value
        }
        waveform.fill(with: data)
        waveform.updateLayer()
        return waveform
    }

    /// Remove all plots from view
    public func dispose() {
        for plot in plots {
            plot.removeFromSuperlayer()
            plot.dispose()
        }
        plots.removeAll()
        removeFromSuperlayer()
    }
}
