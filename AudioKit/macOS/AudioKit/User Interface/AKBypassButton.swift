//
//  AKBypassButton.swift
//  AudioKit for macOS
//
//  Created by Aurelius Prochazka on 7/30/16.
//  Copyright © 2017 Aurelius Prochazka. All rights reserved.
//

public class AKBypassButton: NSView {

    var node: AKToggleable
    var bypassOuterPath = NSBezierPath()
    var processOuterPath = NSBezierPath()

    override public func mouseDown(with theEvent: NSEvent) {

        let touchLocation = convert(theEvent.locationInWindow, from: nil)
        if bypassOuterPath.contains(touchLocation) && node.isPlaying {
            node.bypass()
        }
        if processOuterPath.contains(touchLocation) && node.isBypassed {
            node.start()
        }
        needsDisplay = true
    }

    public init(node: AKToggleable, frame: CGRect = CGRect(x: 0, y: 0, width: 440, height: 60)) {
        self.node = node
        super.init(frame: frame)
    }

    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func drawBypassButton(isBypassed: Bool = false) {
        //// General Declarations
        let _ = unsafeBitCast(NSGraphicsContext.current()?.graphicsPort, to: CGContext.self)

        //// Color Declarations
        let red = #colorLiteral(red: 1, green: 0, blue: 0.062, alpha: 1)
        let gray = #colorLiteral(red: 0.835, green: 0.842, blue: 0.836, alpha: 1)
        let green = #colorLiteral(red: 0.029, green: 1, blue: 0, alpha: 1)

        //// Variable Declarations
        let processingColor: NSColor = isBypassed ? gray : green
        let bypassingCOlor: NSColor = isBypassed ? red : gray
        let bypassedText: String = isBypassed ? "Off / Bypassed" : "Stop / Bypass"
        let processingText: String = isBypassed ? "Play / Start" : "Playing"

        //// bypassGroup
        //// bypassOuter Drawing
        bypassOuterPath = NSBezierPath(rect: NSRect(x: 0, y: 0, width: 220, height: 60))
        bypassingCOlor.setFill()
        bypassOuterPath.fill()

        //// bypassLabel Drawing
        let bypassLabelRect = NSRect(x: 0, y: 0, width: 220, height: 60)
        let bypassLabelStyle = NSMutableParagraphStyle()
        bypassLabelStyle.alignment = .center

        let bypassLabelFontAttributes = [NSFontAttributeName: NSFont(name: "HelveticaNeue", size: 24)!,
                                         NSForegroundColorAttributeName: NSColor.black,
                                         NSParagraphStyleAttributeName: bypassLabelStyle]

        let bypassLabelInset: CGRect = bypassLabelRect.insetBy(dx: 10, dy: 0)
        let bypassLabelTextHeight: CGFloat = NSString(string: bypassedText).boundingRect(
            with: NSSize(width: bypassLabelInset.width, height: CGFloat.infinity),
            options: NSStringDrawingOptions.usesLineFragmentOrigin,
            attributes: bypassLabelFontAttributes).size.height
        let bypassLabelTextRect: NSRect = NSRect(
            x: bypassLabelInset.minX,
            y: bypassLabelInset.minY + (bypassLabelInset.height - bypassLabelTextHeight) / 2,
            width: bypassLabelInset.width,
            height: bypassLabelTextHeight)
        NSGraphicsContext.saveGraphicsState()
        NSRectClip(bypassLabelInset)
        NSString(string: bypassedText).draw(in: bypassLabelTextRect.offsetBy(dx: 0, dy: 0),
                                            withAttributes: bypassLabelFontAttributes)
        NSGraphicsContext.restoreGraphicsState()

        //// processGroup
        //// processOuter Drawing
        processOuterPath = NSBezierPath(rect: NSRect(x: 220, y: 0, width: 220, height: 60))
        processingColor.setFill()
        processOuterPath.fill()

        //// processLabel Drawing
        let processLabelRect = NSRect(x: 220, y: 0, width: 220, height: 60)
        let processLabelStyle = NSMutableParagraphStyle()
        processLabelStyle.alignment = .center

        let processLabelFontAttributes = [NSFontAttributeName: NSFont(name: "HelveticaNeue", size: 24)!,
                                          NSForegroundColorAttributeName: NSColor.black,
                                          NSParagraphStyleAttributeName: processLabelStyle]

        let processLabelInset: CGRect = processLabelRect.insetBy(dx: 10, dy: 0)
        let processLabelTextHeight: CGFloat = NSString(string: processingText).boundingRect(
            with: NSSize(width: processLabelInset.width, height: CGFloat.infinity),
            options: NSStringDrawingOptions.usesLineFragmentOrigin,
            attributes: processLabelFontAttributes).size.height
        let processLabelTextRect: NSRect = NSRect(
            x: processLabelInset.minX,
            y: processLabelInset.minY + (processLabelInset.height - processLabelTextHeight) / 2,
            width: processLabelInset.width,
            height: processLabelTextHeight)
        NSGraphicsContext.saveGraphicsState()
        NSRectClip(processLabelInset)
        NSString(string: processingText).draw(in: processLabelTextRect.offsetBy(dx: 0, dy: 0),
                                              withAttributes: processLabelFontAttributes)
        NSGraphicsContext.restoreGraphicsState()
    }

    override public func draw(_ rect: CGRect) {
        drawBypassButton(isBypassed: node.isBypassed)
    }
}
