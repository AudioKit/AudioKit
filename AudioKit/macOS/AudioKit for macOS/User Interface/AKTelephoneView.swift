//
//  AKTelephoneView.swift
//  AudioKit for macOS
//
//  Created by Aurelius Prochazka on 7/31/16.
//  Copyright © 2016 AudioKit. All rights reserved.
//


/// This is primarily for the telephone page in the Synthesis playground
public class AKTelephoneView: NSView {
    
    var key1Rect = CGRect.zero
    var key2Rect = CGRect.zero
    var key3Rect = CGRect.zero
    var key4Rect = CGRect.zero
    var key5Rect = CGRect.zero
    var key6Rect = CGRect.zero
    var key7Rect = CGRect.zero
    var key8Rect = CGRect.zero
    var key9Rect = CGRect.zero
    var key0Rect = CGRect.zero
    var keyStarRect = CGRect.zero
    var keyHashRect = CGRect.zero
    var callCirclePath = NSBezierPath()
    var busyCirclePath = NSBezierPath()
    
    var last10Presses = Array<String>(count: 10, repeatedValue: "")
    var currentKey = ""
    var callback: (String, String) -> ()
    
    override public func mouseDown(theEvent: NSEvent) {
        let touchLocation = convertPoint(theEvent.locationInWindow, fromView: nil)
        if key1Rect.contains(touchLocation) { currentKey = "1" }
        if key2Rect.contains(touchLocation) { currentKey = "2" }
        if key3Rect.contains(touchLocation) { currentKey = "3" }
        if key4Rect.contains(touchLocation) { currentKey = "4" }
        if key5Rect.contains(touchLocation) { currentKey = "5" }
        if key6Rect.contains(touchLocation) { currentKey = "6" }
        if key7Rect.contains(touchLocation) { currentKey = "7" }
        if key8Rect.contains(touchLocation) { currentKey = "8" }
        if key9Rect.contains(touchLocation) { currentKey = "9" }
        if key0Rect.contains(touchLocation) { currentKey = "0" }
        if keyStarRect.contains(touchLocation) { currentKey = "*" }
        if keyHashRect.contains(touchLocation) { currentKey = "#" }
        if callCirclePath.containsPoint(touchLocation) { currentKey = "CALL" }
        if busyCirclePath.containsPoint(touchLocation) { currentKey = "BUSY" }
        if currentKey != "" {
            callback(currentKey, "down")
            if currentKey.characters.count == 1 {
                last10Presses.removeFirst()
                last10Presses.append(currentKey)
            }
            
        }
        needsDisplay = true
        
    }
    
    override public func mouseUp(theEvent: NSEvent) {

        if currentKey != "" {
            callback(currentKey, "up")
            currentKey = ""
        }
        needsDisplay = true
    }
    
    public init(frame: CGRect = CGRect(x: 0, y: 0, width: 440, height: 782), callback: (String, String) -> ()) {
        self.callback = callback
        super.init(frame: frame)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override public func drawRect(rect: CGRect) {
        //// General Declarations
        let context = NSGraphicsContext.currentContext()!.CGContext
        
        //// Color Declarations
        let color = NSColor(calibratedRed: 0.306, green: 0.851, blue: 0.392, alpha: 1)
        let color2 = NSColor(calibratedRed: 1, green: 0.151, blue: 0, alpha: 1)
        let unpressedKeyColor = NSColor(calibratedRed: 0.937, green: 0.941, blue: 0.949, alpha: 1)
        
        //// Background Drawing
        let backgroundPath = NSBezierPath(rect: NSMakeRect(1, 0, 440, 782))
        unpressedKeyColor.setFill()
        backgroundPath.fill()
        
        
        //// key 1 Drawing
        key1Rect = NSMakeRect(70, 494, 82, 82)
        NSGraphicsContext.saveGraphicsState()
        NSRectClip(key1Rect)
        CGContextTranslateCTM(context, key1Rect.origin.x, key1Rect.origin.y)
        CGContextScaleCTM(context, key1Rect.size.width / 100, key1Rect.size.height / 100)
        
        AKTelephoneView.drawKey(text: "\n", numeral: "1", isPressed: currentKey == "1")
        NSGraphicsContext.restoreGraphicsState()
        
        
        //// key 2 Drawing
        key2Rect = NSMakeRect(179, 495, 82, 82)
        NSGraphicsContext.saveGraphicsState()
        NSRectClip(key2Rect)
        CGContextTranslateCTM(context, key2Rect.origin.x, key2Rect.origin.y)
        CGContextScaleCTM(context, key2Rect.size.width / 100, key2Rect.size.height / 100)
        
        AKTelephoneView.drawKey(text: "A B C", numeral: "2", isPressed: currentKey == "2")
        NSGraphicsContext.restoreGraphicsState()
        
        
        //// key 3 Drawing
        key3Rect = NSMakeRect(288, 495, 82, 82)
        NSGraphicsContext.saveGraphicsState()
        NSRectClip(key3Rect)
        CGContextTranslateCTM(context, key3Rect.origin.x, key3Rect.origin.y)
        CGContextScaleCTM(context, key3Rect.size.width / 100, key3Rect.size.height / 100)
        
        AKTelephoneView.drawKey(text: "D E F", numeral: "3", isPressed: currentKey == "3")
        NSGraphicsContext.restoreGraphicsState()
        
        
        //// key 4 Drawing
        key4Rect = NSMakeRect(70, 398, 82, 82)
        NSGraphicsContext.saveGraphicsState()
        NSRectClip(key4Rect)
        CGContextTranslateCTM(context, key4Rect.origin.x, key4Rect.origin.y)
        CGContextScaleCTM(context, key4Rect.size.width / 100, key4Rect.size.height / 100)
        
        AKTelephoneView.drawKey(text: "G H I", numeral: "4", isPressed: currentKey == "4")
        NSGraphicsContext.restoreGraphicsState()
        
        
        //// key 5 Drawing
        key5Rect = NSMakeRect(179, 398, 82, 82)
        NSGraphicsContext.saveGraphicsState()
        NSRectClip(key5Rect)
        CGContextTranslateCTM(context, key5Rect.origin.x, key5Rect.origin.y)
        CGContextScaleCTM(context, key5Rect.size.width / 100, key5Rect.size.height / 100)
        
        AKTelephoneView.drawKey(text: "J K L", numeral: "5", isPressed: currentKey == "5")
        NSGraphicsContext.restoreGraphicsState()
        
        
        //// key 6 Drawing
        key6Rect = NSMakeRect(288, 398, 82, 82)
        NSGraphicsContext.saveGraphicsState()
        NSRectClip(key6Rect)
        CGContextTranslateCTM(context, key6Rect.origin.x, key6Rect.origin.y)
        CGContextScaleCTM(context, key6Rect.size.width / 100, key6Rect.size.height / 100)
        
        AKTelephoneView.drawKey(text: "M N O", numeral: "6", isPressed: currentKey == "6")
        NSGraphicsContext.restoreGraphicsState()
        
        
        //// key 7 Drawing
        key7Rect = NSMakeRect(70, 303, 82, 82)
        NSGraphicsContext.saveGraphicsState()
        NSRectClip(key7Rect)
        CGContextTranslateCTM(context, key7Rect.origin.x, key7Rect.origin.y)
        CGContextScaleCTM(context, key7Rect.size.width / 100, key7Rect.size.height / 100)
        
        AKTelephoneView.drawKey(text: "P Q R S", numeral: "7", isPressed: currentKey == "7")
        NSGraphicsContext.restoreGraphicsState()
        
        
        //// key 8 Drawing
        key8Rect = NSMakeRect(179, 303, 82, 82)
        NSGraphicsContext.saveGraphicsState()
        NSRectClip(key8Rect)
        CGContextTranslateCTM(context, key8Rect.origin.x, key8Rect.origin.y)
        CGContextScaleCTM(context, key8Rect.size.width / 100, key8Rect.size.height / 100)
        
        AKTelephoneView.drawKey(text: "T U V", numeral: "8", isPressed: currentKey == "8")
        NSGraphicsContext.restoreGraphicsState()
        
        
        //// key 9 Drawing
        key9Rect = NSMakeRect(288, 303, 82, 82)
        NSGraphicsContext.saveGraphicsState()
        NSRectClip(key9Rect)
        CGContextTranslateCTM(context, key9Rect.origin.x, key9Rect.origin.y)
        CGContextScaleCTM(context, key9Rect.size.width / 100, key9Rect.size.height / 100)
        
        AKTelephoneView.drawKey(text: "W X Y Z", numeral: "9", isPressed: currentKey == "9")
        NSGraphicsContext.restoreGraphicsState()
        
        
        //// key 0 Drawing
        key0Rect = NSMakeRect(179, 206, 82, 82)
        NSGraphicsContext.saveGraphicsState()
        NSRectClip(key0Rect)
        CGContextTranslateCTM(context, key0Rect.origin.x, key0Rect.origin.y)
        CGContextScaleCTM(context, key0Rect.size.width / 100, key0Rect.size.height / 100)
        
        AKTelephoneView.drawKey(text: "+", numeral: "0", isPressed: currentKey == "0")
        NSGraphicsContext.restoreGraphicsState()
        
        
        //// keyStar Drawing
        keyStarRect = NSMakeRect(70, 206, 82, 82)
        NSGraphicsContext.saveGraphicsState()
        NSRectClip(keyStarRect)
        CGContextTranslateCTM(context, keyStarRect.origin.x, keyStarRect.origin.y)
        CGContextScaleCTM(context, keyStarRect.size.width / 100, keyStarRect.size.height / 100)
        
        AKTelephoneView.drawCenteredKey(numeral: "*", isPressed: currentKey == "*")
        NSGraphicsContext.restoreGraphicsState()
        
        
        //// keyHash Drawing
        keyHashRect = NSMakeRect(288, 206, 82, 82)
        NSGraphicsContext.saveGraphicsState()
        NSRectClip(keyHashRect)
        CGContextTranslateCTM(context, keyHashRect.origin.x, keyHashRect.origin.y)
        CGContextScaleCTM(context, keyHashRect.size.width / 100, keyHashRect.size.height / 100)
        
        AKTelephoneView.drawCenteredKey(numeral: "#", isPressed: currentKey == "#")
        NSGraphicsContext.restoreGraphicsState()
        
        
        //// CallButton
        //// callCircle Drawing
        callCirclePath = NSBezierPath(ovalInRect: NSMakeRect(181, 100, 79, 79))
        color.setFill()
        callCirclePath.fill()
        
        
        //// telephoneSilhouette Drawing
        let telephoneSilhouettePath = NSBezierPath()
        telephoneSilhouettePath.moveToPoint(NSMakePoint(214.75, 131.6))
        telephoneSilhouettePath.curveToPoint(NSMakePoint(228.04, 122.98), controlPoint1: NSMakePoint(220.59, 125.68), controlPoint2: NSMakePoint(228.04, 122.98))
        telephoneSilhouettePath.curveToPoint(NSMakePoint(234.15, 122.98), controlPoint1: NSMakePoint(228.04, 122.98), controlPoint2: NSMakePoint(231.54, 121.9))
        telephoneSilhouettePath.curveToPoint(NSMakePoint(237.74, 128.01), controlPoint1: NSMakePoint(236.75, 124.06), controlPoint2: NSMakePoint(237.74, 128.01))
        telephoneSilhouettePath.lineToPoint(NSMakePoint(229.12, 134.11))
        telephoneSilhouettePath.curveToPoint(NSMakePoint(222.65, 132.68), controlPoint1: NSMakePoint(229.12, 134.11), controlPoint2: NSMakePoint(225.17, 130.88))
        telephoneSilhouettePath.curveToPoint(NSMakePoint(213.68, 141.3), controlPoint1: NSMakePoint(220.14, 134.47), controlPoint2: NSMakePoint(214.75, 139.14))
        telephoneSilhouettePath.curveToPoint(NSMakePoint(215.83, 146.68), controlPoint1: NSMakePoint(212.6, 143.45), controlPoint2: NSMakePoint(215.83, 146.68))
        telephoneSilhouettePath.lineToPoint(NSMakePoint(210.8, 155.66))
        telephoneSilhouettePath.curveToPoint(NSMakePoint(207.57, 154.58), controlPoint1: NSMakePoint(210.8, 155.66), controlPoint2: NSMakePoint(209.1, 155.57))
        telephoneSilhouettePath.curveToPoint(NSMakePoint(204.7, 151.71), controlPoint1: NSMakePoint(206.05, 153.59), controlPoint2: NSMakePoint(204.7, 151.71))
        telephoneSilhouettePath.curveToPoint(NSMakePoint(205.78, 144.89), controlPoint1: NSMakePoint(204.7, 151.71), controlPoint2: NSMakePoint(204.34, 147.76))
        telephoneSilhouettePath.curveToPoint(NSMakePoint(214.75, 131.6), controlPoint1: NSMakePoint(207.21, 142.01), controlPoint2: NSMakePoint(208.92, 137.53))
        telephoneSilhouettePath.closePath()
        NSColor.whiteColor().setFill()
        telephoneSilhouettePath.fill()
        
        
        
        
        //// BusyButton
        //// busyCircle Drawing
        busyCirclePath = NSBezierPath(ovalInRect: NSMakeRect(73, 100, 79, 79))
        color2.setFill()
        busyCirclePath.fill()
        
        
        //// busyText Drawing
        let busyTextRect = NSMakeRect(73, 100, 79, 79)
        let busyTextTextContent = NSString(string: "BUSY")
        let busyTextStyle = NSMutableParagraphStyle()
        busyTextStyle.alignment = .Center
        
        let busyTextFontAttributes = [NSFontAttributeName: NSFont(name: "HelveticaNeue", size: 17)!, NSForegroundColorAttributeName: NSColor.whiteColor(), NSParagraphStyleAttributeName: busyTextStyle]
        
        let busyTextTextHeight: CGFloat = busyTextTextContent.boundingRectWithSize(NSMakeSize(busyTextRect.width, CGFloat.infinity), options: NSStringDrawingOptions.UsesLineFragmentOrigin, attributes: busyTextFontAttributes).size.height
        let busyTextTextRect: NSRect = NSMakeRect(busyTextRect.minX, busyTextRect.minY + (busyTextRect.height - busyTextTextHeight) / 2, busyTextRect.width, busyTextTextHeight)
        NSGraphicsContext.saveGraphicsState()
        NSRectClip(busyTextRect)
        busyTextTextContent.drawInRect(NSOffsetRect(busyTextTextRect, 0, 5), withAttributes: busyTextFontAttributes)
        NSGraphicsContext.restoreGraphicsState()
        
        
        
        
        //// Readout Drawing
        let readoutRect = NSMakeRect(0, 658, 440, 72)
        let readoutTextContent = NSString(string: last10Presses.joinWithSeparator(""))
        let readoutStyle = NSMutableParagraphStyle()
        readoutStyle.alignment = .Center
        
        let readoutFontAttributes = [NSFontAttributeName: NSFont(name: "HelveticaNeue", size: 48)!, NSForegroundColorAttributeName: NSColor.blackColor(), NSParagraphStyleAttributeName: readoutStyle]
        
        let readoutTextHeight: CGFloat = readoutTextContent.boundingRectWithSize(NSMakeSize(readoutRect.width, CGFloat.infinity), options: NSStringDrawingOptions.UsesLineFragmentOrigin, attributes: readoutFontAttributes).size.height
        let readoutTextRect: NSRect = NSMakeRect(readoutRect.minX, readoutRect.minY + (readoutRect.height - readoutTextHeight) / 2, readoutRect.width, readoutTextHeight)
        NSGraphicsContext.saveGraphicsState()
        NSRectClip(readoutRect)
        readoutTextContent.drawInRect(NSOffsetRect(readoutTextRect, 0, 0), withAttributes: readoutFontAttributes)
        NSGraphicsContext.restoreGraphicsState()
    }
    
    public class func drawKey(text text: String = "A B C", numeral: String = "1", isPressed: Bool = true) {
        //// General Declarations
        let context = NSGraphicsContext.currentContext()!.CGContext
        
        //// Color Declarations
        let pressedKeyColor = NSColor(calibratedRed: 0.655, green: 0.745, blue: 0.804, alpha: 1)
        let unpressedKeyColor = NSColor(calibratedRed: 0.937, green: 0.941, blue: 0.949, alpha: 1)
        let unpressedTextColor = NSColor(calibratedRed: 0, green: 0, blue: 0, alpha: 1)
        let pressedTextColor = NSColor(calibratedRed: 1, green: 0.992, blue: 0.988, alpha: 1)
        
        //// Variable Declarations
        let keyColor: NSColor = isPressed ? pressedKeyColor : unpressedKeyColor
        let textColor: NSColor = isPressed ? pressedTextColor : unpressedTextColor
        
        //// Oval Drawing
        let ovalPath = NSBezierPath(ovalInRect: NSMakeRect(2, 2, 96, 96))
        keyColor.setFill()
        ovalPath.fill()
        NSColor.lightGrayColor().setStroke()
        ovalPath.lineWidth = 2.5
        ovalPath.stroke()
        
        
        //// Letters Drawing
        let lettersRect = NSMakeRect(0, 17, 100, 23)
        let lettersStyle = NSMutableParagraphStyle()
        lettersStyle.alignment = .Center
        
        let lettersFontAttributes = [NSFontAttributeName: NSFont(name: "HelveticaNeue", size: 11)!, NSForegroundColorAttributeName: textColor, NSParagraphStyleAttributeName: lettersStyle]
        
        let lettersTextHeight: CGFloat = NSString(string: text).boundingRectWithSize(NSMakeSize(lettersRect.width, CGFloat.infinity), options: NSStringDrawingOptions.UsesLineFragmentOrigin, attributes: lettersFontAttributes).size.height
        let lettersTextRect: NSRect = NSMakeRect(lettersRect.minX, lettersRect.minY + (lettersRect.height - lettersTextHeight) / 2, lettersRect.width, lettersTextHeight)
        NSGraphicsContext.saveGraphicsState()
        NSRectClip(lettersRect)
        NSString(string: text).drawInRect(NSOffsetRect(lettersTextRect, 0, 2), withAttributes: lettersFontAttributes)
        NSGraphicsContext.restoreGraphicsState()
        
        
        //// Number Drawing
        let numberRect = NSMakeRect(27, 36, 45, 46)
        let numberStyle = NSMutableParagraphStyle()
        numberStyle.alignment = .Center
        
        let numberFontAttributes = [NSFontAttributeName: NSFont(name: "HelveticaNeue", size: 48)!, NSForegroundColorAttributeName: textColor, NSParagraphStyleAttributeName: numberStyle]
        
        let numberTextHeight: CGFloat = NSString(string: numeral).boundingRectWithSize(NSMakeSize(numberRect.width, CGFloat.infinity), options: NSStringDrawingOptions.UsesLineFragmentOrigin, attributes: numberFontAttributes).size.height
        let numberTextRect: NSRect = NSMakeRect(numberRect.minX, numberRect.minY + (numberRect.height - numberTextHeight) / 2, numberRect.width, numberTextHeight)
        NSGraphicsContext.saveGraphicsState()
        NSRectClip(numberRect)
        NSString(string: numeral).drawInRect(NSOffsetRect(numberTextRect, 0, 0), withAttributes: numberFontAttributes)
        NSGraphicsContext.restoreGraphicsState()
    }
    
    public class func drawCenteredKey(numeral numeral: String = "1", isPressed: Bool = true) {
        //// General Declarations
        let context = NSGraphicsContext.currentContext()!.CGContext
        
        //// Color Declarations
        let pressedKeyColor = NSColor(calibratedRed: 0.655, green: 0.745, blue: 0.804, alpha: 1)
        let unpressedKeyColor = NSColor(calibratedRed: 0.937, green: 0.941, blue: 0.949, alpha: 1)
        let unpressedTextColor = NSColor(calibratedRed: 0, green: 0, blue: 0, alpha: 1)
        let pressedTextColor = NSColor(calibratedRed: 1, green: 0.992, blue: 0.988, alpha: 1)
        
        //// Variable Declarations
        let keyColor: NSColor = isPressed ? pressedKeyColor : unpressedKeyColor
        let textColor: NSColor = isPressed ? pressedTextColor : unpressedTextColor
        
        //// Oval Drawing
        let ovalPath = NSBezierPath(ovalInRect: NSMakeRect(2, 2, 96, 96))
        keyColor.setFill()
        ovalPath.fill()
        NSColor.lightGrayColor().setStroke()
        ovalPath.lineWidth = 2.5
        ovalPath.stroke()
        
        
        //// Number Drawing
        let numberRect = NSMakeRect(27, 27, 45, 46)
        let numberStyle = NSMutableParagraphStyle()
        numberStyle.alignment = .Center
        
        let numberFontAttributes = [NSFontAttributeName: NSFont(name: "HelveticaNeue", size: 48)!, NSForegroundColorAttributeName: textColor, NSParagraphStyleAttributeName: numberStyle]
        
        let numberTextHeight: CGFloat = NSString(string: numeral).boundingRectWithSize(NSMakeSize(numberRect.width, CGFloat.infinity), options: NSStringDrawingOptions.UsesLineFragmentOrigin, attributes: numberFontAttributes).size.height
        let numberTextRect: NSRect = NSMakeRect(numberRect.minX, numberRect.minY + (numberRect.height - numberTextHeight) / 2, numberRect.width, numberTextHeight)
        NSGraphicsContext.saveGraphicsState()
        NSRectClip(numberRect)
        NSString(string: numeral).drawInRect(NSOffsetRect(numberTextRect, 0, 0), withAttributes: numberFontAttributes)
        NSGraphicsContext.restoreGraphicsState()
    }
}
