//
//  AKWaveformLayer.swift
//  AudioKit
//
//  Created by Ryan Francesconi on 11/21/18.
//  Copyright © 2020 AudioKit. All rights reserved.
//

/// A CAShapeLayer rendering of a mono waveform. Can be updated on any thread.
open class AKWaveformLayer: CAShapeLayer {
    /// controls whether to use the default CoreAnimation actions or not for property transitions
    public var allowActions: Bool = true

    public var isMirrored: Bool = true {
        didSet {
            updateLayer()
        }
    }

    private var _table: [Float]?
    public var table: [Float]? {
        get {
            return _table
        }
        set {
            guard let newValue = newValue else {
                _table = nil
                return
            }
            // validate data
            for value in newValue where !value.isFinite {
                return
            }

            _table = newValue
            updateABSMax()
        }
    }

    public var isEmpty: Bool {
        if let table = table, table.isNotEmpty {
            return false
        }
        return true
    }

    public var gain: Float = 1 {
        didSet {
            updateLayer()
        }
    }

    private var absmax: Double = 1.0

    public convenience init(table: [Float],
                            size: CGSize? = nil,
                            fillColor: CGColor? = nil,
                            strokeColor: CGColor? = nil,
                            backgroundColor: CGColor? = nil,
                            opacity: Float = 1,
                            isMirrored: Bool = false) {
        self.init()
        self.table = table
        self.isMirrored = isMirrored
        updateABSMax()

        self.opacity = opacity
        self.backgroundColor = backgroundColor
        self.strokeColor = strokeColor
        lineWidth = 0.5 // default if stroke is used, otherwise this does nothing

        self.fillColor = fillColor ?? AKColor.black.cgColor

        masksToBounds = false
        isOpaque = false
        drawsAsynchronously = true

        shadowColor = NSColor.black.cgColor
        shadowOpacity = 0.4
        shadowOffset = NSSize(width: 1, height: -1)
        shadowRadius = 2.0
    }

    // MARK: - Public Functions

    /// controls whether to use the default CoreAnimation actions or not for property transitions
    public override func action(forKey event: String) -> CAAction? {
        return allowActions ? super.action(forKey: event) : nil
    }

    public func updateLayer() {
        updateLayer(with: frame.size)
    }

    public func updateLayer(with size: CGSize) {
        guard size != CGSize.zero else {
            return
        }

        // it could be possible switch mode, vector or bitmap
        // vector appears to be faster at redrawing when objects are very long
        updateLayerWithPath(with: size)
    }

    public func dispose() {
        // AKLog("* disposing table data")
        table?.removeAll()
        table = nil
    }

    deinit {
        // AKLog("* WaveformLayer")
    }

    // MARK: - Private Functions

    private func updateABSMax() {
        guard let table = table else { return }

        let max = Double(table.max() ?? 1.0)
        let min = Double(table.min() ?? -1.0)
        absmax = [max, abs(min)].max() ?? 1.0
    }

    private func updateLayerWithImage(with size: CGSize) {
        contents = createImage(with: size)
    }

    private func updateLayerWithPath(with size: CGSize) {
        guard let path = createPath(at: size) else {
            return
        }
        self.path = path
    }

    private func createPath(at size: CGSize) -> CGPath? {
        guard let table = table,
            table.isNotEmpty,
            size != CGSize.zero else {
            return nil
        }

        let half: CGFloat = isMirrored ? 2 : 1
        let halfHeight = size.height / half
        let path = CGMutablePath()
        let halfPath = CGMutablePath()
        let startPoint = CGPoint(x: 0, y: 0)

        halfPath.move(to: startPoint)

        let theWidth = max(1, Int(size.width))
        let strideWidth = max(1, table.count / theWidth)

        // good for seeing what the stride is:
        //        if strideWidth > 1 {
        //            AKLog("table.count", table.count, "strideWidth", strideWidth)
        //        }
        // this is a sort of visual normalization - not desired in an accurate dB situation
        let sampleDrawingScale = Double(halfHeight) / absmax * 0.75

        for i in stride(from: 0, to: table.count, by: strideWidth) {
            let x = Double(i) / Double(table.count) * Double(size.width)
            let y = Double(table[i]) * sampleDrawingScale

            halfPath.addLine(to: CGPoint(x: x, y: y))
        }
        halfPath.addLine(to: CGPoint(x: size.width, y: startPoint.y))

        // if mirrored just copy the path and flip it upside down
        if isMirrored {
            var xf: CGAffineTransform = .identity
            xf = xf.translatedBy(x: 0.0, y: halfHeight)
            path.addPath(halfPath, transform: xf)

            xf = xf.scaledBy(x: 1.0, y: -1)
            if let copy = halfPath.copy(using: &xf) {
                path.addPath(copy)
            }
        } else {
            path.addPath(halfPath)
        }

        return path
    }

    // Unused, but also works to render the path as a bitmap
    private func createImage(with size: CGSize) -> CGImage? {
        // AKLog("Creating image with visualScaleFactor", visualScaleFactor, "size:", frame.size)

        let width = Int(size.width)
        let height = Int(size.height)
        guard let bitmap = NSBitmapImageRep(bitmapDataPlanes: nil,
                                            pixelsWide: width,
                                            pixelsHigh: height,
                                            bitsPerSample: 8,
                                            samplesPerPixel: 4,
                                            hasAlpha: true,
                                            isPlanar: false,
                                            colorSpaceName: .deviceRGB,
                                            bytesPerRow: width * 4,
                                            bitsPerPixel: 32) else {
            return nil
        }

        guard let context = NSGraphicsContext(bitmapImageRep: bitmap) else {
            return nil
        }
        // if you don't want anti-aliased images:
        //        context.shouldAntialias = false
        //        context.imageInterpolation = .none

        NSGraphicsContext.saveGraphicsState()

        // this is so the text knows where to draw
        NSGraphicsContext.current = context

        drawImage(into: context.cgContext, with: size)
        context.flushGraphics()
        NSGraphicsContext.restoreGraphicsState()

        return bitmap.cgImage
    }

    // Unused, but also works to render the path as a bitmap
    private func drawImage(into context: CGContext, with size: CGSize) {
        guard let fillColor = fillColor,
            let path = createPath(at: size) else { return }
        context.addPath(path)
        context.closePath()
        context.setFillColor(fillColor)
        context.fillPath()
    }
}
