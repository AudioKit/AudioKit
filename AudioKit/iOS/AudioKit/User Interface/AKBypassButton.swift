//
//  AKBypassButton.swift
//  AudioKit for iOS
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright © 2017 Aurelius Prochazka. All rights reserved.
//

/// Button that just access the start/stop feature of an AKNode,
/// primarily used for playgrounds, but potentially useful in your own code.
open class AKBypassButton: UIView {

    var node: AKToggleable
    var bypassOuterPath = UIBezierPath()
    var processOuterPath = UIBezierPath()

    override open func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first {

            let touchLocation = touch.location(in: self)
            if bypassOuterPath.contains(touchLocation) && node.isPlaying {
                node.bypass()
            }
            if processOuterPath.contains(touchLocation) && node.isBypassed {
                node.start()
            }
            setNeedsDisplay()
        }
    }

    /// Instatiate the button with a node and a size
    ///
    /// - Parameters:
    ///   - node:  Toggleable node that will be affected
    ///   - frame: bounds of the button
    ///
    public init(node: AKToggleable, frame: CGRect = CGRect(x: 0, y: 0, width: 440, height: 60)) {
        self.node = node
        super.init(frame: frame)
    }

    /// Required initializer
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func drawBypassButton(isBypassed: Bool = false) {
        //// General Declarations
        let context = UIGraphicsGetCurrentContext()

        //// Color Declarations
        let red = #colorLiteral(red: 1.000, green: 0.000, blue: 0.062, alpha: 1.000)
        let gray = #colorLiteral(red: 0.835, green: 0.842, blue: 0.836, alpha: 1.000)
        let green = #colorLiteral(red: 0.029, green: 1.000, blue: 0.000, alpha: 1.000)

        //// Variable Declarations
        let processingColor = isBypassed ? gray : green
        let bypassingCOlor = isBypassed ? red : gray

        let bypassedText = isBypassed ? "Off / Bypassed" : "Stop / Bypass"
        let processingText = isBypassed ? "Play / Start" : "Playing"

        //// bypassGroup
        //// bypassOuter Drawing
        bypassOuterPath = UIBezierPath(rect: CGRect(x: 0, y: 0, width: 220, height: 60))
        bypassingCOlor.setFill()
        bypassOuterPath.fill()

        //// bypassLabel Drawing
        let bypassLabelRect = CGRect(x: 0, y: 0, width: 220, height: 60)
        let bypassLabelStyle = NSMutableParagraphStyle()
        bypassLabelStyle.alignment = .center

        let bypassLabelFontAttributes = [NSFontAttributeName: UIFont.boldSystemFont(ofSize: 24), NSForegroundColorAttributeName: UIColor.black, NSParagraphStyleAttributeName: bypassLabelStyle]

        let bypassLabelInset: CGRect = bypassLabelRect.insetBy(dx: 10, dy: 0)
        let bypassLabelTextHeight: CGFloat = NSString(string: bypassedText).boundingRect(with: CGSize(width: bypassLabelInset.width, height: CGFloat.infinity), options: NSStringDrawingOptions.usesLineFragmentOrigin, attributes: bypassLabelFontAttributes, context: nil).size.height
        context?.saveGState()
        context?.clip(to: bypassLabelInset)
        NSString(string: bypassedText).draw(in: CGRect(x: bypassLabelInset.minX, y: bypassLabelInset.minY + (bypassLabelInset.height - bypassLabelTextHeight) / 2, width: bypassLabelInset.width, height: bypassLabelTextHeight), withAttributes: bypassLabelFontAttributes)
        context?.restoreGState()

        //// processGroup
        //// processOuter Drawing
        processOuterPath = UIBezierPath(rect: CGRect(x: 220, y: 0, width: 220, height: 60))
        processingColor.setFill()
        processOuterPath.fill()

        //// processLabel Drawing
        let processLabelRect = CGRect(x: 220, y: 0, width: 220, height: 60)
        let processLabelStyle = NSMutableParagraphStyle()
        processLabelStyle.alignment = .center

        let processLabelFontAttributes = [NSFontAttributeName: UIFont.boldSystemFont(ofSize: 24), NSForegroundColorAttributeName: UIColor.black, NSParagraphStyleAttributeName: processLabelStyle]

        let processLabelInset: CGRect = processLabelRect.insetBy(dx: 10, dy: 0)
        let processLabelTextHeight: CGFloat = NSString(string: processingText).boundingRect(with: CGSize(width: processLabelInset.width, height: CGFloat.infinity), options: NSStringDrawingOptions.usesLineFragmentOrigin, attributes: processLabelFontAttributes, context: nil).size.height
        context?.saveGState()
        context?.clip(to: processLabelInset)
        NSString(string: processingText).draw(in: CGRect(x: processLabelInset.minX, y: processLabelInset.minY + (processLabelInset.height - processLabelTextHeight) / 2, width: processLabelInset.width, height: processLabelTextHeight), withAttributes: processLabelFontAttributes)
        context?.restoreGState()
    }

    /// Draw the button
    override open func draw(_ rect: CGRect) {
        drawBypassButton(isBypassed: node.isBypassed)
    }
}
