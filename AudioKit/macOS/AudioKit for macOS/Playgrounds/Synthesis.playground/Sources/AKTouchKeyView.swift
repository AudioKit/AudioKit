//
//  TouchKeyView.swift
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright (c) 2015 Aurelius Prochazka. All rights reserved.
//

import Cocoa

public class AKTouchKeyView: NSButton {
    public var letters = ""
    public var number = "1"
    public init(numeral: String = "1", text: String = "") {
        super.init(frame:
            CGRect(x:0, y:0, width:100, height: 100))
        letters = text
        number = numeral
    }

    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override public func drawRect(rect: CGRect) {
        drawKey(text: letters, numeral: number)
    }

    func drawKey(text text: String = "A B C", numeral: String = "1") {

        //// Gradient Declarations
        let gradient = NSGradient(startingColor: NSColor.darkGrayColor(),
                                  endingColor: NSColor.lightGrayColor())!

        //// Rectangle Drawing
        let rectanglePath = NSBezierPath(roundedRect: NSMakeRect(0, 0, 100, 100),
                                         xRadius: 20,
                                         yRadius: 20)
        gradient.drawInBezierPath(rectanglePath, angle: -90)

        //// Letters Drawing
        let lettersRect = NSMakeRect(0, 73, 100, 21)
        let lettersStyle = NSParagraphStyle.defaultParagraphStyle().mutableCopy() as! NSMutableParagraphStyle
        lettersStyle.alignment = .Center

        let lettersFontAttributes = [NSFontAttributeName: NSFont(name: "HelveticaNeue", size: 25)!,
                                     NSForegroundColorAttributeName: NSColor.whiteColor(),
                                     NSParagraphStyleAttributeName: lettersStyle]

        let lettersTextHeight: CGFloat = NSString(string: text)
            .boundingRectWithSize(NSMakeSize(lettersRect.width, CGFloat.infinity),
                                  options: NSStringDrawingOptions.UsesLineFragmentOrigin,
                                  attributes: lettersFontAttributes)
            .size.height

        let lettersTextRect: NSRect =
            NSMakeRect(lettersRect.minX,
                       lettersRect.minY + (lettersRect.height - lettersTextHeight) / 2,
                       lettersRect.width,
                       lettersTextHeight)
        NSGraphicsContext.saveGraphicsState()
        NSRectClip(lettersRect)
        NSString(string: text).drawInRect(NSOffsetRect(lettersTextRect, 0, 0),
                                          withAttributes: lettersFontAttributes)
        NSGraphicsContext.restoreGraphicsState()


        //// Number Drawing
        let numberRect = NSMakeRect(0, 0, 100, 73)
        let numberStyle = NSParagraphStyle.defaultParagraphStyle().mutableCopy() as! NSMutableParagraphStyle
        numberStyle.alignment = .Center

        let numberFontAttributes = [NSFontAttributeName: NSFont(name: "HelveticaNeue", size: 60)!,
                                    NSForegroundColorAttributeName: NSColor.whiteColor(),
                                    NSParagraphStyleAttributeName: numberStyle]

        let numberTextHeight: CGFloat = NSString(string: numeral)
            .boundingRectWithSize(NSMakeSize(numberRect.width, CGFloat.infinity),
                                  options: NSStringDrawingOptions.UsesLineFragmentOrigin,
                                  attributes: numberFontAttributes).size.height
        let numberTextRect: NSRect =
            NSMakeRect(numberRect.minX,
                       numberRect.minY + (numberRect.height - numberTextHeight) / 2,
                       numberRect.width, numberTextHeight)
        NSGraphicsContext.saveGraphicsState()
        NSRectClip(numberRect)
        NSString(string: numeral).drawInRect(NSOffsetRect(numberTextRect, 0, 0),
                                             withAttributes: numberFontAttributes)
        NSGraphicsContext.restoreGraphicsState()
    }

}

//extension AKPlaygroundView {
//    public func addTouchKey(
//        num: String, text: String, action: Selector) -> AKTouchKeyView {
//
//        let newButton = AKTouchKeyView(numeral: num, text: text)
//
//        // Line up multiple buttons in a row
//        if let button = lastButton {
//            newButton.frame.origin.x += button.frame.origin.x + button.frame.width + 10
//            yPosition -= spacing
//        }
//        spacing = Int((newButton.frame.height)) + 10
//        yPosition += spacing
//
//        newButton.frame.origin.y = self.bounds.height - CGFloat(yPosition)
//        newButton.target = self
//        newButton.action = action
//        super.addSubview(newButton)
//
//        lastButton = newButton
//        return newButton
//    }
//}
