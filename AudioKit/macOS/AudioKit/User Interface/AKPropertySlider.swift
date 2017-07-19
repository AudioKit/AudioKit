//
//  AKPropertySlider.swift
//  AudioKit for macOS
//
//  Created by Aurelius Prochazka on 7/26/16.
//  Copyright © 2017 Aurelius Prochazka. All rights reserved.
//

public enum AKPropertySliderStyle {
    case roundIndicator
    case tabIndicator
    
    // Factor for calculating the corner radius of the slider based on the width of the slider indicator
    var cornerRadiusFactor: CGFloat {
        switch self {
        case .roundIndicator: return 2.0
        case .tabIndicator: return 4.0
        }
    }
}

@IBDesignable public class AKPropertySlider: NSView {
    override public func acceptsFirstMouse(for theEvent: NSEvent?) -> Bool {
        return true
    }
    
    // Default side
    static var defaultSize = CGSize(width: 440.0, height: 60.0)
    
    // Width for the tab indicator
    static var tabIndicatorWidth: CGFloat = 20.0
    
    // Padding surrounding the text inside the value bubble
    static var bubblePadding: CGSize = CGSize(width: 10.0, height: 2.0)
    
    // Margin between the top of the tap and the value bubble
    static var bubbleMargin: CGFloat = 10.0
    
    // Corner radius for the value bubble
    static var bubbleCornerRadius: CGFloat = 2.0
    
    var initialValue: Double = 0
    
    /// Current value of the slider
    @IBInspectable open var value: Double = 0 {
        didSet {
            needsDisplay = true
        }
    }
    
    /// Minimum, left-most value
    @IBInspectable open var minimum: Double = 0
    
    /// Maximum, right-most value
    @IBInspectable open var maximum: Double = 1
    
    /// Text shown on the slider
    @IBInspectable open var property: String = "Property"
    
    /// Format for the number shown on the slider
    @IBInspectable open var format: String = "%0.3f"
    
    /// Background color
    @IBInspectable open var bgColor: NSColor?
    
    /// Slider border color
    @IBInspectable open var sliderBorderColor: NSColor?
    
    /// Indicator border color
    @IBInspectable open var indicatorBorderColor: NSColor?
    
    /// Slider overlay color
    @IBInspectable open var color: NSColor = .red
    
    /// Text color
    @IBInspectable open var textColor: NSColor?
    
    /// Font size
    @IBInspectable open var fontSize: CGFloat = 20
    
    /// Bubble font size
    @IBInspectable open var bubbleFontSize: CGFloat = 12
    
    // Slider style
    open var sliderStyle: AKPropertySliderStyle = .tabIndicator

    // Border width
    @IBInspectable open var sliderBorderWidth: CGFloat = 3.0
    
    // Show value bubble
    @IBInspectable open var showsValueBubble: Bool = false
    
    // Value bubble border width
    @IBInspectable open var valueBubbleBorderWidth: CGFloat = 1.0
    
    // Current dragging state, used to show/hide the value bubble
    private var isDragging: Bool = false
    
    // Calculated height of the slider based on text size and view bounds
    private var sliderHeight: CGFloat = 0.0
    
    /// Function to call when value changes
    public var callback: ((Double) -> Void)?
    fileprivate var lastTouch = CGPoint.zero
    
    public init(property: String,
                format: String = "%0.3f",
                value: Double,
                minimum: Double = 0,
                maximum: Double = 1,
                color: NSColor = NSColor.red,
                frame: CGRect = CGRect(x: 0, y: 0, width: AKPropertySlider.defaultSize.width, height:  AKPropertySlider.defaultSize.height),
                callback: @escaping (_ x: Double) -> Void) {
        self.value = value
        self.initialValue = value
        self.minimum = minimum
        self.maximum = maximum
        self.property = property
        self.format = format
        self.color = color

        self.callback = callback
        super.init(frame: frame)
        
        self.wantsLayer = true

        needsDisplay = true
    }

    /// Initialization within Interface Builder
    required public init?(coder: NSCoder) {
        super.init(coder: coder)
        
        self.wantsLayer = true
    }
    
    public override func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()
        
        self.wantsLayer = true
    }
    
    override public func mouseDown(with theEvent: NSEvent) {
        isDragging = true
        let loc = convert(theEvent.locationInWindow, from: nil)
        let sliderMargin = (indicatorWidth + sliderBorderWidth) / 2.0
        value = Double((loc.x - sliderMargin) / (bounds.width - sliderMargin * 2.0)) * (maximum - minimum) + minimum
        if value > maximum { value = maximum }
        if value < minimum { value = minimum }
        needsDisplay = true
        callback?(value)
    }
    
    override public func mouseDragged(with theEvent: NSEvent) {
        let loc = convert(theEvent.locationInWindow, from: nil)
        let sliderMargin = (indicatorWidth + sliderBorderWidth) / 2.0
        value = Double((loc.x - sliderMargin) / (bounds.width - sliderMargin * 2.0)) * (maximum - minimum) + minimum
        if value > maximum { value = maximum }
        if value < minimum { value = minimum }
        needsDisplay = true
        callback?(value)
    }
    
    public override func mouseUp(with theEvent: NSEvent) {
        isDragging = false
        needsDisplay = true
    }
    
    public func randomize() -> Double {
        value = random(minimum, maximum)
        needsDisplay = true
        return value
    }
    
    private var indicatorWidth: CGFloat {
        switch sliderStyle {
        case .roundIndicator: return sliderHeight
        case .tabIndicator: return AKPropertySlider.tabIndicatorWidth
        }
    }
    
    var bgColorForTheme: NSColor {
        if let bgColor = bgColor { return bgColor }
        
        switch AKStylist.sharedInstance.theme {
        case .basic: return NSColor(white: 0.3, alpha: 1.0)
        case .midnight: return NSColor(white: 0.7, alpha: 1.0)
        }
    }
    
    var indicatorBorderColorForTheme: NSColor {
        if let indicatorBorderColor = indicatorBorderColor { return indicatorBorderColor }
        
        switch AKStylist.sharedInstance.theme {
        case .basic: return NSColor(white: 0.3, alpha: 1.0)
        case .midnight: return NSColor.white
        }
    }
    
    var sliderBorderColorForTheme: NSColor {
        if let sliderBorderColor = sliderBorderColor { return sliderBorderColor }
        
        switch AKStylist.sharedInstance.theme {
        case .basic: return NSColor(white: 0.2, alpha: 1.0)
        case .midnight: return NSColor(white: 0.9, alpha: 1.0)
        }
    }
    
    var textColorForTheme: NSColor {
        if let textColor = textColor { return textColor }
        
        switch AKStylist.sharedInstance.theme {
        case .basic: return NSColor(white: 0.3, alpha: 1.0)
        case .midnight: return NSColor.white
        }
    }
    /// Draw the slider
    override open func draw(_ rect: NSRect) {
        drawFlatSlider(currentValue: CGFloat(value),
                       minimum: CGFloat(minimum),
                       maximum: CGFloat(maximum),
                       propertyName: property,
                       currentValueText: String(format: format, value)
        )
    }
    
    func drawFlatSlider(currentValue: CGFloat = 0,
                        initialValue: CGFloat = 0,
                        minimum: CGFloat = 0,
                        maximum: CGFloat = 1,
                        propertyName: String = "Property Name",
                        currentValueText: String = "0.0") {
        
        
        //// General Declarations
        let context = unsafeBitCast(NSGraphicsContext.current()?.graphicsPort, to: CGContext.self)
        
        let width = self.frame.width
        let height = self.frame.height
        
        // Calculate name label height
        let themeTextColor = textColorForTheme
        
        let nameLabelRect = CGRect(x: 0, y: 0, width: width, height: height)
        let nameLabelStyle = NSMutableParagraphStyle()
        nameLabelStyle.alignment = .left
        
        let nameLabelFontAttributes = [NSFontAttributeName: NSFont.boldSystemFont(ofSize: fontSize),
                                       NSForegroundColorAttributeName: themeTextColor,
                                       NSParagraphStyleAttributeName: nameLabelStyle] as [String : Any]
        
        let nameLabelTextHeight: CGFloat = NSString(string: propertyName).boundingRect(
            with: CGSize(width: width, height: CGFloat.infinity),
            options: NSStringDrawingOptions.usesLineFragmentOrigin,
            attributes: nameLabelFontAttributes,
            context: nil).size.height
        context.saveGState()
        
        // Calculate slider height and other values based on expected label height
        let sliderTextMargin: CGFloat = 5.0
        let labelOrigin = nameLabelTextHeight + sliderTextMargin
        let sliderOrigin = sliderBorderWidth
        sliderHeight = height - labelOrigin - sliderTextMargin
        let indicatorSize = CGSize(width: indicatorWidth, height: sliderHeight)
        let sliderCornerRadius = indicatorSize.width / sliderStyle.cornerRadiusFactor
        
        
        // Draw name label
        let nameLabelInset: CGRect = nameLabelRect.insetBy(dx: sliderCornerRadius, dy: sliderOrigin * 2.0)
        context.clip(to: nameLabelInset)
        NSString(string: propertyName).draw(
            in: CGRect(x: nameLabelInset.minX,
                       y: nameLabelInset.minY + sliderHeight,
                       width: nameLabelInset.width,
                       height: nameLabelTextHeight),
            withAttributes: nameLabelFontAttributes)
        context.restoreGState()
        
        //// Variable Declarations
        let sliderMargin = (indicatorWidth + sliderBorderWidth) / 2.0
        let currentWidth: CGFloat = currentValue < minimum ? sliderMargin :
            (currentValue < maximum ? (currentValue - minimum) / (maximum - minimum) * (width - (sliderMargin * 2.0)) + sliderMargin : width - sliderMargin)
        
        //// sliderArea Drawing
        let sliderAreaRect = NSRect(x: sliderBorderWidth / 2.0, y: sliderOrigin, width: width - sliderBorderWidth, height: sliderHeight)
        let sliderAreaPath = NSBezierPath(roundedRect: sliderAreaRect, xRadius: sliderCornerRadius, yRadius: sliderCornerRadius)
        bgColorForTheme.setFill()
        sliderAreaPath.fill()
        sliderAreaPath.lineWidth = sliderBorderWidth
        
        //// valueRectangle Drawing
        let valueWidth = currentWidth //  < indicatorSize.width ? indicatorSize.width : currentWidth
        let valueAreaRect = NSRect(x: sliderBorderWidth / 2.0, y: sliderOrigin + sliderBorderWidth / 2.0, width: valueWidth + indicatorSize.width / 2.0, height: sliderHeight - sliderBorderWidth)
        let valueAreaPath = NSBezierPath(roundedRect: valueAreaRect, xRadius: sliderCornerRadius, yRadius: sliderCornerRadius)
        color.withAlphaComponent(0.6).setFill()
        valueAreaPath.fill()
        
        // sliderArea Border
        sliderBorderColorForTheme.setStroke()
        sliderAreaPath.stroke()
        
        // Indicator view drawing
        let indicatorRect = NSRect(x: currentWidth - indicatorSize.width / 2.0, y: sliderOrigin, width: indicatorSize.width, height: indicatorSize.height)
        let indicatorPath = NSBezierPath(roundedRect: indicatorRect, xRadius: sliderCornerRadius, yRadius: sliderCornerRadius)
        color.setFill()
        indicatorPath.fill()
        indicatorPath.lineWidth = sliderBorderWidth
        indicatorBorderColorForTheme.setStroke()
        indicatorPath.stroke()
        
        //// valueLabel Drawing
        if showsValueBubble && isDragging {
            let valueLabelRect = NSRect(x: 0, y: 0, width: width, height: height)
            let valueLabelStyle = NSMutableParagraphStyle()
            valueLabelStyle.alignment = .center
            
            let valueLabelFontAttributes = [NSFontAttributeName: NSFont.boldSystemFont(ofSize: bubbleFontSize),
                                            NSForegroundColorAttributeName: themeTextColor,
                                            NSParagraphStyleAttributeName: valueLabelStyle] as [String : Any]
            
            let valueLabelInset: NSRect = valueLabelRect.insetBy(dx: 0, dy: 0)
            let valueLabelTextSize = NSString(string: currentValueText).boundingRect(
                with: CGSize(width: valueLabelInset.width, height: CGFloat.infinity),
                options: NSStringDrawingOptions.usesLineFragmentOrigin,
                attributes: valueLabelFontAttributes,
                context: nil).size
            
            let bubbleSize = CGSize(width: valueLabelTextSize.width + AKPropertySlider.bubblePadding.width, height: valueLabelTextSize.height + AKPropertySlider.bubblePadding.height)
            var bubbleOriginX = (currentWidth - bubbleSize.width / 2.0 - valueBubbleBorderWidth)
            if bubbleOriginX < 0.0 {
                bubbleOriginX = valueBubbleBorderWidth
            } else if (bubbleOriginX + bubbleSize.width) > bounds.width {
                bubbleOriginX = bounds.width - bubbleSize.width - valueBubbleBorderWidth
            }
            let bubbleRect = NSRect(x: bubbleOriginX,
                                    y: sliderHeight + valueLabelTextSize.height - AKPropertySlider.bubbleMargin + sliderOrigin,
                                    width: bubbleSize.width,
                                    height: bubbleSize.height)
            let bubblePath = NSBezierPath(roundedRect: bubbleRect, xRadius: AKPropertySlider.bubbleCornerRadius, yRadius: AKPropertySlider.bubbleCornerRadius)
            color.setFill()
            bubblePath.fill()
            bubblePath.lineWidth = valueBubbleBorderWidth
            indicatorBorderColorForTheme.setStroke()
            bubblePath.stroke()
            
            context.saveGState()
            context.clip(to: valueLabelInset)
            NSString(string: currentValueText).draw(
                in: CGRect(x: bubbleOriginX + ((bubbleSize.width - valueLabelTextSize.width) / 2.0),
                           y: sliderHeight + valueLabelTextSize.height - AKPropertySlider.bubbleMargin + AKPropertySlider.bubblePadding.height/2.0 + sliderOrigin,
                           width: valueLabelTextSize.width,
                           height: valueLabelTextSize.height),
                withAttributes: valueLabelFontAttributes)
            context.restoreGState()
            
        } else if showsValueBubble == false {
            let valueLabelRect = CGRect(x: 0, y: 0, width: width, height: height)
            let valueLabelStyle = NSMutableParagraphStyle()
            valueLabelStyle.alignment = .right
            
            let valueLabelFontAttributes = [NSFontAttributeName: NSFont.boldSystemFont(ofSize: fontSize),
                                            NSForegroundColorAttributeName: themeTextColor,
                                            NSParagraphStyleAttributeName: valueLabelStyle] as [String : Any]
            
            let valueLabelInset: CGRect = valueLabelRect.insetBy(dx: sliderCornerRadius, dy: sliderOrigin * 2.0)
            let valueLabelTextHeight: CGFloat = NSString(string: currentValueText).boundingRect(
                with: CGSize(width: valueLabelInset.width, height: CGFloat.infinity),
                options: NSStringDrawingOptions.usesLineFragmentOrigin,
                attributes: valueLabelFontAttributes,
                context: nil).size.height
            context.saveGState()
            context.clip(to: valueLabelInset)
            NSString(string: currentValueText).draw(
                in: CGRect(x: valueLabelInset.minX,
                           y: valueLabelInset.minY + sliderHeight,
                           width: valueLabelInset.width,
                           height: valueLabelTextHeight),
                withAttributes: valueLabelFontAttributes)
            context.restoreGState()
        }
    }
}
