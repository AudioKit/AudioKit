//
//  AKBypassButton.swift
//  AudioKit for iOS
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright © 2017 Aurelius Prochazka. All rights reserved.
//

import UIKit

public enum AKRotaryKnobTheme {
    case light
    case dark
}

@IBDesignable open class AKRotaryKnob: UIView {
    
    // Default side
    static var defaultSize = CGSize(width: 150.0, height: 170.0)
    
    // Default margin size 
    static var marginSize: CGFloat = 30.0
    
    // Indicator point radius
    static var indicatorPointRadius: CGFloat = 3.0
    
    // Padding surrounding the text inside the value bubble
    static var bubblePadding: CGSize = CGSize(width: 10.0, height: 2.0)
    
    // Margin between the top of the tap and the value bubble
    static var bubbleMargin: CGFloat = 3.0
    
    // Corner radius for the value bubble
    static var bubbleCornerRadius: CGFloat = 2.0

    /// Current value of the slider
    @IBInspectable open var value: Double = 0 {
        didSet {
            setNeedsDisplay()
        }
    }
    
    /// Minimum, left-most value
    @IBInspectable open var minimum: Double = 0
    
    /// Maximum, right-most value
    @IBInspectable open var maximum: Double = 1
    
    /// Text shown on the knob
    @IBInspectable open var property: String = "Property"
    
    /// Format for the number shown on the knob
    @IBInspectable open var format: String = "%0.3f"
    
    /// Background color
    @IBInspectable open var bgColor: UIColor?
    
    /// Knob border color
    @IBInspectable open var knobBorderColor: UIColor?
    
    /// Knob indicator color
    @IBInspectable open var indicatorColor: UIColor?
    
    /// Knob overlay color
    @IBInspectable open var knobColor: UIColor = .red
    
    /// Text color
    @IBInspectable open var textColor: UIColor?
    
    /// Font size
    @IBInspectable open var fontSize: CGFloat = 20
    
    /// Bubble font size
    @IBInspectable open var bubbleFontSize: CGFloat = 12
    
    // Knob theme
    @IBInspectable open var knobTheme: AKRotaryKnobTheme = AKRotaryKnobTheme.light

    // Border width
    @IBInspectable open var knobBorderWidth: CGFloat = 6.0
    
    // Value bubble border width
    @IBInspectable open var valueBubbleBorderWidth: CGFloat = 1.0
    
    // Number of indicator points
    @IBInspectable open var numberOfIndicatorPoints = 10
    
    // Current dragging state, used to show/hide the value bubble
    private var isDragging: Bool = false
    
    // Calculate knob center
    private var knobCenter: CGPoint = CGPoint.zero
    
    /// Function to call when value changes
    open var callback: ((Double) -> Void)?
    fileprivate var lastTouch = CGPoint.zero
    
    /// Initialize the slider
    public init(property: String,
                format: String = "%0.3f",
                value: Double,
                minimum: Double = 0,
                maximum: Double = 1,
                color: UIColor = UIColor.red,
                frame: CGRect = CGRect(x: 0, y: 0, width: AKRotaryKnob.defaultSize.width, height: AKRotaryKnob.defaultSize.height),
                callback: @escaping (_ x: Double) -> Void) {
        self.value = value
        self.minimum = minimum
        self.maximum = maximum
        self.property = property
        self.format = format
        self.knobColor = color
        
        self.callback = callback
        super.init(frame: frame)
        
        self.backgroundColor = UIColor.clear
        
        setNeedsDisplay()
    }
    
    /// Initialization with no details
    override public init(frame: CGRect) {
        super.init(frame: frame)
        
        self.backgroundColor = UIColor.clear
        contentMode = .redraw
    }
    
    /// Initialization within Interface Builder
    required public init?(coder: NSCoder) {
        super.init(coder: coder)
        
        self.isUserInteractionEnabled = true
        self.backgroundColor = UIColor.clear
        contentMode = .redraw
    }
    
    /// Actions to perform to make sure the view is renderable in Interface Builder
    override open func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()
        clipsToBounds = true
    }
    
    func angleBetween(pointA: CGPoint, pointB: CGPoint) -> Double {
        let dx = Double(pointB.x - pointA.x)
        let dy = Double(pointB.y - pointA.y)
        let radians = atan2(-dx, dy)
        let degrees = radians * 180 / Double.pi
        return degrees
    }
    
    /// Handle new touches
    override open func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first {
            isDragging = true
            let touchLocation = touch.location(in: self)
            lastTouch = touchLocation
            let angle = angleBetween(pointA: knobCenter, pointB: touchLocation)
            if angle < 0.0 {
                value = (maximum - minimum) * (0.5 + (180.0 + angle) / (260.0))
            } else {
                value = (maximum - minimum) * ((angle - 50.0) / 130.0) * 0.5
            }
            if value > maximum { value = maximum }
            if value < minimum { value = minimum }
            setNeedsDisplay()
            callback?(value)
        }
    }
    
    /// Handle moved touches
    override open func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first {
            let touchLocation = touch.location(in: self)
            if lastTouch.x != touchLocation.x {
                let angle = angleBetween(pointA: knobCenter, pointB: touchLocation)
                if angle < 0.0 {
                    value = (maximum - minimum) * (0.5 + (180.0 + angle) / (260.0))
                } else {
                    value = (maximum - minimum) * ((angle - 50.0) / 130.0) * 0.5
                }
                if value > maximum { value = maximum }
                if value < minimum { value = minimum }
                setNeedsDisplay()
                callback?(value)
                lastTouch = touchLocation
            }
        }
    }
    
    open override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        if touches.first != nil {
            isDragging = false
            setNeedsDisplay()
        }
    }
    
    open func indicatorColorForTheme(_ theme: AKRotaryKnobTheme) -> UIColor {
        if let indicatorColor = indicatorColor { return indicatorColor }
        
        switch theme {
        case .light: return UIColor.white
        case .dark: return UIColor(white: 0.3, alpha: 1.0)
        }
    }
    
    open func knobBorderColorForTheme(_ theme: AKRotaryKnobTheme) -> UIColor {
        if let knobBorderColor = knobBorderColor { return knobBorderColor }
        
        switch theme {
        case .light: return UIColor(white: 0.9, alpha: 1.0)
        case .dark: return UIColor(white: 0.2, alpha: 1.0)
        }
    }
    
    open func textColorForTheme(_ theme: AKRotaryKnobTheme) -> UIColor {
        if let textColor = textColor { return textColor }
        
        switch theme {
        case .light: return UIColor.white
        case .dark: return UIColor(white: 0.3, alpha: 1.0)
        }
    }
    
    override open func draw(_ rect: CGRect) {
        drawKnob(currentValue: CGFloat(value),
                 minimum: minimum,
                 maximum: maximum,
                 propertyName: property,
                 currentValueText: String(format: format, value))
    }
    
    func drawKnob(currentValue: CGFloat = 0,
                  initialValue: CGFloat = 0,
                  minimum: Double = 0,
                  maximum: Double = 1,
                  propertyName: String = "Property Name",
                  currentValueText: String = "0.0") {
        
        //// General Declarations
        guard let context = UIGraphicsGetCurrentContext() else { return }
        
        let width = self.frame.width
        let height = self.frame.height
        
        let nameLabelRect = CGRect(x: 0, y: 0, width: width, height: height)
        let nameLabelStyle = NSMutableParagraphStyle()
        nameLabelStyle.alignment = .center
        
        let textColor = textColorForTheme(knobTheme)
        
        let nameLabelFontAttributes = [NSFontAttributeName: UIFont.boldSystemFont(ofSize: fontSize),
                                       NSForegroundColorAttributeName: textColor,
                                       NSParagraphStyleAttributeName: nameLabelStyle] as [String : Any]
        
        let nameLabelTextHeight: CGFloat = NSString(string: propertyName).boundingRect(
            with: CGSize(width: width, height: CGFloat.infinity),
            options: NSStringDrawingOptions.usesLineFragmentOrigin,
            attributes: nameLabelFontAttributes,
            context: nil).size.height
        context.saveGState()
        
        let knobHeight = height - nameLabelTextHeight
        
        // Draw name label
        let nameLabelInset: CGRect = nameLabelRect.insetBy(dx: 0.0, dy: 0)
        context.clip(to: nameLabelInset)
        NSString(string: propertyName).draw(
            in: CGRect(x: nameLabelInset.minX,
                       y: nameLabelInset.minY + knobHeight,
                       width: nameLabelInset.width,
                       height: nameLabelTextHeight),
            withAttributes: nameLabelFontAttributes)
        context.restoreGState()
        
        // Calculate knob size
        let knobDiameter = min(width, height) - AKRotaryKnob.marginSize * 2.0
        knobCenter = CGPoint(x: AKRotaryKnob.marginSize + knobDiameter / 2.0, y: AKRotaryKnob.marginSize + knobDiameter / 2.0)
        
        // Draw knob
        let knobRect = CGRect(x: AKRotaryKnob.marginSize, y: AKRotaryKnob.marginSize, width: knobDiameter, height: knobDiameter)
        let knobPath = UIBezierPath(roundedRect: knobRect, byRoundingCorners: .allCorners, cornerRadii: CGSize(width: knobDiameter / 2.0, height: knobDiameter / 2.0))
        knobPath.lineWidth = knobBorderWidth
        knobBorderColorForTheme(knobTheme).withAlphaComponent(0.8).setStroke()
        knobPath.stroke()
        knobColor.setFill()
        knobPath.fill()
        
        // Draw indicator
        let valuePercent = (value - minimum) / (maximum - minimum)
        let angle = Double.pi * ( 0.75 + valuePercent * 1.5)
        let indicatorStart = CGPoint(x: (knobDiameter / 5.0) * CGFloat(cos(angle)), y: (knobDiameter / 5.0) * CGFloat(sin(angle)))
        let indicatorEnd = CGPoint(x: (knobDiameter / 2.0) * CGFloat(cos(angle)), y: (knobDiameter / 2.0) * CGFloat(sin(angle)))
        
        let indicatorPath = UIBezierPath()
        indicatorPath.move(to: CGPoint(x: AKRotaryKnob.marginSize + knobDiameter / 2.0 + indicatorStart.x, y: AKRotaryKnob.marginSize + knobDiameter / 2.0 + indicatorStart.y))
        indicatorPath.addLine(to: CGPoint(x: AKRotaryKnob.marginSize + knobDiameter / 2.0 + indicatorEnd.x, y: AKRotaryKnob.marginSize + knobDiameter / 2.0 + indicatorEnd.y))
        indicatorPath.lineWidth = knobBorderWidth / 2.0
        indicatorColorForTheme(knobTheme).setStroke()
        indicatorPath.stroke()
        
        // Draw points
        let pointRadius = (knobDiameter / 2.0) + AKRotaryKnob.marginSize * 0.6
        for i in 0...numberOfIndicatorPoints {
            let pointPercent = Double(i) / Double(numberOfIndicatorPoints)
            let pointAngle = Double.pi * ( 0.75 + pointPercent * 1.5)
            let pointX = AKRotaryKnob.marginSize + knobDiameter / 2.0 + (pointRadius) * CGFloat(cos(pointAngle)) - AKRotaryKnob.indicatorPointRadius
            let pointY = AKRotaryKnob.marginSize + knobDiameter / 2.0 + (pointRadius) * CGFloat(sin(pointAngle)) - AKRotaryKnob.indicatorPointRadius
            let pointRect = CGRect(x: pointX, y: pointY, width: AKRotaryKnob.indicatorPointRadius * 2.0, height: AKRotaryKnob.indicatorPointRadius * 2.0)
            let pointPath = UIBezierPath(roundedRect: pointRect, byRoundingCorners: .allCorners, cornerRadii: CGSize(width: AKRotaryKnob.indicatorPointRadius, height: AKRotaryKnob.indicatorPointRadius))
            if valuePercent > 0.0 && pointPercent <= valuePercent {
                knobColor.setFill()
            } else {
                knobColor.withAlphaComponent(0.2).setFill()
            }
            pointPath.fill()
        }
        
        //// valueLabel Drawing
        if isDragging {
            let valueLabelRect = CGRect(x: 0, y: 0, width: width, height: height)
            let valueLabelStyle = NSMutableParagraphStyle()
            valueLabelStyle.alignment = .center
            
            let valueLabelFontAttributes = [NSFontAttributeName: UIFont.boldSystemFont(ofSize: bubbleFontSize),
                                            NSForegroundColorAttributeName: textColor,
                                            NSParagraphStyleAttributeName: valueLabelStyle] as [String : Any]
            
            let valueLabelInset: CGRect = valueLabelRect.insetBy(dx: 0, dy: 0)
            let valueLabelTextSize = NSString(string: currentValueText).boundingRect(
                with: CGSize(width: valueLabelInset.width, height: CGFloat.infinity),
                options: NSStringDrawingOptions.usesLineFragmentOrigin,
                attributes: valueLabelFontAttributes,
                context: nil).size
            
            let bubbleSize = CGSize(width: valueLabelTextSize.width + AKRotaryKnob.bubblePadding.width, height: valueLabelTextSize.height + AKRotaryKnob.bubblePadding.height)
            var bubbleOriginX = (knobCenter.x - bubbleSize.width / 2.0 - valueBubbleBorderWidth)
            if bubbleOriginX < 0.0 {
                bubbleOriginX = valueBubbleBorderWidth
            } else if (bubbleOriginX + bubbleSize.width) > bounds.width {
                bubbleOriginX = bounds.width - bubbleSize.width - valueBubbleBorderWidth
            }
            let bubbleRect = CGRect(x: bubbleOriginX,
                                    y: knobHeight - valueLabelTextSize.height - AKRotaryKnob.bubbleMargin,
                                    width: bubbleSize.width,
                                    height: bubbleSize.height)
            let bubblePath = UIBezierPath(roundedRect: bubbleRect, byRoundingCorners: .allCorners, cornerRadii: CGSize(width: AKRotaryKnob.bubbleCornerRadius, height: AKRotaryKnob.bubbleCornerRadius))
            knobColor.setFill()
            bubblePath.fill()
            bubblePath.lineWidth = valueBubbleBorderWidth
            knobBorderColorForTheme(knobTheme).setStroke()
            bubblePath.stroke()
            
            context.saveGState()
            context.clip(to: valueLabelInset)
            NSString(string: currentValueText).draw(
                in: CGRect(x: bubbleOriginX + ((bubbleSize.width - valueLabelTextSize.width) / 2.0),
                           y: knobHeight - valueLabelTextSize.height - AKRotaryKnob.bubbleMargin + AKRotaryKnob.bubblePadding.height/2.0,
                           width: valueLabelTextSize.width,
                           height: valueLabelTextSize.height),
                withAttributes: valueLabelFontAttributes)
            context.restoreGState()
        }
    }
}
