//
//  AKBypassButton.swift
//  AudioKit for macOS
//
//  Created by Aurelius Prochazka on 7/30/16.
//  Copyright © 2016 AudioKit. All rights reserved.
//

public class AKBypassButton: NSView {
    
    var node: AKPlayable
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
    
    public init(node: AKPlayable, frame: CGRect = CGRect(x: 0, y: 0, width: 440, height: 60)) {
        self.node = node
        super.init(frame: frame)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func drawBypassButton(isBypassed: Bool = false) {
        //// General Declarations
        let _ = unsafeBitCast(NSGraphicsContext.current()!.graphicsPort, to: CGContext.self)
        
        //// Color Declarations
        let red = NSColor(calibratedRed: 1, green: 0, blue: 0.062, alpha: 1)
        let gray = NSColor(calibratedRed: 0.835, green: 0.842, blue: 0.836, alpha: 1)
        let green = NSColor(calibratedRed: 0.029, green: 1, blue: 0, alpha: 1)
        
        //// Variable Declarations
        let processingColor: NSColor = isBypassed ? gray : green
        let bypassingCOlor: NSColor = isBypassed ? red : gray
        let bypassedText: String = isBypassed ? "Off / Bypassed" : "Stop / Bypass"
        let processingText: String = isBypassed ? "Play / Start" : "Playing"
        
        //// bypassGroup
        //// bypassOuter Drawing
        bypassOuterPath = NSBezierPath(rect: NSMakeRect(0, 0, 220, 60))
        bypassingCOlor.setFill()
        bypassOuterPath.fill()
        
        
        //// bypassLabel Drawing
        let bypassLabelRect = NSMakeRect(0, 0, 220, 60)
        let bypassLabelStyle = NSMutableParagraphStyle()
        bypassLabelStyle.alignment = .center
        
        let bypassLabelFontAttributes = [NSFontAttributeName: NSFont(name: "HelveticaNeue", size: 24)!, NSForegroundColorAttributeName: NSColor.black, NSParagraphStyleAttributeName: bypassLabelStyle]
        
        let bypassLabelInset: CGRect = NSInsetRect(bypassLabelRect, 10, 0)
        let bypassLabelTextHeight: CGFloat = NSString(string: bypassedText).boundingRect(with: NSMakeSize(bypassLabelInset.width, CGFloat.infinity), options: NSStringDrawingOptions.usesLineFragmentOrigin, attributes: bypassLabelFontAttributes).size.height
        let bypassLabelTextRect: NSRect = NSMakeRect(bypassLabelInset.minX, bypassLabelInset.minY + (bypassLabelInset.height - bypassLabelTextHeight) / 2, bypassLabelInset.width, bypassLabelTextHeight)
        NSGraphicsContext.saveGraphicsState()
        NSRectClip(bypassLabelInset)
        NSString(string: bypassedText).draw(in: NSOffsetRect(bypassLabelTextRect, 0, 0), withAttributes: bypassLabelFontAttributes)
        NSGraphicsContext.restoreGraphicsState()
        
        
        //// processGroup
        //// processOuter Drawing
        processOuterPath = NSBezierPath(rect: NSMakeRect(220, 0, 220, 60))
        processingColor.setFill()
        processOuterPath.fill()
        
        
        //// processLabel Drawing
        let processLabelRect = NSMakeRect(220, 0, 220, 60)
        let processLabelStyle = NSMutableParagraphStyle()
        processLabelStyle.alignment = .center
        
        let processLabelFontAttributes = [NSFontAttributeName: NSFont(name: "HelveticaNeue", size: 24)!, NSForegroundColorAttributeName: NSColor.black, NSParagraphStyleAttributeName: processLabelStyle]
        
        let processLabelInset: CGRect = NSInsetRect(processLabelRect, 10, 0)
        let processLabelTextHeight: CGFloat = NSString(string: processingText).boundingRect(with: NSMakeSize(processLabelInset.width, CGFloat.infinity), options: NSStringDrawingOptions.usesLineFragmentOrigin, attributes: processLabelFontAttributes).size.height
        let processLabelTextRect: NSRect = NSMakeRect(processLabelInset.minX, processLabelInset.minY + (processLabelInset.height - processLabelTextHeight) / 2, processLabelInset.width, processLabelTextHeight)
        NSGraphicsContext.saveGraphicsState()
        NSRectClip(processLabelInset)
        NSString(string: processingText).draw(in: NSOffsetRect(processLabelTextRect, 0, 0), withAttributes: processLabelFontAttributes)
        NSGraphicsContext.restoreGraphicsState()
    }
    
    override public func draw(_ rect: CGRect) {
        drawBypassButton(isBypassed: node.isBypassed)
    }
}
