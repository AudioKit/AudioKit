// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import QuartzCore

/// Container CALayer based class for multiple CAWaveformLayers
public class AKWaveform: CALayer {
    private var halfWidth: Int = 0
    private var reverseDirection: CGFloat = 1
    private var plotSize = CGSize(width: 200, height: 20)

    /// controls whether to use the default CoreAnimation actions or not for property transitions
    public var allowActions: Bool = true

    public private(set) var plots = [AKWaveformLayer]()
    public private(set) var samplesPerPixel: Int = 0
    public private(set) var channels: Int = 2

    public var minimumStereoHeight: CGFloat = 50

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

    public var waveformOpacity: Float = 1 {
        didSet {
            for plot in plots {
                plot.opacity = waveformOpacity
            }
        }
    }

    public var waveformColor: CGColor = AKColor.black.cgColor {
        didSet {
            for plot in plots {
                plot.fillColor = waveformColor
            }
        }
    }

    // Reverse the waveform
    public var isReversed: Bool = false {
        didSet {
            updateReverse()
        }
    }

    // display channels backwards, so Right first
    public var flipStereo: Bool = false {
        didSet {
            updateLayer()
        }
    }

    public var mixToMono: Bool = false {
        didSet {
            updateLayer()
        }
    }

    // MARK: - Initialization

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
        self.waveformColor = waveformColor ?? AKColor.black.cgColor
        self.backgroundColor = backgroundColor
        isOpaque = false
        initPlots()
    }

    deinit {
        // AKLog("* { Waveform \(name ?? "") } *")
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
            AKLog("Waveform isn't ready to be reversed yet. No data.", type: .error)
            return
        }
        let direction: CGFloat = isReversed ? -1.0 : 1.0

        // AKLog("Current Direction:", reverseDirection, "proposed direction:", direction)

        guard direction != reverseDirection else { return }

        var xf: CGAffineTransform = .identity
        xf = xf.scaledBy(x: direction, y: 1)

        for plot in plots {
            plot.setAffineTransform(xf)
        }

        reverseDirection = direction
        // AKLog("REVERSING:", reverseDirection)
    }

    // TODO: account for files that have more than 2 channels
    private func fillPlots(with data: FloatChannelData, completionHandler: (() -> Void)? = nil) {
        // just setting the table data here
        if !plots.isEmpty {
            if let left = data.first {
                // AKLog("** Updating table data", left.count, "points")
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
        // AKLog("** Creating plots... channels:", data.count)

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

        // TODO: multi channel, more than 2 channels...

        completionHandler?()
    }

    private func createPlot(data: [Float], color: CGColor) -> AKWaveformLayer {
        // AKLog(data.count, "plotSize", plotSize)

        let plot = AKWaveformLayer(table: data,
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

    public func updateLayer() {
        guard plots.isNotEmpty else {
            AKLog("Plots are empty... nothing to layout.", type: .error)
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

        //         AKLog("** relayout, showStereo", showStereo, "flipStereo", flipStereo,
        //                   "plotSize", plotSize, "numberOfPoints", numberOfPoints,
        //                   "halfWidth", halfWidth, "maxNumberOfPoints", maxNumberOfPoints,
        //                   "adjustedHeight", adjustedHeight)

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

    /// can be called from any thread
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

    public func duplicate() -> AKWaveform? {
        let waveform = AKWaveform(channels: channels,
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

    public func dispose() {
        for plot in plots {
            plot.removeFromSuperlayer()
            plot.dispose()
        }
        plots.removeAll()
        removeFromSuperlayer()
    }
}
