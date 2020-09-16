// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

#if !os(macOS) || targetEnvironment(macCatalyst)

import UIKit

/// Displays the values in the table into a nice graph
public class AKTableView: UIView {

    var table: AKTable
    var absmax: Double = 1.0

    /// Initialize the table view
    public init(_ table: AKTable, frame: CGRect = CGRect(x: 0, y: 0, width: 440, height: 150)) {
        self.table = table
        super.init(frame: frame)
        let max = Double(table.max() ?? 1.0)
        let min = Double(table.min() ?? -1.0)
        absmax = [max, abs(min)].max() ?? 1.0
    }

    /// Required initializer
    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    /// Draw the table view
    public override func draw(_ rect: CGRect) {

        let width = Double(frame.width)
        let height = Double(frame.height) / 2.0
        let padding = 0.9

        let border = UIBezierPath(rect: CGRect(x: 0, y: 0, width: frame.width, height: frame.height))
        let bgcolor = AKStylist.sharedInstance.nextColor
        bgcolor.setFill()
        border.fill()
        UIColor.black.setStroke()
        border.lineWidth = 8
        border.stroke()

        let midline = UIBezierPath()
        midline.move(to: CGPoint(x: 0, y: frame.height / 2))
        midline.addLine(to: CGPoint(x: frame.width, y: frame.height / 2))
        UIColor.black.setStroke()
        midline.lineWidth = 1
        midline.stroke()

        let bezierPath = UIBezierPath()
        bezierPath.move(to: CGPoint(x: 0.0, y: (1.0 - Double(table[0]) / absmax) * height))

        for index in 1..<table.count {

            let xPoint = Double(index) / Double(table.count) * width

            let yPoint = (1.0 - Double(table[index]) / absmax * padding) * height

            bezierPath.addLine(to: CGPoint(x: xPoint, y: yPoint))
        }

        bezierPath.addLine(to: CGPoint(x: Double(frame.width), y: (1.0 - Double(table[0]) / absmax * padding) * height))

        UIColor.black.setStroke()
        bezierPath.lineWidth = 2
        bezierPath.stroke()
    }
}

#else

import Cocoa

public class AKTableView: NSView {

    public var table: AKTable {
        didSet {
            let max = Double(table.max() ?? 1.0)
            let min = Double(table.min() ?? -1.0)
            absmax = [max, abs(min)].max() ?? 1.0
            needsDisplay = true
        }
    }

    public var absmax: Double = 1.0

    public init(_ table: AKTable, frame: CGRect = CGRect(width: 440, height: 150)) {
        self.table = table
        super.init(frame: frame)
        let max = Double(table.max() ?? 1.0)
        let min = Double(table.min() ?? -1.0)
        absmax = [max, abs(min)].max() ?? 1.0
    }

    override public var isFlipped: Bool {
        return true
    }

    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override public func draw(_ rect: CGRect) {

        let width = Double(frame.width)
        let height = Double(frame.height) / 2.0
        let padding = 0.9

        let border = NSBezierPath(rect: NSRect(size: frame.size))
        let bgcolor = AKStylist.sharedInstance.nextColor
        bgcolor.setFill()
        border.fill()
        NSColor.black.setStroke()
        border.lineWidth = 8
        border.stroke()

        let midline = NSBezierPath()
        midline.move(to: NSPoint(x: 0, y: frame.height / 2))
        midline.line(to: NSPoint(x: frame.width, y: frame.height / 2))
        NSColor.black.setStroke()
        midline.lineWidth = 1
        midline.stroke()

        let bezierPath = NSBezierPath()
        bezierPath.move(to: NSPoint(x: 0.0, y: (1.0 - Double(table[0]) / absmax) * height))

        let strideWidth = max(1, Int(Double(table.count) / Double(frame.width)))

        for i in  stride(from: 0, to: table.count, by: strideWidth) {

            let x = Double(i) / Double(table.count) * width

            let y = (1.0 - Double(table[i]) / absmax * padding) * height

            bezierPath.line(to: NSPoint(x: x, y: y))
        }

        bezierPath.line(to: NSPoint(x: Double(frame.width),
                                    y: (1.0 - Double(table[0]) / absmax * padding) * height))

        NSColor.black.setStroke()
        bezierPath.lineWidth = 2
        bezierPath.stroke()
    }
}

#endif
