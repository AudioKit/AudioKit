//
//  AKPropertySlider.swift
//  AudioKit for iOS
//
//  Created by Aurelius Prochazka on 7/28/16.
//  Copyright © 2016 AudioKit. All rights reserved.
//

import Foundation

public class AKPropertySlider: UIView {
    var callback: (Double)->()
    var initialValue: Double = 0
    public var value: Double = 0 {
        didSet {
            setNeedsDisplay()
        }
    }
    public var minimum: Double = 0
    public var maximum: Double = 0
    public var property: String = ""
    var format = ""
    var color = AKColor.redColor()
    public var lastTouch = CGPointZero
    
    public init(property: String,
                format: String = "%0.3f",
                value: Double,
                minimum: Double = 0,
                maximum: Double = 1,
                color: AKColor = AKColor.redColor(),
                frame: CGRect = CGRect(x: 0, y: 0, width: 440, height: 60),
                callback: (x: Double)->()) {
        self.value = value
        self.initialValue = value
        self.minimum = minimum
        self.maximum = maximum
        self.property = property
        self.format = format
        self.color = color

        
        self.callback = callback
        super.init(frame: frame)
        self.userInteractionEnabled = true
        
        setNeedsDisplay()
    }
    
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override public func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        if let touch = touches.first {
            let touchLocation = touch.locationInView(self)
            lastTouch = touchLocation
            value = Double(touchLocation.x / bounds.width) * (maximum - minimum) + minimum
            setNeedsDisplay()
            callback(value)

        }
    }
    
    override public func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?) {
        if let touch = touches.first {
            let touchLocation = touch.locationInView(self)
            if lastTouch.x != touchLocation.x {
                value = Double(touchLocation.x / bounds.width) * (maximum - minimum) + minimum
                if value > maximum { value = maximum }
                if value < minimum { value = minimum }
                setNeedsDisplay()
                callback(value)
                lastTouch = touchLocation
            }
        }
    }
    
    public func randomize() -> Double {
        value = random(minimum, maximum)
        setNeedsDisplay()
        return value
    }
    
    override public func drawRect(rect: CGRect) {
        drawFlatSlider(currentValue: CGFloat(value),
            initialValue: CGFloat(initialValue),
            minimum: CGFloat(minimum),
            maximum: CGFloat(maximum),
            propertyName: property,
            currentValueText: String(format: format, value)
        )
    }
    
    func drawFlatSlider(currentValue currentValue: CGFloat = 0, initialValue: CGFloat = 0, minimum: CGFloat = 0, maximum: CGFloat = 1, propertyName: String = "Property Name", currentValueText: String = "0.0") {
        //// General Declarations
        let context = UIGraphicsGetCurrentContext()
        
        //// Color Declarations
        let backgroundColor = UIColor(red: 0.835, green: 0.842, blue: 0.836, alpha: 0.925)
        let sliderColor = color //UIColor(red: 1.000, green: 0.000, blue: 0.062, alpha: 1.000)
        
        //// Variable Declarations
        let currentWidth: CGFloat = currentValue < minimum ? 0 : (currentValue < maximum ? (currentValue - minimum) / (maximum - minimum) * 440 : 440)
        let initialX: CGFloat = initialValue < minimum ? 9 : 9 + (initialValue < maximum ? (initialValue - minimum) / (maximum - minimum) * 440 : 440)
        
        //// sliderArea Drawing
        let sliderAreaPath = UIBezierPath(rect: CGRect(x: 0, y: 0, width: 440, height: 60))
        backgroundColor.setFill()
        sliderAreaPath.fill()
        
        
        //// valueRectangle Drawing
        let valueRectanglePath = UIBezierPath(rect: CGRect(x: 0, y: 0, width: currentWidth, height: 60))
        sliderColor.setFill()
        valueRectanglePath.fill()
        
        
        //// initialValueBezier Drawing
        CGContextSaveGState(context)
        CGContextTranslateCTM(context, (initialX - 8), -0)
        
        let initialValueBezierPath = UIBezierPath()
        initialValueBezierPath.moveToPoint(CGPoint(x: 0, y: 0))
        initialValueBezierPath.addLineToPoint(CGPoint(x: 0.25, y: 60))
        UIColor.whiteColor().setFill()
        initialValueBezierPath.fill()
        UIColor.blackColor().setStroke()
        initialValueBezierPath.lineWidth = 0.5
        CGContextSaveGState(context)
        CGContextSetLineDash(context, 0, [2, 2], 2)
        initialValueBezierPath.stroke()
        CGContextRestoreGState(context)
        
        CGContextRestoreGState(context)
        
        
        //// nameLabel Drawing
        let nameLabelRect = CGRect(x: 0, y: 0, width: 440, height: 60)
        let nameLabelStyle = NSMutableParagraphStyle()
        nameLabelStyle.alignment = .Left
        
        let nameLabelFontAttributes = [NSFontAttributeName: UIFont.boldSystemFontOfSize(24), NSForegroundColorAttributeName: UIColor.blackColor(), NSParagraphStyleAttributeName: nameLabelStyle]
        
        let nameLabelInset: CGRect = CGRectInset(nameLabelRect, 10, 0)
        let nameLabelTextHeight: CGFloat = NSString(string: propertyName).boundingRectWithSize(CGSize(width: nameLabelInset.width, height: CGFloat.infinity), options: NSStringDrawingOptions.UsesLineFragmentOrigin, attributes: nameLabelFontAttributes, context: nil).size.height
        CGContextSaveGState(context)
        CGContextClipToRect(context, nameLabelInset)
        NSString(string: propertyName).drawInRect(CGRect(x: nameLabelInset.minX, y: nameLabelInset.minY + (nameLabelInset.height - nameLabelTextHeight) / 2, width: nameLabelInset.width, height: nameLabelTextHeight), withAttributes: nameLabelFontAttributes)
        CGContextRestoreGState(context)
        
        
        //// valueLabel Drawing
        let valueLabelRect = CGRect(x: 0, y: 0, width: 440, height: 60)
        let valueLabelStyle = NSMutableParagraphStyle()
        valueLabelStyle.alignment = .Right
        
        let valueLabelFontAttributes = [NSFontAttributeName: UIFont.boldSystemFontOfSize(24), NSForegroundColorAttributeName: UIColor.blackColor(), NSParagraphStyleAttributeName: valueLabelStyle]
        
        let valueLabelInset: CGRect = CGRectInset(valueLabelRect, 10, 0)
        let valueLabelTextHeight: CGFloat = NSString(string: currentValueText).boundingRectWithSize(CGSize(width: valueLabelInset.width, height: CGFloat.infinity), options: NSStringDrawingOptions.UsesLineFragmentOrigin, attributes: valueLabelFontAttributes, context: nil).size.height
        CGContextSaveGState(context)
        CGContextClipToRect(context, valueLabelInset)
        NSString(string: currentValueText).drawInRect(CGRect(x: valueLabelInset.minX, y: valueLabelInset.minY + (valueLabelInset.height - valueLabelTextHeight) / 2, width: valueLabelInset.width, height: valueLabelTextHeight), withAttributes: valueLabelFontAttributes)
        CGContextRestoreGState(context)
    }

}