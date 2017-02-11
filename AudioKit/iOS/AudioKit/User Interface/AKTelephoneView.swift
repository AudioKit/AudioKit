//
//  AKTelephoneView.swift
//  AudioKit for iOS
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright © 2017 Aurelius Prochazka. All rights reserved.
//

import Foundation

/// This is primarily for the telephone page in the Synthesis playground
open class AKTelephoneView: UIView {
    
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
    
    var last10Presses = [String](repeating: "", count: 10)
    var currentKey = ""
    var callback: (String, String) -> Void
    
    override open func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first {
            let touchLocation = touch.location(in: self)
            let keyRects: [String: CGRect] = [
                "1": key1Rect,
                "2": key2Rect,
                "3": key3Rect,
                "4": key4Rect,
                "5": key5Rect,
                "6": key6Rect,
                "7": key7Rect,
                "8": key8Rect,
                "9": key9Rect,
                "0": key0Rect,
                "*": keyStarRect,
                "#": keyHashRect            ]
            for key in keyRects.keys {
                guard let rect = keyRects[key] else { return }
                if rect.contains(touchLocation) { currentKey = key }
            }
            if callCirclePath.contains(touchLocation) { currentKey = "CALL" }
            if busyCirclePath.contains(touchLocation) { currentKey = "BUSY" }

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
    
    override open func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        if currentKey != "" {
            callback(currentKey, "up")
            currentKey = ""
        }
        setNeedsDisplay()
    }
    
    public init(frame: CGRect = CGRect(x: 0, y: 0, width: 440, height: 782), callback: @escaping (String, String) -> Void) {
        self.callback = callback
        super.init(frame: frame)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override open func draw(_ rect: CGRect) {
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
        context!.saveGState()
        UIRectClip(key1Rect)
        context!.translateBy(x: key1Rect.origin.x, y: key1Rect.origin.y)
        context!.scaleBy(x: key1Rect.size.width / 100, y: key1Rect.size.height / 100)

        AKTelephoneView.drawKey(text: "\n", numeral: "1", isPressed: currentKey == "1")
        context!.restoreGState()

        //// key 2 Drawing
        key2Rect = CGRect(x: 179, y: 205, width: 82, height: 82)
        context!.saveGState()
        UIRectClip(key2Rect)
        context!.translateBy(x: key2Rect.origin.x, y: key2Rect.origin.y)
        context!.scaleBy(x: key2Rect.size.width / 100, y: key2Rect.size.height / 100)

        AKTelephoneView.drawKey(text: "A B C", numeral: "2", isPressed: currentKey == "2")
        context!.restoreGState()

        //// key 3 Drawing
        key3Rect = CGRect(x: 288, y: 205, width: 82, height: 82)
        context!.saveGState()
        UIRectClip(key3Rect)
        context!.translateBy(x: key3Rect.origin.x, y: key3Rect.origin.y)
        context!.scaleBy(x: key3Rect.size.width / 100, y: key3Rect.size.height / 100)

        AKTelephoneView.drawKey(text: "D E F", numeral: "3", isPressed: currentKey == "3")
        context!.restoreGState()

        //// key 4 Drawing
        key4Rect = CGRect(x: 70, y: 302, width: 82, height: 82)
        context!.saveGState()
        UIRectClip(key4Rect)
        context!.translateBy(x: key4Rect.origin.x, y: key4Rect.origin.y)
        context!.scaleBy(x: key4Rect.size.width / 100, y: key4Rect.size.height / 100)

        AKTelephoneView.drawKey(text: "G H I", numeral: "4", isPressed: currentKey == "4")
        context!.restoreGState()

        //// key 5 Drawing
        key5Rect = CGRect(x: 179, y: 302, width: 82, height: 82)
        context!.saveGState()
        UIRectClip(key5Rect)
        context!.translateBy(x: key5Rect.origin.x, y: key5Rect.origin.y)
        context!.scaleBy(x: key5Rect.size.width / 100, y: key5Rect.size.height / 100)

        AKTelephoneView.drawKey(text: "J K L", numeral: "5", isPressed: currentKey == "5")
        context!.restoreGState()

        //// key 6 Drawing
        key6Rect = CGRect(x: 288, y: 302, width: 82, height: 82)
        context!.saveGState()
        UIRectClip(key6Rect)
        context!.translateBy(x: key6Rect.origin.x, y: key6Rect.origin.y)
        context!.scaleBy(x: key6Rect.size.width / 100, y: key6Rect.size.height / 100)

        AKTelephoneView.drawKey(text: "M N O", numeral: "6", isPressed: currentKey == "6")
        context!.restoreGState()

        //// key 7 Drawing
        key7Rect = CGRect(x: 70, y: 397, width: 82, height: 82)
        context!.saveGState()
        UIRectClip(key7Rect)
        context!.translateBy(x: key7Rect.origin.x, y: key7Rect.origin.y)
        context!.scaleBy(x: key7Rect.size.width / 100, y: key7Rect.size.height / 100)

        AKTelephoneView.drawKey(text: "P Q R S", numeral: "7", isPressed: currentKey == "7")
        context!.restoreGState()

        //// key 8 Drawing
        key8Rect = CGRect(x: 179, y: 397, width: 82, height: 82)
        context!.saveGState()
        UIRectClip(key8Rect)
        context!.translateBy(x: key8Rect.origin.x, y: key8Rect.origin.y)
        context!.scaleBy(x: key8Rect.size.width / 100, y: key8Rect.size.height / 100)

        AKTelephoneView.drawKey(text: "T U V", numeral: "8", isPressed: currentKey == "8")
        context!.restoreGState()

        //// key 9 Drawing
        key9Rect = CGRect(x: 288, y: 397, width: 82, height: 82)
        context!.saveGState()
        UIRectClip(key9Rect)
        context!.translateBy(x: key9Rect.origin.x, y: key9Rect.origin.y)
        context!.scaleBy(x: key9Rect.size.width / 100, y: key9Rect.size.height / 100)

        AKTelephoneView.drawKey(text: "W X Y Z", numeral: "9", isPressed: currentKey == "9")
        context!.restoreGState()

        //// key 0 Drawing
        key0Rect = CGRect(x: 179, y: 494, width: 82, height: 82)
        context!.saveGState()
        UIRectClip(key0Rect)
        context!.translateBy(x: key0Rect.origin.x, y: key0Rect.origin.y)
        context!.scaleBy(x: key0Rect.size.width / 100, y: key0Rect.size.height / 100)

        AKTelephoneView.drawKey(text: "+", numeral: "0", isPressed: currentKey == "0")
        context!.restoreGState()

        //// keyStar Drawing
        keyStarRect = CGRect(x: 70, y: 494, width: 82, height: 82)
        context!.saveGState()
        UIRectClip(keyStarRect)
        context!.translateBy(x: keyStarRect.origin.x, y: keyStarRect.origin.y)
        context!.scaleBy(x: keyStarRect.size.width / 100, y: keyStarRect.size.height / 100)

        AKTelephoneView.drawCenteredKey(numeral: "*", isPressed: currentKey == "*")
        context!.restoreGState()

        //// keyHash Drawing
        keyHashRect = CGRect(x: 288, y: 494, width: 82, height: 82)
        context!.saveGState()
        UIRectClip(keyHashRect)
        context!.translateBy(x: keyHashRect.origin.x, y: keyHashRect.origin.y)
        context!.scaleBy(x: keyHashRect.size.width / 100, y: keyHashRect.size.height / 100)

        AKTelephoneView.drawCenteredKey(numeral: "#", isPressed: currentKey == "#")
        context!.restoreGState()

        //// CallButton
        //// callCircle Drawing
        callCirclePath = UIBezierPath(ovalIn: CGRect(x: 181, y: 603, width: 79, height: 79))
        color.setFill()
        callCirclePath.fill()

        //// telephoneSilhouette Drawing
        let telephoneSilhouettePath = UIBezierPath()
        telephoneSilhouettePath.move(to: CGPoint(x: 214.75, y: 650.4))
        telephoneSilhouettePath.addCurve(to: CGPoint(x: 228.04, y: 659.02), controlPoint1: CGPoint(x: 220.59, y: 656.33), controlPoint2: CGPoint(x: 228.04, y: 659.02))
        telephoneSilhouettePath.addCurve(to: CGPoint(x: 234.15, y: 659.02), controlPoint1: CGPoint(x: 228.04, y: 659.02), controlPoint2: CGPoint(x: 231.54, y: 660.1))
        telephoneSilhouettePath.addCurve(to: CGPoint(x: 237.74, y: 653.99), controlPoint1: CGPoint(x: 236.75, y: 657.94), controlPoint2: CGPoint(x: 237.74, y: 653.99))
        telephoneSilhouettePath.addLine(to: CGPoint(x: 229.12, y: 647.89))
        telephoneSilhouettePath.addCurve(to: CGPoint(x: 222.65, y: 649.32), controlPoint1: CGPoint(x: 229.12, y: 647.89), controlPoint2: CGPoint(x: 225.17, y: 651.12))
        telephoneSilhouettePath.addCurve(to: CGPoint(x: 213.68, y: 640.7), controlPoint1: CGPoint(x: 220.14, y: 647.53), controlPoint2: CGPoint(x: 214.75, y: 642.86))
        telephoneSilhouettePath.addCurve(to: CGPoint(x: 215.83, y: 635.32), controlPoint1: CGPoint(x: 212.6, y: 638.55), controlPoint2: CGPoint(x: 215.83, y: 635.32))
        telephoneSilhouettePath.addLine(to: CGPoint(x: 210.8, y: 626.34))
        telephoneSilhouettePath.addCurve(to: CGPoint(x: 207.57, y: 627.42), controlPoint1: CGPoint(x: 210.8, y: 626.34), controlPoint2: CGPoint(x: 209.1, y: 626.43))
        telephoneSilhouettePath.addCurve(to: CGPoint(x: 204.7, y: 630.29), controlPoint1: CGPoint(x: 206.05, y: 628.41), controlPoint2: CGPoint(x: 204.7, y: 630.29))
        telephoneSilhouettePath.addCurve(to: CGPoint(x: 205.78, y: 637.11), controlPoint1: CGPoint(x: 204.7, y: 630.29), controlPoint2: CGPoint(x: 204.34, y: 634.24))
        telephoneSilhouettePath.addCurve(to: CGPoint(x: 214.75, y: 650.4), controlPoint1: CGPoint(x: 207.21, y: 639.99), controlPoint2: CGPoint(x: 208.92, y: 644.48))
        telephoneSilhouettePath.close()
        UIColor.white.setFill()
        telephoneSilhouettePath.fill()

        //// BusyButton
        //// busyCircle Drawing
        busyCirclePath = UIBezierPath(ovalIn: CGRect(x: 73, y: 603, width: 79, height: 79))
        color2.setFill()
        busyCirclePath.fill()

        //// busyText Drawing
        let busyTextRect = CGRect(x: 73, y: 603, width: 79, height: 79)
        let busyTextTextContent = NSString(string: "BUSY")
        let busyTextStyle = NSMutableParagraphStyle()
        busyTextStyle.alignment = .center

        let busyTextFontAttributes = [NSFontAttributeName: UIFont.boldSystemFont(ofSize: UIFont.labelFontSize), NSForegroundColorAttributeName: UIColor.white, NSParagraphStyleAttributeName: busyTextStyle]

        let busyTextTextHeight: CGFloat = busyTextTextContent.boundingRect(with: CGSize(width: busyTextRect.width, height: CGFloat.infinity), options: NSStringDrawingOptions.usesLineFragmentOrigin, attributes: busyTextFontAttributes, context: nil).size.height
        context!.saveGState()
        context!.clip(to: busyTextRect)
        busyTextTextContent.draw(in: CGRect(x: busyTextRect.minX, y: busyTextRect.minY + (busyTextRect.height - busyTextTextHeight) / 2, width: busyTextRect.width, height: busyTextTextHeight), withAttributes: busyTextFontAttributes)
        context!.restoreGState()

        //// Readout Drawing
        let readoutRect = CGRect(x: 0, y: 52, width: 440, height: 72)
        let readoutTextContent = NSString(string: last10Presses.joined(separator: ""))
        let readoutStyle = NSMutableParagraphStyle()
        readoutStyle.alignment = .center

        let readoutFontAttributes = [NSFontAttributeName: UIFont.systemFont(ofSize: 48), NSForegroundColorAttributeName: UIColor.black, NSParagraphStyleAttributeName: readoutStyle]

        let readoutTextHeight: CGFloat = readoutTextContent.boundingRect(with: CGSize(width: readoutRect.width, height: CGFloat.infinity), options: NSStringDrawingOptions.usesLineFragmentOrigin, attributes: readoutFontAttributes, context: nil).size.height
        context!.saveGState()
        context!.clip(to: readoutRect)
        readoutTextContent.draw(in: CGRect(x: readoutRect.minX, y: readoutRect.minY + (readoutRect.height - readoutTextHeight) / 2, width: readoutRect.width, height: readoutTextHeight), withAttributes: readoutFontAttributes)
        context!.restoreGState()
    }

    open class func drawKey(text: String = "A B C", numeral: String = "1", isPressed: Bool = true) {
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
        let ovalPath = UIBezierPath(ovalIn: CGRect(x: 2, y: 2, width: 96, height: 96))
        keyColor.setFill()
        ovalPath.fill()
        UIColor.lightGray.setStroke()
        ovalPath.lineWidth = 2.5
        ovalPath.stroke()

        //// Letters Drawing
        let lettersRect = CGRect(x: 0, y: 60, width: 100, height: 23)
        let lettersStyle = NSMutableParagraphStyle()
        lettersStyle.alignment = .center

        let lettersFontAttributes = [NSFontAttributeName: UIFont.systemFont(ofSize: 11), NSForegroundColorAttributeName: textColor, NSParagraphStyleAttributeName: lettersStyle]

        let lettersTextHeight: CGFloat = NSString(string: text).boundingRect(with: CGSize(width: lettersRect.width, height: CGFloat.infinity), options: NSStringDrawingOptions.usesLineFragmentOrigin, attributes: lettersFontAttributes, context: nil).size.height
        context!.saveGState()
        context!.clip(to: lettersRect)
        NSString(string: text).draw(in: CGRect(x: lettersRect.minX, y: lettersRect.minY + (lettersRect.height - lettersTextHeight) / 2, width: lettersRect.width, height: lettersTextHeight), withAttributes: lettersFontAttributes)
        context!.restoreGState()

        //// Number Drawing
        let numberRect = CGRect(x: 27, y: 18, width: 45, height: 46)
        let numberStyle = NSMutableParagraphStyle()
        numberStyle.alignment = .center

        let numberFontAttributes = [NSFontAttributeName: UIFont.systemFont(ofSize: 48), NSForegroundColorAttributeName: textColor, NSParagraphStyleAttributeName: numberStyle]

        let numberTextHeight: CGFloat = NSString(string: numeral).boundingRect(with: CGSize(width: numberRect.width, height: CGFloat.infinity), options: NSStringDrawingOptions.usesLineFragmentOrigin, attributes: numberFontAttributes, context: nil).size.height
        context!.saveGState()
        context!.clip(to: numberRect)
        NSString(string: numeral).draw(in: CGRect(x: numberRect.minX, y: numberRect.minY + (numberRect.height - numberTextHeight) / 2, width: numberRect.width, height: numberTextHeight), withAttributes: numberFontAttributes)
        context!.restoreGState()
    }

    open class func drawCenteredKey(numeral: String = "1", isPressed: Bool = true) {
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
        let ovalPath = UIBezierPath(ovalIn: CGRect(x: 2, y: 2, width: 96, height: 96))
        keyColor.setFill()
        ovalPath.fill()
        UIColor.lightGray.setStroke()
        ovalPath.lineWidth = 2.5
        ovalPath.stroke()

        //// Number Drawing
        let numberRect = CGRect(x: 27, y: 27, width: 45, height: 46)
        let numberStyle = NSMutableParagraphStyle()
        numberStyle.alignment = .center

        let numberFontAttributes = [NSFontAttributeName: UIFont.systemFont(ofSize: 48), NSForegroundColorAttributeName: textColor, NSParagraphStyleAttributeName: numberStyle]

        let numberTextHeight: CGFloat = NSString(string: numeral).boundingRect(with: CGSize(width: numberRect.width, height: CGFloat.infinity), options: NSStringDrawingOptions.usesLineFragmentOrigin, attributes: numberFontAttributes, context: nil).size.height
        context!.saveGState()
        context!.clip(to: numberRect)
        NSString(string: numeral).draw(in: CGRect(x: numberRect.minX, y: numberRect.minY + (numberRect.height - numberTextHeight) / 2, width: numberRect.width, height: numberTextHeight), withAttributes: numberFontAttributes)
        context!.restoreGState()
    }

}
