//
//  AKTelephoneView.swift
//  AudioKit for macOS
//
//  Created by Aurelius Prochazka on 7/31/16.
//  Copyright © 2017 Aurelius Prochazka. All rights reserved.
//

/// This is primarily for the telephone page in the Synthesis playground
public class AKTelephoneView: NSView {

    var keyRects = [String: CGRect]()
    var callCirclePath = NSBezierPath()
    var busyCirclePath = NSBezierPath()

    var last10Presses = [String](repeating: "", count: 10)
    var currentKey = ""
    var callback: (String, String) -> Void

    override public func mouseDown(with theEvent: NSEvent) {
        let touchLocation = convert(theEvent.locationInWindow, from: nil)

        for key in keyRects.keys {
            guard let rect = keyRects[key] else {
                return
            }
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

    func setupKeyDrawing(context: CGContext?, x: Int, y: Int) -> CGRect {
        let keyRect = NSRect(x: x, y: y, width: 82, height: 82)
        NSGraphicsContext.saveGraphicsState()
        NSRectClip(keyRect)
        context?.translateBy(x: keyRect.origin.x, y: keyRect.origin.y)
        context?.scaleBy(x: keyRect.size.width / 100, y: keyRect.size.height / 100)
        return keyRect
    }

    override public func draw(_ rect: CGRect) {
        //// General Declarations
        let context = NSGraphicsContext.current()?.cgContext

        //// Color Declarations
        let color = #colorLiteral(red: 0.306, green: 0.851, blue: 0.392, alpha: 1)
        let color2 = #colorLiteral(red: 1, green: 0.151, blue: 0, alpha: 1)
        let unpressedKeyColor = #colorLiteral(red: 0.937, green: 0.941, blue: 0.949, alpha: 1)

        //// Background Drawing
        let backgroundPath = NSBezierPath(rect: NSRect(x: 1, y: 0, width: 440, height: 782))
        unpressedKeyColor.setFill()
        backgroundPath.fill()

        keyRects["1"] = setupKeyDrawing(context: context, x: 70, y: 494)
        AKTelephoneView.drawKey(text: "\n", numeral: "1", isPressed: currentKey == "1")
        NSGraphicsContext.restoreGraphicsState()

        keyRects["2"] = setupKeyDrawing(context: context, x: 179, y: 495)
        AKTelephoneView.drawKey(text: "A B C", numeral: "2", isPressed: currentKey == "2")
        NSGraphicsContext.restoreGraphicsState()

        keyRects["3"] = setupKeyDrawing(context: context, x: 288, y: 495)
        AKTelephoneView.drawKey(text: "D E F", numeral: "3", isPressed: currentKey == "3")
        NSGraphicsContext.restoreGraphicsState()

        keyRects["4"] = setupKeyDrawing(context: context, x: 70, y: 398)
        AKTelephoneView.drawKey(text: "G H I", numeral: "4", isPressed: currentKey == "4")
        NSGraphicsContext.restoreGraphicsState()

        keyRects["5"] = setupKeyDrawing(context: context, x: 179, y: 398)
        AKTelephoneView.drawKey(text: "J K L", numeral: "5", isPressed: currentKey == "5")
        NSGraphicsContext.restoreGraphicsState()

        keyRects["6"] = setupKeyDrawing(context: context, x: 288, y: 398)
        AKTelephoneView.drawKey(text: "M N O", numeral: "6", isPressed: currentKey == "6")
        NSGraphicsContext.restoreGraphicsState()

        keyRects["7"] = setupKeyDrawing(context: context, x: 70, y: 303)
        AKTelephoneView.drawKey(text: "P Q R S", numeral: "7", isPressed: currentKey == "7")
        NSGraphicsContext.restoreGraphicsState()

        keyRects["8"] = setupKeyDrawing(context: context, x: 179, y: 303)
        AKTelephoneView.drawKey(text: "T U V", numeral: "8", isPressed: currentKey == "8")
        NSGraphicsContext.restoreGraphicsState()

        keyRects["9"] = setupKeyDrawing(context: context, x: 288, y: 303)
        AKTelephoneView.drawKey(text: "W X Y Z", numeral: "9", isPressed: currentKey == "9")
        NSGraphicsContext.restoreGraphicsState()

        keyRects["0"] = setupKeyDrawing(context: context, x: 179, y: 206)
        AKTelephoneView.drawKey(text: "+", numeral: "0", isPressed: currentKey == "0")
        NSGraphicsContext.restoreGraphicsState()

        keyRects["*"] = setupKeyDrawing(context: context, x: 70, y: 206)
        AKTelephoneView.drawCenteredKey(numeral: "*", isPressed: currentKey == "*")
        NSGraphicsContext.restoreGraphicsState()

        keyRects["#"] = setupKeyDrawing(context: context, x: 288, y: 206)
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

        let busyTextTextHeight: CGFloat = busyTextTextContent.boundingRect(
            with: NSSize(width: busyTextRect.width, height: CGFloat.infinity),
            options: NSStringDrawingOptions.usesLineFragmentOrigin,
            attributes: busyTextFontAttributes).size.height
        let busyTextTextRect: NSRect = NSRect(
            x: busyTextRect.minX,
            y: busyTextRect.minY + (busyTextRect.height - busyTextTextHeight) / 2,
            width: busyTextRect.width,
            height: busyTextTextHeight)
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

        let readoutTextHeight: CGFloat = readoutTextContent.boundingRect(
            with: NSSize(width: readoutRect.width, height: CGFloat.infinity),
            options: NSStringDrawingOptions.usesLineFragmentOrigin,
            attributes: readoutFontAttributes).size.height
        let readoutTextRect: NSRect = NSRect(
            x: readoutRect.minX,
            y: readoutRect.minY + (readoutRect.height - readoutTextHeight) / 2,
            width: readoutRect.width,
            height: readoutTextHeight)
        NSGraphicsContext.saveGraphicsState()
        NSRectClip(readoutRect)
        readoutTextContent.draw(in: readoutTextRect.offsetBy(dx: 0, dy: 0), withAttributes: readoutFontAttributes)
        NSGraphicsContext.restoreGraphicsState()
    }

    public class func drawKey(text: String = "A B C", numeral: String = "1", isPressed: Bool = true) {
        //// General Declarations
        let _ = NSGraphicsContext.current()?.cgContext

        //// Color Declarations
        let pressedKeyColor = #colorLiteral(red: 0.655, green: 0.745, blue: 0.804, alpha: 1)
        let unpressedKeyColor = #colorLiteral(red: 0.937, green: 0.941, blue: 0.949, alpha: 1)
        let unpressedTextColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
        let pressedTextColor = #colorLiteral(red: 1, green: 0.992, blue: 0.988, alpha: 1)

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

        let lettersTextHeight: CGFloat = NSString(string: text).boundingRect(
            with: NSSize(width: lettersRect.width, height: CGFloat.infinity),
            options: NSStringDrawingOptions.usesLineFragmentOrigin,
            attributes: lettersFontAttributes).size.height
        let lettersTextRect: NSRect = NSRect(
            x: lettersRect.minX,
            y: lettersRect.minY + (lettersRect.height - lettersTextHeight) / 2,
            width: lettersRect.width,
            height: lettersTextHeight)
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

        let numberTextHeight: CGFloat = NSString(string: numeral).boundingRect(
            with: NSSize(width: numberRect.width, height: CGFloat.infinity),
            options: NSStringDrawingOptions.usesLineFragmentOrigin,
            attributes: numberFontAttributes).size.height
        let numberTextRect: NSRect = NSRect(
            x: numberRect.minX,
            y: numberRect.minY + (numberRect.height - numberTextHeight) / 2,
            width: numberRect.width,
            height: numberTextHeight)
        NSGraphicsContext.saveGraphicsState()
        NSRectClip(numberRect)
        NSString(string: numeral).draw(in: numberTextRect.offsetBy(dx: 0, dy: 0), withAttributes: numberFontAttributes)
        NSGraphicsContext.restoreGraphicsState()
    }

    public class func drawCenteredKey(numeral: String = "1", isPressed: Bool = true) {
        //// General Declarations
        let _ = NSGraphicsContext.current()?.cgContext

        //// Color Declarations
        let pressedKeyColor = #colorLiteral(red: 0.655, green: 0.745, blue: 0.804, alpha: 1)
        let unpressedKeyColor = #colorLiteral(red: 0.937, green: 0.941, blue: 0.949, alpha: 1)
        let unpressedTextColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
        let pressedTextColor = #colorLiteral(red: 1, green: 0.992, blue: 0.988, alpha: 1)

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

        let numberTextHeight: CGFloat = NSString(string: numeral).boundingRect(
            with: NSSize(width: numberRect.width, height: CGFloat.infinity),
            options: NSStringDrawingOptions.usesLineFragmentOrigin,
            attributes: numberFontAttributes).size.height
        let numberTextRect: NSRect = NSRect(
            x: numberRect.minX,
            y: numberRect.minY + (numberRect.height - numberTextHeight) / 2,
            width: numberRect.width,
            height: numberTextHeight)
        NSGraphicsContext.saveGraphicsState()
        NSRectClip(numberRect)
        NSString(string: numeral).draw(in: numberTextRect.offsetBy(dx: 0, dy: 0), withAttributes: numberFontAttributes)
        NSGraphicsContext.restoreGraphicsState()
    }
}
