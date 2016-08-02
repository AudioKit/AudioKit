//
//  AKPresetLoaderView.swift
//  AudioKit for macOS
//
//  Created by Aurelius Prochazka on 7/30/16.
//  Copyright © 2016 AudioKit. All rights reserved.
//

public class AKPresetLoaderView: NSView {
    
    var player: AKAudioPlayer?
    var presetOuterPath = NSBezierPath()
    var upOuterPath     = NSBezierPath()
    var downOuterPath   = NSBezierPath()
    
    var currentIndex = 0
    var presets = [String]()
    var callback: String -> ()
    var isPresetLoaded = false
    
    override public func mouseDown(theEvent: NSEvent) {
        isPresetLoaded = false
        let touchLocation = convertPoint(theEvent.locationInWindow, fromView: nil)
        if upOuterPath.containsPoint(touchLocation) {
            currentIndex -= 1
            isPresetLoaded = true
        }
        if downOuterPath.containsPoint(touchLocation) {
            currentIndex += 1
            isPresetLoaded = true
        }
        if currentIndex < 0 { currentIndex = presets.count - 1 }
        if currentIndex >= presets.count { currentIndex = 0 }
        
        if isPresetLoaded {
            callback(presets[currentIndex])
            needsDisplay = true
        }
    }

    public init(presets: [String], frame: CGRect = CGRect(x: 0, y: 0, width: 440, height: 60), callback: String -> ()) {
        self.callback = callback
        self.presets = presets
        super.init(frame: frame)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func drawPresetLoader(presetName presetName: String = "None", isPresetLoaded: Bool = false) {
        //// General Declarations
        let _ = unsafeBitCast(NSGraphicsContext.currentContext()!.graphicsPort, CGContext.self)
        
        //// Color Declarations
        let red = NSColor(calibratedRed: 1, green: 0, blue: 0.062, alpha: 1)
        let gray = NSColor(calibratedRed: 0.835, green: 0.842, blue: 0.836, alpha: 0.925)
        let green = NSColor(calibratedRed: 0.029, green: 1, blue: 0, alpha: 1)
        let dark = NSColor(calibratedRed: 0, green: 0, blue: 0, alpha: 1)
        
        //// Variable Declarations
        let expression: NSColor = isPresetLoaded ? green : red
        
        //// background Drawing
        let backgroundPath = NSBezierPath(rect: NSMakeRect(0, 0, 440, 60))
        gray.setFill()
        backgroundPath.fill()
        
        
        //// presetButton
        //// presetOuter Drawing
        presetOuterPath = NSBezierPath(rect: NSMakeRect(0, 0, 95, 60))
        expression.setFill()
        presetOuterPath.fill()
        
        
        //// presetLabel Drawing
        let presetLabelRect = NSMakeRect(0, 0, 95, 60)
        let presetLabelTextContent = NSString(string: "Preset")
        let presetLabelStyle = NSMutableParagraphStyle()
        presetLabelStyle.alignment = .Left
        
        let presetLabelFontAttributes = [NSFontAttributeName: NSFont(name: "HelveticaNeue", size: 24)!, NSForegroundColorAttributeName: NSColor.blackColor(), NSParagraphStyleAttributeName: presetLabelStyle]
        
        let presetLabelInset: CGRect = NSInsetRect(presetLabelRect, 10, 0)
        let presetLabelTextHeight: CGFloat = presetLabelTextContent.boundingRectWithSize(NSMakeSize(presetLabelInset.width, CGFloat.infinity), options: NSStringDrawingOptions.UsesLineFragmentOrigin, attributes: presetLabelFontAttributes).size.height
        let presetLabelTextRect: NSRect = NSMakeRect(presetLabelInset.minX, presetLabelInset.minY + (presetLabelInset.height - presetLabelTextHeight) / 2, presetLabelInset.width, presetLabelTextHeight)
        NSGraphicsContext.saveGraphicsState()
        NSRectClip(presetLabelInset)
        presetLabelTextContent.drawInRect(NSOffsetRect(presetLabelTextRect, 0, 0), withAttributes: presetLabelFontAttributes)
        NSGraphicsContext.restoreGraphicsState()
        
        
        
        
        //// upButton
        //// upOuter Drawing
        upOuterPath = NSBezierPath(rect: NSMakeRect(381, 30, 59, 30))
        gray.setFill()
        upOuterPath.fill()
        
        
        //// upInner Drawing
        let upInnerPath = NSBezierPath()
        upInnerPath.moveToPoint(NSMakePoint(395.75, 37.5))
        upInnerPath.lineToPoint(NSMakePoint(425.25, 37.5))
        upInnerPath.lineToPoint(NSMakePoint(410.5, 52.5))
        upInnerPath.lineToPoint(NSMakePoint(410.5, 52.5))
        upInnerPath.lineToPoint(NSMakePoint(395.75, 37.5))
        upInnerPath.closePath()
        dark.setFill()
        upInnerPath.fill()
        
        
        
        
        //// downButton
        //// downOuter Drawing
        downOuterPath = NSBezierPath(rect: NSMakeRect(381, 0, 59, 30))
        gray.setFill()
        downOuterPath.fill()
        
        
        //// downInner Drawing
        let downInnerPath = NSBezierPath()
        downInnerPath.moveToPoint(NSMakePoint(410.5, 7.5))
        downInnerPath.lineToPoint(NSMakePoint(410.5, 7.5))
        downInnerPath.lineToPoint(NSMakePoint(425.25, 22.5))
        downInnerPath.lineToPoint(NSMakePoint(395.75, 22.5))
        downInnerPath.lineToPoint(NSMakePoint(410.5, 7.5))
        downInnerPath.closePath()
        dark.setFill()
        downInnerPath.fill()
        
        
        
        
        //// nameLabel Drawing
        let nameLabelRect = NSMakeRect(95, 0, 345, 60)
        let nameLabelStyle = NSMutableParagraphStyle()
        nameLabelStyle.alignment = .Left
        
        let nameLabelFontAttributes = [NSFontAttributeName: NSFont(name: "HelveticaNeue", size: 24)!, NSForegroundColorAttributeName: NSColor.blackColor(), NSParagraphStyleAttributeName: nameLabelStyle]
        
        let nameLabelInset: CGRect = NSInsetRect(nameLabelRect, 10, 0)
        let nameLabelTextHeight: CGFloat = NSString(string: presetName).boundingRectWithSize(NSMakeSize(nameLabelInset.width, CGFloat.infinity), options: NSStringDrawingOptions.UsesLineFragmentOrigin, attributes: nameLabelFontAttributes).size.height
        let nameLabelTextRect: NSRect = NSMakeRect(nameLabelInset.minX, nameLabelInset.minY + (nameLabelInset.height - nameLabelTextHeight) / 2, nameLabelInset.width, nameLabelTextHeight)
        NSGraphicsContext.saveGraphicsState()
        NSRectClip(nameLabelInset)
        NSString(string: presetName).drawInRect(NSOffsetRect(nameLabelTextRect, 0, 0), withAttributes: nameLabelFontAttributes)
        NSGraphicsContext.restoreGraphicsState()
    }
    
    override public func drawRect(rect: CGRect) {
        let presetName = isPresetLoaded ? presets[currentIndex] : "None"
        drawPresetLoader(presetName: presetName, isPresetLoaded: isPresetLoaded)
    }
}
