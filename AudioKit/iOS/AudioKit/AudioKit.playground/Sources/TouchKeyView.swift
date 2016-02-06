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
    func drawKey(text text: String = "", numeral: String = "2") {
        //// General Declarations
        let context = UIGraphicsGetCurrentContext()
        
        
        //// Gradient Declarations
        let gradient = CGGradientCreateWithColors(CGColorSpaceCreateDeviceRGB(), [UIColor.darkGrayColor().CGColor, UIColor.lightGrayColor().CGColor], [0, 1])!
        
        //// Rectangle Drawing
        let rectanglePath = UIBezierPath(roundedRect: CGRectMake(0, 0, 100, 100), cornerRadius: 20)
        CGContextSaveGState(context)
        rectanglePath.addClip()
        CGContextDrawLinearGradient(context, gradient, CGPointMake(50, -0), CGPointMake(50, 100), CGGradientDrawingOptions())
        CGContextRestoreGState(context)
        
        
        //// Letters Drawing
        let lettersRect = CGRectMake(0, 6, 100, 21)
        let lettersStyle = NSParagraphStyle.defaultParagraphStyle().mutableCopy() as! NSMutableParagraphStyle
        lettersStyle.alignment = .Center
        
        let lettersFontAttributes = [NSFontAttributeName: UIFont.systemFontOfSize(25), NSForegroundColorAttributeName: UIColor.whiteColor(), NSParagraphStyleAttributeName: lettersStyle]
        
        let lettersTextHeight: CGFloat = NSString(string: text).boundingRectWithSize(CGSizeMake(lettersRect.width, CGFloat.infinity), options: NSStringDrawingOptions.UsesLineFragmentOrigin, attributes: lettersFontAttributes, context: nil).size.height
        CGContextSaveGState(context)
        CGContextClipToRect(context, lettersRect);
        NSString(string: letters).drawInRect(CGRectMake(lettersRect.minX, lettersRect.minY + (lettersRect.height - lettersTextHeight) / 2, lettersRect.width, lettersTextHeight), withAttributes: lettersFontAttributes)
        CGContextRestoreGState(context)
        
        
        //// Number Drawing
        let numberRect = CGRectMake(0, 27, 100, 73)
        let numberStyle = NSParagraphStyle.defaultParagraphStyle().mutableCopy() as! NSMutableParagraphStyle
        numberStyle.alignment = .Center
        
        let numberFontAttributes = [NSFontAttributeName: UIFont.boldSystemFontOfSize(60), NSForegroundColorAttributeName: UIColor.whiteColor(), NSParagraphStyleAttributeName: numberStyle]
        
        let numberTextHeight: CGFloat = NSString(string: number).boundingRectWithSize(CGSizeMake(numberRect.width, CGFloat.infinity), options: NSStringDrawingOptions.UsesLineFragmentOrigin, attributes: numberFontAttributes, context: nil).size.height
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
