//
//  AKTableView.swift
//  AudioKit for macOS
//
//  Created by Aurelius Prochazka on 7/15/17.
//  Copyright © 2017 AudioKit. All rights reserved.
//

public class AKTableView: NSView {

    var table: AKTable
    var absmax: Double = 1.0
    public init(_ table: AKTable, frame: CGRect = CGRect(x: 0, y: 0, width: 440, height: 150)) {
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

        let border = NSBezierPath(rect: NSRect(x: 0, y: 0, width: frame.width, height: frame.height))
        let bgcolor = AKColorPalette.sharedInstance.next
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
        bezierPath.move(to: NSPoint(x: 0.0, y: (1.0 - table[0] / absmax)  * height))

        for i in 1..<table.count {

            let x = Double(i) / table.count  * width

            let y = (1.0 - table[i] / absmax * padding) * height

            bezierPath.line(to: NSPoint(x: x, y: y))
        }

        bezierPath.line(to: NSPoint(x: Double(frame.width), y: (1.0 - table[0] / absmax * padding)  * height))

        NSColor.black.setStroke()
        bezierPath.lineWidth = 2
        bezierPath.stroke()
    }
}
