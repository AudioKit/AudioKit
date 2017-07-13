//
//  AKPropertySlider.swift
//  AudioKit for iOS
//
//  Created by Aurelius Prochazka, revision history on Github.
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

public enum AKPropertySliderTheme {
    case light
    case dark
}

/// Simple slider interface for AudioKit properties
@IBDesignable open class AKPropertySlider: UIView {

    // Width for the tab indicator
    static var tabIndicatorWidth: CGFloat = 20.0
    
    // Padding surrounding the text inside the value bubble
    static var bubblePadding: CGSize = CGSize(width: 10.0, height: 2.0)
    
    // Margin between the top of the tap and the value bubble
    static var bubbleMargin: CGFloat = 10.0
    
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

    /// Text shown on the slider
    @IBInspectable open var property: String = "Property"

    /// Format for the number shown on the slider
    @IBInspectable open var format: String = "%0.3f"

    /// Background color
    @IBInspectable open var bgColor: UIColor?

    /// Slider border color
    @IBInspectable open var sliderBorderColor: UIColor?
    
    /// Indicator border color
    @IBInspectable open var indicatorBorderColor: UIColor?

    /// Slider overlay color
    @IBInspectable open var sliderColor: UIColor = .red

    /// Text color
    @IBInspectable open var textColor: UIColor?

    /// Font size
    @IBInspectable open var fontSize: CGFloat = 20

    /// Bubble font size
    @IBInspectable open var bubbleFontSize: CGFloat = 12

    // Slider style
    @IBInspectable open var sliderStyle: AKPropertySliderStyle = AKPropertySliderStyle.tabIndicator
    
    // Slider theme
    @IBInspectable open var sliderTheme: AKPropertySliderTheme = AKPropertySliderTheme.light
    
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
    open var callback: ((Double) -> Void)?
    fileprivate var lastTouch = CGPoint.zero

    /// Initialize the slider
    public init(property: String,
                format: String = "%0.3f",
                value: Double,
                minimum: Double = 0,
                maximum: Double = 1,
                color: UIColor = UIColor.red,
                frame: CGRect = CGRect(x: 0, y: 0, width: 440, height: 60),
                callback: @escaping (_ x: Double) -> Void) {
        self.value = value
        self.minimum = minimum
        self.maximum = maximum
        self.property = property
        self.format = format
        self.sliderColor = color

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

    /// Require constraint-based layout
    open class override var requiresConstraintBasedLayout: Bool {
        return true
    }

    /// Handle new touches
    override open func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first {
            isDragging = true
            let touchLocation = touch.location(in: self)
            lastTouch = touchLocation
            let sliderMargin = (indicatorWidth + sliderBorderWidth) / 2.0
            value = Double((touchLocation.x - sliderMargin) / (bounds.width - sliderMargin)) * (maximum - minimum) + minimum
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
                let sliderMargin = (indicatorWidth + sliderBorderWidth) / 2.0
                value = Double((touchLocation.x - sliderMargin) / (bounds.width - sliderMargin)) * (maximum - minimum) + minimum
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

    /// Give the slider a random value
    open func randomize() -> Double {
        value = random(minimum, maximum)
        setNeedsDisplay()
        return value
    }
    
    private var indicatorWidth: CGFloat {
        switch sliderStyle {
        case .roundIndicator: return sliderHeight
        case .tabIndicator: return AKPropertySlider.tabIndicatorWidth
        }
    }
    
    open func bgColorForTheme(_ theme: AKPropertySliderTheme) -> UIColor {
        if let bgColor = bgColor { return bgColor }
        
        switch theme {
            case .light: return UIColor(white: 0.7, alpha: 1.0)
            case .dark: return UIColor(white: 0.3, alpha: 1.0)
        }
    }

    open func indicatorBorderColorForTheme(_ theme: AKPropertySliderTheme) -> UIColor {
        if let indicatorBorderColor = indicatorBorderColor { return indicatorBorderColor }
        
        switch theme {
            case .light: return UIColor.white
            case .dark: return UIColor(white: 0.3, alpha: 1.0)
        }
    }
    
    open func sliderBorderColorForTheme(_ theme: AKPropertySliderTheme) -> UIColor {
        if let sliderBorderColor = sliderBorderColor { return sliderBorderColor }
        
        switch theme {
        case .light: return UIColor(white: 0.9, alpha: 1.0)
        case .dark: return UIColor(white: 0.2, alpha: 1.0)
        }
    }
    
    open func textColorForTheme(_ theme: AKPropertySliderTheme) -> UIColor {
        if let textColor = textColor { return textColor }
        
        switch theme {
        case .light: return UIColor.white
        case .dark: return UIColor(white: 0.3, alpha: 1.0)
        }
    }
    
    /// Draw the slider
    override open func draw(_ rect: CGRect) {
        guard let context = UIGraphicsGetCurrentContext() else { return }
        context.clear(rect)
        
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
        guard let context = UIGraphicsGetCurrentContext() else { return }

        let width = self.frame.width
        let height = self.frame.height
        
        // Calculate name label height
        let themeTextColor = textColorForTheme(sliderTheme)
        
        let nameLabelRect = CGRect(x: 0, y: 0, width: width, height: height)
        let nameLabelStyle = NSMutableParagraphStyle()
        nameLabelStyle.alignment = .left
        
        let nameLabelFontAttributes = [NSFontAttributeName: UIFont.boldSystemFont(ofSize: fontSize),
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
        let sliderOrigin = nameLabelTextHeight + sliderTextMargin
        sliderHeight = height - sliderOrigin - sliderTextMargin
        let indicatorSize = CGSize(width: indicatorWidth, height: sliderHeight)
        let sliderCornerRadius = indicatorSize.width / sliderStyle.cornerRadiusFactor

        // Draw name label
        let nameLabelInset: CGRect = nameLabelRect.insetBy(dx: sliderCornerRadius, dy: 0)
        context.clip(to: nameLabelInset)
        NSString(string: propertyName).draw(
            in: CGRect(x: nameLabelInset.minX,
                       y: nameLabelInset.minY,
                       width: nameLabelInset.width,
                       height: nameLabelTextHeight),
            withAttributes: nameLabelFontAttributes)
        context.restoreGState()

        //// Variable Declarations
        let sliderMargin = (indicatorWidth + sliderBorderWidth) / 2.0
        let currentWidth: CGFloat = currentValue < minimum ? sliderMargin :
            (currentValue < maximum ? (currentValue - minimum) / (maximum - minimum) * (width - (sliderMargin * 2.0)) + sliderMargin : width - sliderMargin)

        //// sliderArea Drawing
        let sliderAreaRect = CGRect(x: sliderBorderWidth / 2.0, y: sliderOrigin, width: width - sliderBorderWidth, height: sliderHeight)
        let sliderAreaPath = UIBezierPath(roundedRect: sliderAreaRect, byRoundingCorners: .allCorners, cornerRadii: CGSize(width: sliderCornerRadius, height: sliderCornerRadius))
        bgColorForTheme(sliderTheme).setFill()
        sliderAreaPath.fill()
        sliderAreaPath.lineWidth = sliderBorderWidth

        //// valueRectangle Drawing
        let valueWidth = currentWidth < indicatorSize.width ? indicatorSize.width : currentWidth
        let valueCorners = currentWidth < indicatorSize.width ? UIRectCorner.allCorners : [.topLeft, .bottomLeft]
        let valueAreaRect = CGRect(x: sliderBorderWidth / 2.0, y: sliderOrigin + sliderBorderWidth / 2.0, width: valueWidth, height: sliderHeight - sliderBorderWidth)
        let valueAreaPath = UIBezierPath(roundedRect: valueAreaRect, byRoundingCorners: valueCorners, cornerRadii: CGSize(width: sliderCornerRadius, height: sliderCornerRadius))
        sliderColor.withAlphaComponent(0.6).setFill()
        valueAreaPath.fill()
        
        // sliderArea Border
        sliderBorderColorForTheme(sliderTheme).setStroke()
        sliderAreaPath.stroke()
        
        // Indicator view drawing
        let indicatorRect = CGRect(x: currentWidth - indicatorSize.width / 2.0, y: sliderOrigin, width: indicatorSize.width, height: indicatorSize.height)
        let indicatorPath = UIBezierPath(roundedRect: indicatorRect, byRoundingCorners: .allCorners, cornerRadii: CGSize(width: sliderCornerRadius, height: sliderCornerRadius))
        sliderColor.setFill()
        indicatorPath.fill()
        indicatorPath.lineWidth = sliderBorderWidth
        indicatorBorderColorForTheme(sliderTheme).setStroke()
        indicatorPath.stroke()

        //// valueLabel Drawing
        if showsValueBubble && isDragging {
            let valueLabelRect = CGRect(x: 0, y: 0, width: width, height: height)
            let valueLabelStyle = NSMutableParagraphStyle()
            valueLabelStyle.alignment = .center
            
            let valueLabelFontAttributes = [NSFontAttributeName: UIFont.boldSystemFont(ofSize: bubbleFontSize),
                                            NSForegroundColorAttributeName: themeTextColor,
                                            NSParagraphStyleAttributeName: valueLabelStyle] as [String : Any]
            
            let valueLabelInset: CGRect = valueLabelRect.insetBy(dx: 0, dy: 0)
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
            let bubbleRect = CGRect(x: bubbleOriginX,
                                    y: sliderOrigin - valueLabelTextSize.height - AKPropertySlider.bubbleMargin,
                                    width: bubbleSize.width,
                                    height: bubbleSize.height)
            let bubblePath = UIBezierPath(roundedRect: bubbleRect, byRoundingCorners: .allCorners, cornerRadii: CGSize(width: AKPropertySlider.bubbleCornerRadius, height: AKPropertySlider.bubbleCornerRadius))
            sliderColor.setFill()
            bubblePath.fill()
            bubblePath.lineWidth = valueBubbleBorderWidth
            indicatorBorderColorForTheme(sliderTheme).setStroke()
            bubblePath.stroke()
            
            context.saveGState()
            context.clip(to: valueLabelInset)
            NSString(string: currentValueText).draw(
                in: CGRect(x: bubbleOriginX + ((bubbleSize.width - valueLabelTextSize.width) / 2.0),
                           y: sliderOrigin - valueLabelTextSize.height - AKPropertySlider.bubbleMargin + AKPropertySlider.bubblePadding.height/2.0,
                           width: valueLabelTextSize.width,
                           height: valueLabelTextSize.height),
                withAttributes: valueLabelFontAttributes)
            context.restoreGState()
            
        } else if showsValueBubble == false {
            let valueLabelRect = CGRect(x: 0, y: 0, width: width, height: height)
            let valueLabelStyle = NSMutableParagraphStyle()
            valueLabelStyle.alignment = .right
            
            let valueLabelFontAttributes = [NSFontAttributeName: UIFont.boldSystemFont(ofSize: fontSize),
                                            NSForegroundColorAttributeName: themeTextColor,
                                            NSParagraphStyleAttributeName: valueLabelStyle] as [String : Any]
            
            let valueLabelInset: CGRect = valueLabelRect.insetBy(dx: sliderCornerRadius, dy: 0)
            let valueLabelTextHeight: CGFloat = NSString(string: currentValueText).boundingRect(
                with: CGSize(width: valueLabelInset.width, height: CGFloat.infinity),
                options: NSStringDrawingOptions.usesLineFragmentOrigin,
                attributes: valueLabelFontAttributes,
                context: nil).size.height
            context.saveGState()
            context.clip(to: valueLabelInset)
            NSString(string: currentValueText).draw(
                in: CGRect(x: valueLabelInset.minX,
                           y: valueLabelInset.minY,
                           width: valueLabelInset.width,
                           height: valueLabelTextHeight),
                withAttributes: valueLabelFontAttributes)
            context.restoreGState()
        }
    }

}
