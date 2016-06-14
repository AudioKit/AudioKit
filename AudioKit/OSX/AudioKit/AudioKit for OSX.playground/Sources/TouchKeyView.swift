//
//  TouchKeyView.swift
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright (c) 2015 Aurelius Prochazka. All rights reserved.
//

import Cocoa

public class TouchKeyView: NSButton {
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
    override public func draw(_ rect: CGRect) {
        drawKey(text: letters, numeral: number)
    }
    func drawKey(text: String = "A B C", numeral: String = "1") {
        
        //// Gradient Declarations
        let gradient = NSGradient(starting: NSColor.darkGray(), ending: NSColor.lightGray())!
        
        //// Rectangle Drawing
        let rectanglePath = NSBezierPath(roundedRect: NSMakeRect(0, 0, 100, 100), xRadius: 20, yRadius: 20)
        gradient.draw(in: rectanglePath, angle: -90)
        
        
        //// Letters Drawing
        let lettersRect = NSMakeRect(0, 73, 100, 21)
        let lettersStyle = NSParagraphStyle.default().mutableCopy() as! NSMutableParagraphStyle
        lettersStyle.alignment = .center
        
        let lettersFontAttributes = [NSFontAttributeName: NSFont(name: "HelveticaNeue", size: 25)!, NSForegroundColorAttributeName: NSColor.white(), NSParagraphStyleAttributeName: lettersStyle]
        
//        let lettersTextHeight: CGFloat = NSString(string: text).boundingRect(NSMakeSize(lettersRect.width, CGFloat.infinity), options: NSStringDrawingOptions.UsesLineFragmentOrigin, attributes: lettersFontAttributes).size.height
//        let lettersTextRect: NSRect = NSMakeRect(lettersRect.minX, lettersRect.minY + (lettersRect.height - lettersTextHeight) / 2, lettersRect.width, lettersTextHeight)
//        NSGraphicsContext.saveGraphicsState()
//        NSRectClip(lettersRect)
//        NSString(string: text).draw(rect: NSOffsetRect(lettersTextRect, 0, 0), withAttributes: lettersFontAttributes)
//        NSGraphicsContext.restoreGraphicsState()
//        
//        
//        //// Number Drawing
//        let numberRect = NSMakeRect(0, 0, 100, 73)
//        let numberStyle = NSParagraphStyle.default().mutableCopy() as! NSMutableParagraphStyle
//        numberStyle.alignment = .center
//        
//        let numberFontAttributes = [NSFontAttributeName: NSFont(name: "HelveticaNeue", size: 60)!, NSForegroundColorAttributeName: NSColor.white(), NSParagraphStyleAttributeName: numberStyle]
//        
//        let numberTextHeight: CGFloat = NSString(string: numeral).boundingRect(NSMakeSize(numberRect.width, CGFloat.infinity), options: NSStringDrawingOptions.UsesLineFragmentOrigin, attributes: numberFontAttributes).size.height
//        let numberTextRect: NSRect = NSMakeRect(numberRect.minX, numberRect.minY + (numberRect.height - numberTextHeight) / 2, numberRect.width, numberTextHeight)
//        NSGraphicsContext.saveGraphicsState()
//        NSRectClip(numberRect)
//        NSString(string: numeral).draw(NSOffsetRect(numberTextRect, 0, 0), withAttributes: numberFontAttributes)
//        NSGraphicsContext.restoreGraphicsState()
    }

}

extension AKPlaygroundView {
    public func addTouchKey(
        num: String, text: String, action: Selector) -> TouchKeyView {
        
        let newButton = TouchKeyView(numeral: num, text: text)
        
        // Line up multiple buttons in a row
        if let button = lastButton {
            newButton.frame.origin.x += button.frame.origin.x + button.frame.width + 10
            yPosition -= horizontalSpacing
            
        }
        horizontalSpacing = Int((newButton.frame.height)) + 10
        yPosition += horizontalSpacing
        
        newButton.frame.origin.y = self.bounds.height - CGFloat(yPosition)
        newButton.target = self
        newButton.action = action
        self.addSubview(newButton)
        
        lastButton = newButton
        return newButton
    }
}
