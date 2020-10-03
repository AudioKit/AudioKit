// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import CoreGraphics
import QuartzCore

/// A CAShapeLayer rendering of a mono waveform. Can be updated on any thread.
public class WaveformLayer: CAShapeLayer {
    /// controls whether to use the default CoreAnimation actions or not for property transitions
    public var allowActions: Bool = true

    /// Mirrored is the traditional DAW display
    public var isMirrored: Bool = true {
        didSet {
            updateLayer()
        }
    }

    private var _table: [Float]?
    /// Array of float values
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

    /// Does this contain any information
    public var isEmpty: Bool {
        if let table = table, table.isNotEmpty {
            return false
        }
        return true
    }

    private var absmax: Double = 1.0

    /// Initialize with all parameters
    /// - Parameters:
    ///   - table: Array of floats
    ///   - size: Layer size
    ///   - fillColor: Fill Color
    ///   - strokeColor: Stroke color
    ///   - backgroundColor: Backround color
    ///   - opacity: Opacity
    ///   - isMirrored: Whether or not to display mirrored
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
        #if targetEnvironment(macCatalyst)
        self.fillColor = fillColor ?? CGColor(srgbRed: 0, green: 0, blue: 0, alpha: 1)
        #else
        self.fillColor = fillColor ?? CGColor(red: 0, green: 0, blue: 0, alpha: 1)
        #endif
        masksToBounds = false
        isOpaque = false
        drawsAsynchronously = true
        #if targetEnvironment(macCatalyst)
        shadowColor = CGColor(srgbRed: 0, green: 0, blue: 0, alpha: 1)
        #else
        shadowColor = CGColor(red: 0, green: 0, blue: 0, alpha: 1)
        #endif
        shadowOpacity = 0.4
        shadowOffset = CGSize(width: 1, height: -1)
        shadowRadius = 2.0
    }

    // MARK: - Public Functions

    /// controls whether to use the default CoreAnimation actions or not for property transitions
    override public func action(forKey event: String) -> CAAction? {
        return allowActions ? super.action(forKey: event) : nil
    }

    /// Update layer
    public func updateLayer() {
        updateLayer(with: frame.size)
    }

    /// Update layer with size
    /// - Parameter size: Size of layer
    public func updateLayer(with size: CGSize) {
        guard size != CGSize.zero else {
            return
        }

        updateLayerWithPath(with: size)
    }

    /// Remove all data
    public func dispose() {
        table?.removeAll()
        table = nil
    }

    // MARK: - Private Functions

    private func updateABSMax() {
        guard let table = table else { return }

        let max = Double(table.max() ?? 1.0)
        let min = Double(table.min() ?? -1.0)
        absmax = [max, abs(min)].max() ?? 1.0
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
        //            Log("table.count", table.count, "strideWidth", strideWidth)
        //        }
        // this is a sort of visual normalization - not desired in an accurate dB situation
        let sampleDrawingScale = Double(halfHeight) / absmax * 0.85

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
}
