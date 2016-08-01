//
//  AKTelephoneView.swift
//  AudioKit for iOS
//
//  Created by Aurelius Prochazka on 7/31/16.
//  Copyright © 2016 AudioKit. All rights reserved.
//

import Foundation


/// This is primarily for the telephone page in the Synthesis playground
public class AKTelephoneView: UIView {
    
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
    var callCirclePath = UIBezierPath()
    var busyCirclePath = UIBezierPath()
    
    var last10Presses = Array<String>(count: 10, repeatedValue: "")
    var currentKey = ""
    var callback: (String, String) -> ()
    
    override public func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        if let touch = touches.first {
            let touchLocation = touch.locationInView(self)
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
            setNeedsDisplay()
        }
    }
    
    override public func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        if currentKey != "" {
            callback(currentKey, "up")
            currentKey = ""
        }
        setNeedsDisplay()
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
        let context = UIGraphicsGetCurrentContext()

        //// Color Declarations
        let color = UIColor(red: 0.306, green: 0.851, blue: 0.392, alpha: 1.000)
        let color2 = UIColor(red: 1.000, green: 0.151, blue: 0.000, alpha: 1.000)
        let unpressedKeyColor = UIColor(red: 0.937, green: 0.941, blue: 0.949, alpha: 1.000)

        //// Background Drawing
        let backgroundPath = UIBezierPath(rect: CGRect(x: 1, y: 0, width: 440, height: 782))
        unpressedKeyColor.setFill()
        backgroundPath.fill()


        //// key 1 Drawing
        key1Rect = CGRect(x: 70, y: 206, width: 82, height: 82)
        CGContextSaveGState(context)
        UIRectClip(key1Rect)
        CGContextTranslateCTM(context, key1Rect.origin.x, key1Rect.origin.y)
        CGContextScaleCTM(context, key1Rect.size.width / 100, key1Rect.size.height / 100)

        AKTelephoneView.drawKey(text: "\n", numeral: "1", isPressed: currentKey == "1")
        CGContextRestoreGState(context)


        //// key 2 Drawing
        key2Rect = CGRect(x: 179, y: 205, width: 82, height: 82)
        CGContextSaveGState(context)
        UIRectClip(key2Rect)
        CGContextTranslateCTM(context, key2Rect.origin.x, key2Rect.origin.y)
        CGContextScaleCTM(context, key2Rect.size.width / 100, key2Rect.size.height / 100)

        AKTelephoneView.drawKey(text: "A B C", numeral: "2", isPressed: currentKey == "2")
        CGContextRestoreGState(context)


        //// key 3 Drawing
        key3Rect = CGRect(x: 288, y: 205, width: 82, height: 82)
        CGContextSaveGState(context)
        UIRectClip(key3Rect)
        CGContextTranslateCTM(context, key3Rect.origin.x, key3Rect.origin.y)
        CGContextScaleCTM(context, key3Rect.size.width / 100, key3Rect.size.height / 100)

        AKTelephoneView.drawKey(text: "D E F", numeral: "3", isPressed: currentKey == "3")
        CGContextRestoreGState(context)


        //// key 4 Drawing
        key4Rect = CGRect(x: 70, y: 302, width: 82, height: 82)
        CGContextSaveGState(context)
        UIRectClip(key4Rect)
        CGContextTranslateCTM(context, key4Rect.origin.x, key4Rect.origin.y)
        CGContextScaleCTM(context, key4Rect.size.width / 100, key4Rect.size.height / 100)

        AKTelephoneView.drawKey(text: "G H I", numeral: "4", isPressed: currentKey == "4")
        CGContextRestoreGState(context)


        //// key 5 Drawing
        key5Rect = CGRect(x: 179, y: 302, width: 82, height: 82)
        CGContextSaveGState(context)
        UIRectClip(key5Rect)
        CGContextTranslateCTM(context, key5Rect.origin.x, key5Rect.origin.y)
        CGContextScaleCTM(context, key5Rect.size.width / 100, key5Rect.size.height / 100)

        AKTelephoneView.drawKey(text: "J K L", numeral: "5", isPressed: currentKey == "5")
        CGContextRestoreGState(context)


        //// key 6 Drawing
        key6Rect = CGRect(x: 288, y: 302, width: 82, height: 82)
        CGContextSaveGState(context)
        UIRectClip(key6Rect)
        CGContextTranslateCTM(context, key6Rect.origin.x, key6Rect.origin.y)
        CGContextScaleCTM(context, key6Rect.size.width / 100, key6Rect.size.height / 100)

        AKTelephoneView.drawKey(text: "M N O", numeral: "6", isPressed: currentKey == "6")
        CGContextRestoreGState(context)


        //// key 7 Drawing
        key7Rect = CGRect(x: 70, y: 397, width: 82, height: 82)
        CGContextSaveGState(context)
        UIRectClip(key7Rect)
        CGContextTranslateCTM(context, key7Rect.origin.x, key7Rect.origin.y)
        CGContextScaleCTM(context, key7Rect.size.width / 100, key7Rect.size.height / 100)

        AKTelephoneView.drawKey(text: "P Q R S", numeral: "7", isPressed: currentKey == "7")
        CGContextRestoreGState(context)


        //// key 8 Drawing
        key8Rect = CGRect(x: 179, y: 397, width: 82, height: 82)
        CGContextSaveGState(context)
        UIRectClip(key8Rect)
        CGContextTranslateCTM(context, key8Rect.origin.x, key8Rect.origin.y)
        CGContextScaleCTM(context, key8Rect.size.width / 100, key8Rect.size.height / 100)

        AKTelephoneView.drawKey(text: "T U V", numeral: "8", isPressed: currentKey == "8")
        CGContextRestoreGState(context)


        //// key 9 Drawing
        key9Rect = CGRect(x: 288, y: 397, width: 82, height: 82)
        CGContextSaveGState(context)
        UIRectClip(key9Rect)
        CGContextTranslateCTM(context, key9Rect.origin.x, key9Rect.origin.y)
        CGContextScaleCTM(context, key9Rect.size.width / 100, key9Rect.size.height / 100)

        AKTelephoneView.drawKey(text: "W X Y Z", numeral: "9", isPressed: currentKey == "9")
        CGContextRestoreGState(context)


        //// key 0 Drawing
        key0Rect = CGRect(x: 179, y: 494, width: 82, height: 82)
        CGContextSaveGState(context)
        UIRectClip(key0Rect)
        CGContextTranslateCTM(context, key0Rect.origin.x, key0Rect.origin.y)
        CGContextScaleCTM(context, key0Rect.size.width / 100, key0Rect.size.height / 100)

        AKTelephoneView.drawKey(text: "+", numeral: "0", isPressed: currentKey == "0")
        CGContextRestoreGState(context)


        //// keyStar Drawing
        keyStarRect = CGRect(x: 70, y: 494, width: 82, height: 82)
        CGContextSaveGState(context)
        UIRectClip(keyStarRect)
        CGContextTranslateCTM(context, keyStarRect.origin.x, keyStarRect.origin.y)
        CGContextScaleCTM(context, keyStarRect.size.width / 100, keyStarRect.size.height / 100)

        AKTelephoneView.drawCenteredKey(numeral: "*", isPressed: currentKey == "*")
        CGContextRestoreGState(context)


        //// keyHash Drawing
        keyHashRect = CGRect(x: 288, y: 494, width: 82, height: 82)
        CGContextSaveGState(context)
        UIRectClip(keyHashRect)
        CGContextTranslateCTM(context, keyHashRect.origin.x, keyHashRect.origin.y)
        CGContextScaleCTM(context, keyHashRect.size.width / 100, keyHashRect.size.height / 100)

        AKTelephoneView.drawCenteredKey(numeral: "#", isPressed: currentKey == "#")
        CGContextRestoreGState(context)


        //// CallButton
        //// callCircle Drawing
        callCirclePath = UIBezierPath(ovalInRect: CGRect(x: 181, y: 603, width: 79, height: 79))
        color.setFill()
        callCirclePath.fill()


        //// telephoneSilhouette Drawing
        let telephoneSilhouettePath = UIBezierPath()
        telephoneSilhouettePath.moveToPoint(CGPoint(x: 214.75, y: 650.4))
        telephoneSilhouettePath.addCurveToPoint(CGPoint(x: 228.04, y: 659.02), controlPoint1: CGPoint(x: 220.59, y: 656.33), controlPoint2: CGPoint(x: 228.04, y: 659.02))
        telephoneSilhouettePath.addCurveToPoint(CGPoint(x: 234.15, y: 659.02), controlPoint1: CGPoint(x: 228.04, y: 659.02), controlPoint2: CGPoint(x: 231.54, y: 660.1))
        telephoneSilhouettePath.addCurveToPoint(CGPoint(x: 237.74, y: 653.99), controlPoint1: CGPoint(x: 236.75, y: 657.94), controlPoint2: CGPoint(x: 237.74, y: 653.99))
        telephoneSilhouettePath.addLineToPoint(CGPoint(x: 229.12, y: 647.89))
        telephoneSilhouettePath.addCurveToPoint(CGPoint(x: 222.65, y: 649.32), controlPoint1: CGPoint(x: 229.12, y: 647.89), controlPoint2: CGPoint(x: 225.17, y: 651.12))
        telephoneSilhouettePath.addCurveToPoint(CGPoint(x: 213.68, y: 640.7), controlPoint1: CGPoint(x: 220.14, y: 647.53), controlPoint2: CGPoint(x: 214.75, y: 642.86))
        telephoneSilhouettePath.addCurveToPoint(CGPoint(x: 215.83, y: 635.32), controlPoint1: CGPoint(x: 212.6, y: 638.55), controlPoint2: CGPoint(x: 215.83, y: 635.32))
        telephoneSilhouettePath.addLineToPoint(CGPoint(x: 210.8, y: 626.34))
        telephoneSilhouettePath.addCurveToPoint(CGPoint(x: 207.57, y: 627.42), controlPoint1: CGPoint(x: 210.8, y: 626.34), controlPoint2: CGPoint(x: 209.1, y: 626.43))
        telephoneSilhouettePath.addCurveToPoint(CGPoint(x: 204.7, y: 630.29), controlPoint1: CGPoint(x: 206.05, y: 628.41), controlPoint2: CGPoint(x: 204.7, y: 630.29))
        telephoneSilhouettePath.addCurveToPoint(CGPoint(x: 205.78, y: 637.11), controlPoint1: CGPoint(x: 204.7, y: 630.29), controlPoint2: CGPoint(x: 204.34, y: 634.24))
        telephoneSilhouettePath.addCurveToPoint(CGPoint(x: 214.75, y: 650.4), controlPoint1: CGPoint(x: 207.21, y: 639.99), controlPoint2: CGPoint(x: 208.92, y: 644.48))
        telephoneSilhouettePath.closePath()
        UIColor.whiteColor().setFill()
        telephoneSilhouettePath.fill()




        //// BusyButton
        //// busyCircle Drawing
        busyCirclePath = UIBezierPath(ovalInRect: CGRect(x: 73, y: 603, width: 79, height: 79))
        color2.setFill()
        busyCirclePath.fill()


        //// busyText Drawing
        let busyTextRect = CGRect(x: 73, y: 603, width: 79, height: 79)
        let busyTextTextContent = NSString(string: "BUSY")
        let busyTextStyle = NSMutableParagraphStyle()
        busyTextStyle.alignment = .Center

        let busyTextFontAttributes = [NSFontAttributeName: UIFont.boldSystemFontOfSize(UIFont.labelFontSize()), NSForegroundColorAttributeName: UIColor.whiteColor(), NSParagraphStyleAttributeName: busyTextStyle]

        let busyTextTextHeight: CGFloat = busyTextTextContent.boundingRectWithSize(CGSize(width: busyTextRect.width, height: CGFloat.infinity), options: NSStringDrawingOptions.UsesLineFragmentOrigin, attributes: busyTextFontAttributes, context: nil).size.height
        CGContextSaveGState(context)
        CGContextClipToRect(context, busyTextRect)
        busyTextTextContent.drawInRect(CGRect(x: busyTextRect.minX, y: busyTextRect.minY + (busyTextRect.height - busyTextTextHeight) / 2, width: busyTextRect.width, height: busyTextTextHeight), withAttributes: busyTextFontAttributes)
        CGContextRestoreGState(context)




        //// Readout Drawing
        let readoutRect = CGRect(x: 0, y: 52, width: 440, height: 72)
        let readoutTextContent = NSString(string: last10Presses.joinWithSeparator(""))
        let readoutStyle = NSMutableParagraphStyle()
        readoutStyle.alignment = .Center

        let readoutFontAttributes = [NSFontAttributeName: UIFont.systemFontOfSize(48), NSForegroundColorAttributeName: UIColor.blackColor(), NSParagraphStyleAttributeName: readoutStyle]

        let readoutTextHeight: CGFloat = readoutTextContent.boundingRectWithSize(CGSize(width: readoutRect.width, height: CGFloat.infinity), options: NSStringDrawingOptions.UsesLineFragmentOrigin, attributes: readoutFontAttributes, context: nil).size.height
        CGContextSaveGState(context)
        CGContextClipToRect(context, readoutRect)
        readoutTextContent.drawInRect(CGRect(x: readoutRect.minX, y: readoutRect.minY + (readoutRect.height - readoutTextHeight) / 2, width: readoutRect.width, height: readoutTextHeight), withAttributes: readoutFontAttributes)
        CGContextRestoreGState(context)
    }

    public class func drawKey(text text: String = "A B C", numeral: String = "1", isPressed: Bool = true) {
        //// General Declarations
        let context = UIGraphicsGetCurrentContext()

        //// Color Declarations
        let pressedKeyColor = UIColor(red: 0.655, green: 0.745, blue: 0.804, alpha: 1.000)
        let unpressedKeyColor = UIColor(red: 0.937, green: 0.941, blue: 0.949, alpha: 1.000)
        let unpressedTextColor = UIColor(red: 0.000, green: 0.000, blue: 0.000, alpha: 1.000)
        let pressedTextColor = UIColor(red: 1.000, green: 0.992, blue: 0.988, alpha: 1.000)

        //// Variable Declarations
        let keyColor = isPressed ? pressedKeyColor : unpressedKeyColor
        let textColor = isPressed ? pressedTextColor : unpressedTextColor

        //// Oval Drawing
        let ovalPath = UIBezierPath(ovalInRect: CGRect(x: 2, y: 2, width: 96, height: 96))
        keyColor.setFill()
        ovalPath.fill()
        UIColor.lightGrayColor().setStroke()
        ovalPath.lineWidth = 2.5
        ovalPath.stroke()


        //// Letters Drawing
        let lettersRect = CGRect(x: 0, y: 60, width: 100, height: 23)
        let lettersStyle = NSMutableParagraphStyle()
        lettersStyle.alignment = .Center

        let lettersFontAttributes = [NSFontAttributeName: UIFont.systemFontOfSize(11), NSForegroundColorAttributeName: textColor, NSParagraphStyleAttributeName: lettersStyle]

        let lettersTextHeight: CGFloat = NSString(string: text).boundingRectWithSize(CGSize(width: lettersRect.width, height: CGFloat.infinity), options: NSStringDrawingOptions.UsesLineFragmentOrigin, attributes: lettersFontAttributes, context: nil).size.height
        CGContextSaveGState(context)
        CGContextClipToRect(context, lettersRect)
        NSString(string: text).drawInRect(CGRect(x: lettersRect.minX, y: lettersRect.minY + (lettersRect.height - lettersTextHeight) / 2, width: lettersRect.width, height: lettersTextHeight), withAttributes: lettersFontAttributes)
        CGContextRestoreGState(context)


        //// Number Drawing
        let numberRect = CGRect(x: 27, y: 18, width: 45, height: 46)
        let numberStyle = NSMutableParagraphStyle()
        numberStyle.alignment = .Center

        let numberFontAttributes = [NSFontAttributeName: UIFont.systemFontOfSize(48), NSForegroundColorAttributeName: textColor, NSParagraphStyleAttributeName: numberStyle]

        let numberTextHeight: CGFloat = NSString(string: numeral).boundingRectWithSize(CGSize(width: numberRect.width, height: CGFloat.infinity), options: NSStringDrawingOptions.UsesLineFragmentOrigin, attributes: numberFontAttributes, context: nil).size.height
        CGContextSaveGState(context)
        CGContextClipToRect(context, numberRect)
        NSString(string: numeral).drawInRect(CGRect(x: numberRect.minX, y: numberRect.minY + (numberRect.height - numberTextHeight) / 2, width: numberRect.width, height: numberTextHeight), withAttributes: numberFontAttributes)
        CGContextRestoreGState(context)
    }

    public class func drawCenteredKey(numeral numeral: String = "1", isPressed: Bool = true) {
        //// General Declarations
        let context = UIGraphicsGetCurrentContext()

        //// Color Declarations
        let pressedKeyColor = UIColor(red: 0.655, green: 0.745, blue: 0.804, alpha: 1.000)
        let unpressedKeyColor = UIColor(red: 0.937, green: 0.941, blue: 0.949, alpha: 1.000)
        let unpressedTextColor = UIColor(red: 0.000, green: 0.000, blue: 0.000, alpha: 1.000)
        let pressedTextColor = UIColor(red: 1.000, green: 0.992, blue: 0.988, alpha: 1.000)

        //// Variable Declarations
        let keyColor = isPressed ? pressedKeyColor : unpressedKeyColor
        let textColor = isPressed ? pressedTextColor : unpressedTextColor

        //// Oval Drawing
        let ovalPath = UIBezierPath(ovalInRect: CGRect(x: 2, y: 2, width: 96, height: 96))
        keyColor.setFill()
        ovalPath.fill()
        UIColor.lightGrayColor().setStroke()
        ovalPath.lineWidth = 2.5
        ovalPath.stroke()


        //// Number Drawing
        let numberRect = CGRect(x: 27, y: 27, width: 45, height: 46)
        let numberStyle = NSMutableParagraphStyle()
        numberStyle.alignment = .Center

        let numberFontAttributes = [NSFontAttributeName: UIFont.systemFontOfSize(48), NSForegroundColorAttributeName: textColor, NSParagraphStyleAttributeName: numberStyle]

        let numberTextHeight: CGFloat = NSString(string: numeral).boundingRectWithSize(CGSize(width: numberRect.width, height: CGFloat.infinity), options: NSStringDrawingOptions.UsesLineFragmentOrigin, attributes: numberFontAttributes, context: nil).size.height
        CGContextSaveGState(context)
        CGContextClipToRect(context, numberRect)
        NSString(string: numeral).drawInRect(CGRect(x: numberRect.minX, y: numberRect.minY + (numberRect.height - numberTextHeight) / 2, width: numberRect.width, height: numberTextHeight), withAttributes: numberFontAttributes)
        CGContextRestoreGState(context)
    }

}
