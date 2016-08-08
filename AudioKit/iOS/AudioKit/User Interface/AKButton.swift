//
//  AKButton.swift
//  AudioKit for iOS
//
//  Created by Aurelius Prochazka on 7/30/16.
//  Copyright © 2016 AudioKit. All rights reserved.
//

import Foundation

public class AKButton: UIView {
    internal var callback: ()->(String)
    public var title: String {
        didSet {
            setNeedsDisplay()
        }
    }
    public var color: UIColor {
        didSet {
            setNeedsDisplay()
        }
    }
    
    override public func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        let newTitle = callback()
        if newTitle != "" { title = newTitle }
    }
    
    public init(title: String,
                color: UIColor = UIColor(red: 0.029, green: 1.000, blue: 0.000, alpha: 1.000),
                frame: CGRect = CGRect(x: 0, y: 0, width: 440, height: 60),
                callback: ()->(String)) {
        self.title = title
        self.callback = callback
        self.color = color
        super.init(frame: frame)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func drawButton() {
        //// General Declarations
        let context = UIGraphicsGetCurrentContext()

        let outerPath = UIBezierPath(rect: CGRect(x: 0, y: 0, width: 440, height: 60))
        color.setFill()
        outerPath.fill()
        
        
        let labelRect = CGRect(x: 0, y: 0, width: 440, height: 60)
        let labelStyle = NSMutableParagraphStyle()
        labelStyle.alignment = .Center
        
        let labelFontAttributes = [NSFontAttributeName: UIFont.boldSystemFontOfSize(24), NSForegroundColorAttributeName: UIColor.blackColor(), NSParagraphStyleAttributeName: labelStyle]
        
        let labelInset: CGRect = CGRectInset(labelRect, 10, 0)
        let labelTextHeight: CGFloat = NSString(string: title).boundingRectWithSize(CGSize(width: labelInset.width, height: CGFloat.infinity), options: NSStringDrawingOptions.UsesLineFragmentOrigin, attributes: labelFontAttributes, context: nil).size.height
        CGContextSaveGState(context)
        CGContextClipToRect(context, labelInset)
        NSString(string: title).drawInRect(CGRect(x: labelInset.minX, y: labelInset.minY + (labelInset.height - labelTextHeight) / 2, width: labelInset.width, height: labelTextHeight), withAttributes: labelFontAttributes)
        CGContextRestoreGState(context)
        
    }
    
    override public func drawRect(rect: CGRect) {
        drawButton()
    }
}