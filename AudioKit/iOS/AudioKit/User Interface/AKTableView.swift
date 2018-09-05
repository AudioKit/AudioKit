//
//  AKTableView.swift
//  AudioKit
//
//  Created by Aurelius Prochazka, revision7.
//  Copyright © 2018 AudioKit. All rights reserved.
//

import UIKit
import AudioKit

/// Displays the values in the table into a nice graph
public class AKTableView: UIView {

    var table: AKTable
    var absmax: Double = 1.0

    /// Initialize the table view
    @objc public init(_ table: AKTable, frame: CGRect = CGRect(x: 0, y: 0, width: 440, height: 150)) {
        self.table = table
        super.init(frame: frame)
        let max = Double(table.max() ?? 1.0)
        let min = Double(table.min() ?? -1.0)
        absmax = [max, abs(min)].max() ?? 1.0
    }

    /// Required initializer
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    /// Draw the table view
    override public func draw(_ rect: CGRect) {

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
        bezierPath.move(to: CGPoint(x: 0.0, y: (1.0 - table[0] / absmax) * height))

        for index in 1..<table.count {

            let xPoint = Double(index) / table.count * width

            let yPoint = (1.0 - table[index] / absmax * padding) * height

            bezierPath.addLine(to: CGPoint(x: xPoint, y: yPoint))
        }

        bezierPath.addLine(to: CGPoint(x: Double(frame.width), y: (1.0 - table[0] / absmax * padding) * height))

        UIColor.black.setStroke()
        bezierPath.lineWidth = 2
        bezierPath.stroke()
    }
}
