//
//  AKPropertySlider.swift
//  AudioKit for iOS
//
//  Created by Aurelius Prochazka on 7/28/16.
//  Copyright © 2016 AudioKit. All rights reserved.
//

import Foundation

@IBDesignable public class AKPropertySlider: UIView {
    
    @IBInspectable public var initialValue: Double = 0.5
    @IBInspectable public var minimum: Double = 0
    @IBInspectable public var maximum: Double = 1
    @IBInspectable public var property: String = "Property"
    @IBInspectable public var format: String = "%0.3f"
    @IBInspectable public var sliderColor: UIColor = UIColor.redColor()
    @IBInspectable public var textColor: UIColor = UIColor.whiteColor()
    @IBInspectable public var fontSize: CGFloat = 24
    
    public var callback: ((Double)->())?
    public var value: Double = 0 {
        didSet {
            setNeedsDisplay()
        }
    }
    public var lastTouch = CGPoint.zero

    public init(property: String,
                format: String = "%0.3f",
                value: Double,
                minimum: Double = 0,
                maximum: Double = 1,
                color: UIColor = UIColor.redColor(),
                frame: CGRect = CGRect(x: 0, y: 0, width: 440, height: 60),
                callback: (x: Double)->()) {
        self.value = value
        self.initialValue = value
        self.minimum = minimum
        self.maximum = maximum
        self.property = property
        self.format = format
        self.sliderColor = color


        self.callback = callback
        super.init(frame: frame)

        setNeedsDisplay()
    }

    override public init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required public init?(coder: NSCoder) {
        super.init(coder: coder)
        self.userInteractionEnabled = true
        self.value = initialValue
    }
    
    override public func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()
        clipsToBounds = true
    }
    
    public class override func requiresConstraintBasedLayout() -> Bool {
        return true
    }

    override public func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        if let touch = touches.first {
            let touchLocation = touch.locationInView(self)
            lastTouch = touchLocation
            value = Double(touchLocation.x / bounds.width) * (maximum - minimum) + minimum
            setNeedsDisplay()
            callback?(value)

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
                callback?(value)
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
        
        let width = self.frame.width
        let height = self.frame.height

        //// Variable Declarations
        let currentWidth: CGFloat = currentValue < minimum ? 0 : (currentValue < maximum ? (currentValue - minimum) / (maximum - minimum) * width : width)
        let initialX: CGFloat = initialValue < minimum ? 9 : 9 + (initialValue < maximum ? (initialValue - minimum) / (maximum - minimum) * width : width)

        //// sliderArea Drawing
        let sliderAreaPath = UIBezierPath(rect: CGRect(x: 0, y: 0, width: width, height: height))
        UIColor.clearColor().setFill()
        sliderAreaPath.fill()


        //// valueRectangle Drawing
        let valueRectanglePath = UIBezierPath(rect: CGRect(x: 0, y: 0, width: currentWidth, height: height))
        sliderColor.setFill()
        valueRectanglePath.fill()


        //// initialValueBezier Drawing
        CGContextSaveGState(context)
        CGContextTranslateCTM(context, (initialX - 8), -0)

        let initialValueBezierPath = UIBezierPath()
        initialValueBezierPath.moveToPoint(CGPoint(x: 0, y: 0))
        initialValueBezierPath.addLineToPoint(CGPoint(x: 0.25, y: height))
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
        let nameLabelRect = CGRect(x: 0, y: 0, width: width, height: height)
        let nameLabelStyle = NSMutableParagraphStyle()
        nameLabelStyle.alignment = .Left

        let nameLabelFontAttributes = [NSFontAttributeName: UIFont.boldSystemFontOfSize(fontSize), NSForegroundColorAttributeName: textColor, NSParagraphStyleAttributeName: nameLabelStyle]

        let nameLabelInset: CGRect = CGRectInset(nameLabelRect, 10, 0)
        let nameLabelTextHeight: CGFloat = NSString(string: propertyName).boundingRectWithSize(CGSize(width: nameLabelInset.width, height: CGFloat.infinity), options: NSStringDrawingOptions.UsesLineFragmentOrigin, attributes: nameLabelFontAttributes, context: nil).size.height
        CGContextSaveGState(context)
        CGContextClipToRect(context, nameLabelInset)
        NSString(string: propertyName).drawInRect(CGRect(x: nameLabelInset.minX, y: nameLabelInset.minY + (nameLabelInset.height - nameLabelTextHeight) / 2, width: nameLabelInset.width, height: nameLabelTextHeight), withAttributes: nameLabelFontAttributes)
        CGContextRestoreGState(context)


        //// valueLabel Drawing
        let valueLabelRect = CGRect(x: 0, y: 0, width: width, height: height)
        let valueLabelStyle = NSMutableParagraphStyle()
        valueLabelStyle.alignment = .Right

        let valueLabelFontAttributes = [NSFontAttributeName: UIFont.boldSystemFontOfSize(fontSize), NSForegroundColorAttributeName: textColor, NSParagraphStyleAttributeName: valueLabelStyle]

        let valueLabelInset: CGRect = CGRectInset(valueLabelRect, 10, 0)
        let valueLabelTextHeight: CGFloat = NSString(string: currentValueText).boundingRectWithSize(CGSize(width: valueLabelInset.width, height: CGFloat.infinity), options: NSStringDrawingOptions.UsesLineFragmentOrigin, attributes: valueLabelFontAttributes, context: nil).size.height
        CGContextSaveGState(context)
        CGContextClipToRect(context, valueLabelInset)
        NSString(string: currentValueText).drawInRect(CGRect(x: valueLabelInset.minX, y: valueLabelInset.minY + (valueLabelInset.height - valueLabelTextHeight) / 2, width: valueLabelInset.width, height: valueLabelTextHeight), withAttributes: valueLabelFontAttributes)
        CGContextRestoreGState(context)
    }

}
