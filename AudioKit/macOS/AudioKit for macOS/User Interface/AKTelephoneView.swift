//
//  AKTelephoneView.swift
//  AudioKit for macOS
//
//  Created by Aurelius Prochazka on 7/31/16.
//  Copyright © 2017 Aurelius Prochazka. All rights reserved.
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

    var last10Presses = Array<String>(repeating: "", count: 10)
    var currentKey = ""
    var callback: (String, String) -> Void

    override public func mouseDown(with theEvent: NSEvent) {
        let touchLocation = convert(theEvent.locationInWindow, from: nil)
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
        if callCirclePath.contains(touchLocation) { currentKey = "CALL" }
        if busyCirclePath.contains(touchLocation) { currentKey = "BUSY" }
        if currentKey != "" {
            callback(currentKey, "down")
            if currentKey.characters.count == 1 {
                last10Presses.removeFirst()
                last10Presses.append(currentKey)
            }

        }
        needsDisplay = true

    }

    override public func mouseUp(with theEvent: NSEvent) {

        if currentKey != "" {
            callback(currentKey, "up")
            currentKey = ""
        }
        needsDisplay = true
    }

    public init(frame: CGRect = CGRect(x: 0, y: 0, width: 440, height: 782),
                callback: @escaping (String, String) -> Void) {
        self.callback = callback
        super.init(frame: frame)
    }

    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override public func draw(_ rect: CGRect) {
        //// General Declarations
        let context = NSGraphicsContext.current()!.cgContext

        //// Color Declarations
        let color = NSColor(calibratedRed: 0.306, green: 0.851, blue: 0.392, alpha: 1)
        let color2 = NSColor(calibratedRed: 1, green: 0.151, blue: 0, alpha: 1)
        let unpressedKeyColor = NSColor(calibratedRed: 0.937, green: 0.941, blue: 0.949, alpha: 1)

        //// Background Drawing
        let backgroundPath = NSBezierPath(rect: NSRect(x: 1, y: 0, width: 440, height: 782))
        unpressedKeyColor.setFill()
        backgroundPath.fill()

        //// key 1 Drawing
        key1Rect = NSRect(x: 70, y: 494, width: 82, height: 82)
        NSGraphicsContext.saveGraphicsState()
        NSRectClip(key1Rect)
        context.translateBy(x: key1Rect.origin.x, y: key1Rect.origin.y)
        context.scaleBy(x: key1Rect.size.width / 100, y: key1Rect.size.height / 100)

        AKTelephoneView.drawKey(text: "\n", numeral: "1", isPressed: currentKey == "1")
        NSGraphicsContext.restoreGraphicsState()

        //// key 2 Drawing
        key2Rect = NSRect(x: 179, y: 495, width: 82, height: 82)
        NSGraphicsContext.saveGraphicsState()
        NSRectClip(key2Rect)
        context.translateBy(x: key2Rect.origin.x, y: key2Rect.origin.y)
        context.scaleBy(x: key2Rect.size.width / 100, y: key2Rect.size.height / 100)

        AKTelephoneView.drawKey(text: "A B C", numeral: "2", isPressed: currentKey == "2")
        NSGraphicsContext.restoreGraphicsState()

        //// key 3 Drawing
        key3Rect = NSRect(x: 288, y: 495, width: 82, height: 82)
        NSGraphicsContext.saveGraphicsState()
        NSRectClip(key3Rect)
        context.translateBy(x: key3Rect.origin.x, y: key3Rect.origin.y)
        context.scaleBy(x: key3Rect.size.width / 100, y: key3Rect.size.height / 100)

        AKTelephoneView.drawKey(text: "D E F", numeral: "3", isPressed: currentKey == "3")
        NSGraphicsContext.restoreGraphicsState()

        //// key 4 Drawing
        key4Rect = NSRect(x: 70, y: 398, width: 82, height: 82)
        NSGraphicsContext.saveGraphicsState()
        NSRectClip(key4Rect)
        context.translateBy(x: key4Rect.origin.x, y: key4Rect.origin.y)
        context.scaleBy(x: key4Rect.size.width / 100, y: key4Rect.size.height / 100)

        AKTelephoneView.drawKey(text: "G H I", numeral: "4", isPressed: currentKey == "4")
        NSGraphicsContext.restoreGraphicsState()

        //// key 5 Drawing
        key5Rect = NSRect(x: 179, y: 398, width: 82, height: 82)
        NSGraphicsContext.saveGraphicsState()
        NSRectClip(key5Rect)
        context.translateBy(x: key5Rect.origin.x, y: key5Rect.origin.y)
        context.scaleBy(x: key5Rect.size.width / 100, y: key5Rect.size.height / 100)

        AKTelephoneView.drawKey(text: "J K L", numeral: "5", isPressed: currentKey == "5")
        NSGraphicsContext.restoreGraphicsState()

        //// key 6 Drawing
        key6Rect = NSRect(x: 288, y: 398, width: 82, height: 82)
        NSGraphicsContext.saveGraphicsState()
        NSRectClip(key6Rect)
        context.translateBy(x: key6Rect.origin.x, y: key6Rect.origin.y)
        context.scaleBy(x: key6Rect.size.width / 100, y: key6Rect.size.height / 100)

        AKTelephoneView.drawKey(text: "M N O", numeral: "6", isPressed: currentKey == "6")
        NSGraphicsContext.restoreGraphicsState()

        //// key 7 Drawing
        key7Rect = NSRect(x: 70, y: 303, width: 82, height: 82)
        NSGraphicsContext.saveGraphicsState()
        NSRectClip(key7Rect)
        context.translateBy(x: key7Rect.origin.x, y: key7Rect.origin.y)
        context.scaleBy(x: key7Rect.size.width / 100, y: key7Rect.size.height / 100)

        AKTelephoneView.drawKey(text: "P Q R S", numeral: "7", isPressed: currentKey == "7")
        NSGraphicsContext.restoreGraphicsState()

        //// key 8 Drawing
        key8Rect = NSRect(x: 179, y: 303, width: 82, height: 82)
        NSGraphicsContext.saveGraphicsState()
        NSRectClip(key8Rect)
        context.translateBy(x: key8Rect.origin.x, y: key8Rect.origin.y)
        context.scaleBy(x: key8Rect.size.width / 100, y: key8Rect.size.height / 100)

        AKTelephoneView.drawKey(text: "T U V", numeral: "8", isPressed: currentKey == "8")
        NSGraphicsContext.restoreGraphicsState()

        //// key 9 Drawing
        key9Rect = NSRect(x: 288, y: 303, width: 82, height: 82)
        NSGraphicsContext.saveGraphicsState()
        NSRectClip(key9Rect)
        context.translateBy(x: key9Rect.origin.x, y: key9Rect.origin.y)
        context.scaleBy(x: key9Rect.size.width / 100, y: key9Rect.size.height / 100)

        AKTelephoneView.drawKey(text: "W X Y Z", numeral: "9", isPressed: currentKey == "9")
        NSGraphicsContext.restoreGraphicsState()

        //// key 0 Drawing
        key0Rect = NSRect(x: 179, y: 206, width: 82, height: 82)
        NSGraphicsContext.saveGraphicsState()
        NSRectClip(key0Rect)
        context.translateBy(x: key0Rect.origin.x, y: key0Rect.origin.y)
        context.scaleBy(x: key0Rect.size.width / 100, y: key0Rect.size.height / 100)

        AKTelephoneView.drawKey(text: "+", numeral: "0", isPressed: currentKey == "0")
        NSGraphicsContext.restoreGraphicsState()

        //// keyStar Drawing
        keyStarRect = NSRect(x: 70, y: 206, width: 82, height: 82)
        NSGraphicsContext.saveGraphicsState()
        NSRectClip(keyStarRect)
        context.translateBy(x: keyStarRect.origin.x, y: keyStarRect.origin.y)
        context.scaleBy(x: keyStarRect.size.width / 100, y: keyStarRect.size.height / 100)

        AKTelephoneView.drawCenteredKey(numeral: "*", isPressed: currentKey == "*")
        NSGraphicsContext.restoreGraphicsState()

        //// keyHash Drawing
        keyHashRect = NSRect(x: 288, y: 206, width: 82, height: 82)
        NSGraphicsContext.saveGraphicsState()
        NSRectClip(keyHashRect)
        context.translateBy(x: keyHashRect.origin.x, y: keyHashRect.origin.y)
        context.scaleBy(x: keyHashRect.size.width / 100, y: keyHashRect.size.height / 100)

        AKTelephoneView.drawCenteredKey(numeral: "#", isPressed: currentKey == "#")
        NSGraphicsContext.restoreGraphicsState()

        //// CallButton
        //// callCircle Drawing
        callCirclePath = NSBezierPath(ovalIn: NSRect(x: 181, y: 100, width: 79, height: 79))
        color.setFill()
        callCirclePath.fill()

        //// telephoneSilhouette Drawing
        let telephoneSilhouettePath = NSBezierPath()
        telephoneSilhouettePath.move(to: NSPoint(x: 214.75, y: 131.6))
        telephoneSilhouettePath.curve(to: NSPoint(x: 228.04, y: 122.98),
                                      controlPoint1: NSPoint(x: 220.59, y: 125.68),
                                      controlPoint2: NSPoint(x: 228.04, y: 122.98))
        telephoneSilhouettePath.curve(to: NSPoint(x: 234.15, y: 122.98),
                                      controlPoint1: NSPoint(x: 228.04, y: 122.98),
                                      controlPoint2: NSPoint(x: 231.54, y: 121.9))
        telephoneSilhouettePath.curve(to: NSPoint(x: 237.74, y: 128.01),
                                      controlPoint1: NSPoint(x: 236.75, y: 124.06),
                                      controlPoint2: NSPoint(x: 237.74, y: 128.01))
        telephoneSilhouettePath.line(to: NSPoint(x: 229.12, y: 134.11))
        telephoneSilhouettePath.curve(to: NSPoint(x: 222.65, y: 132.68),
                                      controlPoint1: NSPoint(x: 229.12, y: 134.11),
                                      controlPoint2: NSPoint(x: 225.17, y: 130.88))
        telephoneSilhouettePath.curve(to: NSPoint(x: 213.68, y: 141.3),
                                      controlPoint1: NSPoint(x: 220.14, y: 134.47),
                                      controlPoint2: NSPoint(x: 214.75, y: 139.14))
        telephoneSilhouettePath.curve(to: NSPoint(x: 215.83, y: 146.68),
                                      controlPoint1: NSPoint(x: 212.6, y: 143.45),
                                      controlPoint2: NSPoint(x: 215.83, y: 146.68))
        telephoneSilhouettePath.line(to: NSPoint(x: 210.8, y: 155.66))
        telephoneSilhouettePath.curve(to: NSPoint(x: 207.57, y: 154.58),
                                      controlPoint1: NSPoint(x: 210.8, y: 155.66),
                                      controlPoint2: NSPoint(x: 209.1, y: 155.57))
        telephoneSilhouettePath.curve(to: NSPoint(x: 204.7, y: 151.71),
                                      controlPoint1: NSPoint(x: 206.05, y: 153.59),
                                      controlPoint2: NSPoint(x: 204.7, y: 151.71))
        telephoneSilhouettePath.curve(to: NSPoint(x: 205.78, y: 144.89),
                                      controlPoint1: NSPoint(x: 204.7, y: 151.71),
                                      controlPoint2: NSPoint(x: 204.34, y: 147.76))
        telephoneSilhouettePath.curve(to: NSPoint(x: 214.75, y: 131.6),
                                      controlPoint1: NSPoint(x: 207.21, y: 142.01),
                                      controlPoint2: NSPoint(x: 208.92, y: 137.53))
        telephoneSilhouettePath.close()
        NSColor.white.setFill()
        telephoneSilhouettePath.fill()

        //// BusyButton
        //// busyCircle Drawing
        busyCirclePath = NSBezierPath(ovalIn: NSRect(x: 73, y: 100, width: 79, height: 79))
        color2.setFill()
        busyCirclePath.fill()

        //// busyText Drawing
        let busyTextRect = NSRect(x: 73, y: 100, width: 79, height: 79)
        let busyTextTextContent = NSString(string: "BUSY")
        let busyTextStyle = NSMutableParagraphStyle()
        busyTextStyle.alignment = .center

        let busyTextFontAttributes = [NSFontAttributeName: NSFont(name: "HelveticaNeue", size: 17)!,
                                      NSForegroundColorAttributeName: NSColor.white,
                                      NSParagraphStyleAttributeName: busyTextStyle]

        let busyTextTextHeight: CGFloat = busyTextTextContent.boundingRect(with: NSMakeSize(busyTextRect.width, CGFloat.infinity),
                                                                           options: NSStringDrawingOptions.usesLineFragmentOrigin,
                                                                           attributes: busyTextFontAttributes).size.height
        let busyTextTextRect: NSRect = NSMakeRect(busyTextRect.minX,
                                                  busyTextRect.minY + (busyTextRect.height - busyTextTextHeight) / 2,
                                                  busyTextRect.width,
                                                  busyTextTextHeight)
        NSGraphicsContext.saveGraphicsState()
        NSRectClip(busyTextRect)
        busyTextTextContent.draw(in: busyTextTextRect.offsetBy(dx: 0, dy: 5), withAttributes: busyTextFontAttributes)
        NSGraphicsContext.restoreGraphicsState()

        //// Readout Drawing
        let readoutRect = NSRect(x: 0, y: 658, width: 440, height: 72)
        let readoutTextContent = NSString(string: last10Presses.joined(separator: ""))
        let readoutStyle = NSMutableParagraphStyle()
        readoutStyle.alignment = .center

        let readoutFontAttributes = [NSFontAttributeName: NSFont(name: "HelveticaNeue", size: 48)!,
                                     NSForegroundColorAttributeName: NSColor.black,
                                     NSParagraphStyleAttributeName: readoutStyle]

        let readoutTextHeight: CGFloat = readoutTextContent.boundingRect(with: NSMakeSize(readoutRect.width, CGFloat.infinity),
                                                                         options: NSStringDrawingOptions.usesLineFragmentOrigin,
                                                                         attributes: readoutFontAttributes).size.height
        let readoutTextRect: NSRect = NSMakeRect(readoutRect.minX,
                                                 readoutRect.minY + (readoutRect.height - readoutTextHeight) / 2,
                                                 readoutRect.width,
                                                 readoutTextHeight)
        NSGraphicsContext.saveGraphicsState()
        NSRectClip(readoutRect)
        readoutTextContent.draw(in: readoutTextRect.offsetBy(dx: 0, dy: 0), withAttributes: readoutFontAttributes)
        NSGraphicsContext.restoreGraphicsState()
    }

    public class func drawKey(text: String = "A B C", numeral: String = "1", isPressed: Bool = true) {
        //// General Declarations
        let _ = NSGraphicsContext.current()!.cgContext

        //// Color Declarations
        let pressedKeyColor = NSColor(calibratedRed: 0.655, green: 0.745, blue: 0.804, alpha: 1)
        let unpressedKeyColor = NSColor(calibratedRed: 0.937, green: 0.941, blue: 0.949, alpha: 1)
        let unpressedTextColor = NSColor(calibratedRed: 0, green: 0, blue: 0, alpha: 1)
        let pressedTextColor = NSColor(calibratedRed: 1, green: 0.992, blue: 0.988, alpha: 1)

        //// Variable Declarations
        let keyColor: NSColor = isPressed ? pressedKeyColor : unpressedKeyColor
        let textColor: NSColor = isPressed ? pressedTextColor : unpressedTextColor

        //// Oval Drawing
        let ovalPath = NSBezierPath(ovalIn: NSRect(x: 2, y: 2, width: 96, height: 96))
        keyColor.setFill()
        ovalPath.fill()
        NSColor.lightGray.setStroke()
        ovalPath.lineWidth = 2.5
        ovalPath.stroke()

        //// Letters Drawing
        let lettersRect = NSRect(x: 0, y: 17, width: 100, height: 23)
        let lettersStyle = NSMutableParagraphStyle()
        lettersStyle.alignment = .center

        let lettersFontAttributes = [NSFontAttributeName: NSFont(name: "HelveticaNeue", size: 11)!,
                                     NSForegroundColorAttributeName: textColor,
                                     NSParagraphStyleAttributeName: lettersStyle]

        let lettersTextHeight: CGFloat = NSString(string: text).boundingRect(with: NSMakeSize(lettersRect.width, CGFloat.infinity),
                                                                             options: NSStringDrawingOptions.usesLineFragmentOrigin,
                                                                             attributes: lettersFontAttributes).size.height
        let lettersTextRect: NSRect = NSMakeRect(lettersRect.minX,
                                                 lettersRect.minY + (lettersRect.height - lettersTextHeight) / 2,
                                                 lettersRect.width,
                                                 lettersTextHeight)
        NSGraphicsContext.saveGraphicsState()
        NSRectClip(lettersRect)
        NSString(string: text).draw(in: lettersTextRect.offsetBy(dx: 0, dy: 2), withAttributes: lettersFontAttributes)
        NSGraphicsContext.restoreGraphicsState()

        //// Number Drawing
        let numberRect = NSRect(x: 27, y: 36, width: 45, height: 46)
        let numberStyle = NSMutableParagraphStyle()
        numberStyle.alignment = .center

        let numberFontAttributes = [NSFontAttributeName: NSFont(name: "HelveticaNeue", size: 48)!,
                                    NSForegroundColorAttributeName: textColor,
                                    NSParagraphStyleAttributeName: numberStyle]

        let numberTextHeight: CGFloat = NSString(string: numeral).boundingRect(with: NSMakeSize(numberRect.width, CGFloat.infinity),
                                                                               options: NSStringDrawingOptions.usesLineFragmentOrigin,
                                                                               attributes: numberFontAttributes).size.height
        let numberTextRect: NSRect = NSMakeRect(numberRect.minX,
                                                numberRect.minY + (numberRect.height - numberTextHeight) / 2,
                                                numberRect.width,
                                                numberTextHeight)
        NSGraphicsContext.saveGraphicsState()
        NSRectClip(numberRect)
        NSString(string: numeral).draw(in: numberTextRect.offsetBy(dx: 0, dy: 0), withAttributes: numberFontAttributes)
        NSGraphicsContext.restoreGraphicsState()
    }

    public class func drawCenteredKey(numeral: String = "1", isPressed: Bool = true) {
        //// General Declarations
        let _ = NSGraphicsContext.current()!.cgContext

        //// Color Declarations
        let pressedKeyColor = NSColor(calibratedRed: 0.655, green: 0.745, blue: 0.804, alpha: 1)
        let unpressedKeyColor = NSColor(calibratedRed: 0.937, green: 0.941, blue: 0.949, alpha: 1)
        let unpressedTextColor = NSColor(calibratedRed: 0, green: 0, blue: 0, alpha: 1)
        let pressedTextColor = NSColor(calibratedRed: 1, green: 0.992, blue: 0.988, alpha: 1)

        //// Variable Declarations
        let keyColor: NSColor = isPressed ? pressedKeyColor : unpressedKeyColor
        let textColor: NSColor = isPressed ? pressedTextColor : unpressedTextColor

        //// Oval Drawing
        let ovalPath = NSBezierPath(ovalIn: NSRect(x: 2, y: 2, width: 96, height: 96))
        keyColor.setFill()
        ovalPath.fill()
        NSColor.lightGray.setStroke()
        ovalPath.lineWidth = 2.5
        ovalPath.stroke()

        //// Number Drawing
        let numberRect = NSRect(x: 27, y: 27, width: 45, height: 46)
        let numberStyle = NSMutableParagraphStyle()
        numberStyle.alignment = .center

        let numberFontAttributes = [NSFontAttributeName: NSFont(name: "HelveticaNeue", size: 48)!,
                                    NSForegroundColorAttributeName: textColor,
                                    NSParagraphStyleAttributeName: numberStyle]

        let numberTextHeight: CGFloat = NSString(string: numeral).boundingRect(with: NSMakeSize(numberRect.width, CGFloat.infinity),
                                                                               options: NSStringDrawingOptions.usesLineFragmentOrigin,
                                                                               attributes: numberFontAttributes).size.height
        let numberTextRect: NSRect = NSMakeRect(numberRect.minX,
                                                numberRect.minY + (numberRect.height - numberTextHeight) / 2,
                                                numberRect.width,
                                                numberTextHeight)
        NSGraphicsContext.saveGraphicsState()
        NSRectClip(numberRect)
        NSString(string: numeral).draw(in: numberTextRect.offsetBy(dx: 0, dy: 0), withAttributes: numberFontAttributes)
        NSGraphicsContext.restoreGraphicsState()
    }
}
