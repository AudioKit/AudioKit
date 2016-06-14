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
    public override func draw(_ rect: CGRect) {
        drawKey(text: letters, numeral: number)
    }
    func drawKey(text: String = "A B C", numeral: String = "1") {
        //// General Declarations
        let context = UIGraphicsGetCurrentContext()
        
        //// Oval Drawing
        let ovalPath = UIBezierPath.init(ovalIn: CGRect(x: 2, y: 2, width: 96, height: 96))
        UIColor.lightGray().setStroke()
        ovalPath.lineWidth = 2.5
        ovalPath.stroke()
        
        
        //// Letters Drawing
        let lettersRect = CGRect(x: 0, y: 0, width: 100, height: 81)
        let lettersStyle = NSMutableParagraphStyle()
        lettersStyle.alignment = .center
        
        let lettersFontAttributes = [NSFontAttributeName: UIFont.systemFont(ofSize: 15), NSForegroundColorAttributeName: UIColor.black(), NSParagraphStyleAttributeName: lettersStyle]
        
        let lettersTextHeight: CGFloat = NSString(string: text).boundingRect(with: CGSize(width: lettersRect.width, height: CGFloat.infinity), options: NSStringDrawingOptions.usesLineFragmentOrigin, attributes: lettersFontAttributes, context: nil).size.height
        context!.saveGState()
        context!.clipTo(lettersRect)
//        NSString(string: text).draw(rect: CGRect(x: lettersRect.minX, y: lettersRect.minY + lettersRect.height - lettersTextHeight, width: lettersRect.width, height: lettersTextHeight), withAttributes: lettersFontAttributes)
        context!.restoreGState()
        
        //// Number Drawing
        let numberRect = CGRect(x: 0, y: 0, width: 100, height: 75)
        let numberStyle = NSMutableParagraphStyle()
        numberStyle.setParagraphStyle(NSParagraphStyle.default())
        numberStyle.alignment = .center
        
        let numberFontAttributes = [NSFontAttributeName: UIFont.systemFont(ofSize: 48), NSForegroundColorAttributeName: UIColor.black(), NSParagraphStyleAttributeName: numberStyle]
        
        let numberTextHeight: CGFloat = NSString(string: numeral).boundingRect(with: CGSize(width: numberRect.width, height: CGFloat.infinity), options: NSStringDrawingOptions.usesLineFragmentOrigin, attributes: numberFontAttributes, context: nil).size.height
        context!.saveGState()
        context!.clipTo(numberRect)
//        NSString(string: numeral).draw(CGRect(x: numberRect.minX, y: numberRect.minY + (numberRect.height - numberTextHeight) / 2, width: numberRect.width, height: numberTextHeight), withAttributes: numberFontAttributes)
        context!.restoreGState()
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
        newButton.addTarget(self, action: action, for: .touchDown)
        //        newButton.sizeToFit()
        self.addSubview(newButton)
        horizontalSpacing = Int((newButton.frame.height)) + 10
        yPosition += horizontalSpacing
        
        lastButton = newButton
        return newButton
    }
}
