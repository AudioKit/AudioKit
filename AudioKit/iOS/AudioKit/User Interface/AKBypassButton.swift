//
//  AKBypassButton.swift
//  AudioKit for iOS
//
//  Created by Aurelius Prochazka on 7/30/16.
//  Copyright © 2016 AudioKit. All rights reserved.
//

public class AKBypassButton: UIView {

    var node: AKToggleable
    var bypassOuterPath = UIBezierPath()
    var processOuterPath = UIBezierPath()

    override public func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        if let touch = touches.first {

            let touchLocation = touch.locationInView(self)
            if bypassOuterPath.containsPoint(touchLocation) && node.isPlaying {
                node.bypass()
            }
            if processOuterPath.containsPoint(touchLocation) && node.isBypassed {
                node.start()
            }
            setNeedsDisplay()
        }
    }

    public init(node: AKToggleable, frame: CGRect = CGRect(x: 0, y: 0, width: 440, height: 60)) {
        self.node = node
        super.init(frame: frame)
    }

    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func drawBypassButton(isBypassed isBypassed: Bool = false) {
        //// General Declarations
        let context = UIGraphicsGetCurrentContext()

        //// Color Declarations
        let red = UIColor(red: 1.000, green: 0.000, blue: 0.062, alpha: 1.000)
        let gray = UIColor(red: 0.835, green: 0.842, blue: 0.836, alpha: 1.000)
        let green = UIColor(red: 0.029, green: 1.000, blue: 0.000, alpha: 1.000)

        //// Variable Declarations
        let processingColor = isBypassed ? gray : green
        let bypassingCOlor = isBypassed ? red : gray
        let bypassedText = isBypassed ? "Bypassed" : "Bypass"
        let processingText = isBypassed ? "Process" : "Processing"

        //// bypassGroup
        //// bypassOuter Drawing
        bypassOuterPath = UIBezierPath(rect: CGRect(x: 0, y: 0, width: 220, height: 60))
        bypassingCOlor.setFill()
        bypassOuterPath.fill()


        //// bypassLabel Drawing
        let bypassLabelRect = CGRect(x: 0, y: 0, width: 220, height: 60)
        let bypassLabelStyle = NSMutableParagraphStyle()
        bypassLabelStyle.alignment = .Center

        let bypassLabelFontAttributes = [NSFontAttributeName: UIFont.boldSystemFontOfSize(24), NSForegroundColorAttributeName: UIColor.blackColor(), NSParagraphStyleAttributeName: bypassLabelStyle]

        let bypassLabelInset: CGRect = CGRectInset(bypassLabelRect, 10, 0)
        let bypassLabelTextHeight: CGFloat = NSString(string: bypassedText).boundingRectWithSize(CGSize(width: bypassLabelInset.width, height: CGFloat.infinity), options: NSStringDrawingOptions.UsesLineFragmentOrigin, attributes: bypassLabelFontAttributes, context: nil).size.height
        CGContextSaveGState(context)
        CGContextClipToRect(context, bypassLabelInset)
        NSString(string: bypassedText).drawInRect(CGRect(x: bypassLabelInset.minX, y: bypassLabelInset.minY + (bypassLabelInset.height - bypassLabelTextHeight) / 2, width: bypassLabelInset.width, height: bypassLabelTextHeight), withAttributes: bypassLabelFontAttributes)
        CGContextRestoreGState(context)




        //// processGroup
        //// processOuter Drawing
        processOuterPath = UIBezierPath(rect: CGRect(x: 220, y: 0, width: 220, height: 60))
        processingColor.setFill()
        processOuterPath.fill()


        //// processLabel Drawing
        let processLabelRect = CGRect(x: 220, y: 0, width: 220, height: 60)
        let processLabelStyle = NSMutableParagraphStyle()
        processLabelStyle.alignment = .Center

        let processLabelFontAttributes = [NSFontAttributeName: UIFont.boldSystemFontOfSize(24), NSForegroundColorAttributeName: UIColor.blackColor(), NSParagraphStyleAttributeName: processLabelStyle]

        let processLabelInset: CGRect = CGRectInset(processLabelRect, 10, 0)
        let processLabelTextHeight: CGFloat = NSString(string: processingText).boundingRectWithSize(CGSize(width: processLabelInset.width, height: CGFloat.infinity), options: NSStringDrawingOptions.UsesLineFragmentOrigin, attributes: processLabelFontAttributes, context: nil).size.height
        CGContextSaveGState(context)
        CGContextClipToRect(context, processLabelInset)
        NSString(string: processingText).drawInRect(CGRect(x: processLabelInset.minX, y: processLabelInset.minY + (processLabelInset.height - processLabelTextHeight) / 2, width: processLabelInset.width, height: processLabelTextHeight), withAttributes: processLabelFontAttributes)
        CGContextRestoreGState(context)
    }

    override public func drawRect(rect: CGRect) {
        drawBypassButton(isBypassed: node.isBypassed)
    }
}