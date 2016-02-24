//
//  TouchKeyView.swift
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright (c) 2015 Aurelius Prochazka. All rights reserved.
//

import UIKit

public class TouchKeyView: UIButton {
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
    public override func drawRect(rect: CGRect) {
        drawKey(text: letters, numeral: number)
    }
    func drawKey(text text: String = "A B C", numeral: String = "1") {
        //// General Declarations
        let context = UIGraphicsGetCurrentContext()
        
        //// Oval Drawing
        let ovalPath = UIBezierPath(ovalInRect: CGRectMake(2, 2, 96, 96))
        UIColor.lightGrayColor().setStroke()
        ovalPath.lineWidth = 2.5
        ovalPath.stroke()
        
        
        //// Letters Drawing
        let lettersRect = CGRectMake(0, 0, 100, 81)
        let lettersStyle = NSParagraphStyle.defaultParagraphStyle().mutableCopy() as! NSMutableParagraphStyle
        lettersStyle.alignment = .Center
        
        let lettersFontAttributes = [NSFontAttributeName: UIFont.systemFontOfSize(15), NSForegroundColorAttributeName: UIColor.blackColor(), NSParagraphStyleAttributeName: lettersStyle]
        
        let lettersTextHeight: CGFloat = NSString(string: text).boundingRectWithSize(CGSizeMake(lettersRect.width, CGFloat.infinity), options: NSStringDrawingOptions.UsesLineFragmentOrigin, attributes: lettersFontAttributes, context: nil).size.height
        CGContextSaveGState(context)
        CGContextClipToRect(context, lettersRect);
        NSString(string: text).drawInRect(CGRectMake(lettersRect.minX, lettersRect.minY + lettersRect.height - lettersTextHeight, lettersRect.width, lettersTextHeight), withAttributes: lettersFontAttributes)
        CGContextRestoreGState(context)
        
        
        //// Number Drawing
        let numberRect = CGRectMake(0, 0, 100, 75)
        let numberStyle = NSParagraphStyle.defaultParagraphStyle().mutableCopy() as! NSMutableParagraphStyle
        numberStyle.alignment = .Center
        
        let numberFontAttributes = [NSFontAttributeName: UIFont.systemFontOfSize(48), NSForegroundColorAttributeName: UIColor.blackColor(), NSParagraphStyleAttributeName: numberStyle]
        
        let numberTextHeight: CGFloat = NSString(string: numeral).boundingRectWithSize(CGSizeMake(numberRect.width, CGFloat.infinity), options: NSStringDrawingOptions.UsesLineFragmentOrigin, attributes: numberFontAttributes, context: nil).size.height
        CGContextSaveGState(context)
        CGContextClipToRect(context, numberRect);
        NSString(string: numeral).drawInRect(CGRectMake(numberRect.minX, numberRect.minY + (numberRect.height - numberTextHeight) / 2, numberRect.width, numberTextHeight), withAttributes: numberFontAttributes)
        CGContextRestoreGState(context)
    }

}

extension AKPlaygroundView {
    public func addTouchKey(
        num: String, text: String, action: Selector) -> TouchKeyView {
        
        let newButton = TouchKeyView(numeral: num, text: text)
        
        // Line up multiple buttons in a row
        if let button = lastButton {
            newButton.frame.origin.x += button.frame.origin.x + button.frame.width + 10
            yPosition = Int(button.frame.origin.y)
            
        }
        
        newButton.frame.origin.y = CGFloat(yPosition)
        newButton.addTarget(self, action: action, forControlEvents: .TouchDown)
        //        newButton.sizeToFit()
        self.addSubview(newButton)
        horizontalSpacing = Int((newButton.frame.height)) + 10
        yPosition += horizontalSpacing
        
        lastButton = newButton
        return newButton
    }
}
