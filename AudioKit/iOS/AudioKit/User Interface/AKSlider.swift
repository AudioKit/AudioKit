//
//  AKSlider.swift
//  AudioKit for iOS
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright © 2018 AudioKit. All rights reserved.
//
import AudioKit

/// Different looks the slider can have
public enum AKSliderStyle {
    /// Uses a circle for the touch point
    case roundIndicator

    /// Uses a rectange for the touch point
    case tabIndicator

    // Factor for calculating the corner radius of the slider based on the width of the slider indicator
    var cornerRadiusFactor: CGFloat {
        switch self {
        case .roundIndicator: return 2.0
        case .tabIndicator: return 4.0
        }
    }
}

/// Simple slider interface for AudioKit properties
@IBDesignable open class AKSlider: AKPropertyControl {

    /// Width for the tab indicator
    static var tabIndicatorWidth: CGFloat = 20.0

    /// Padding surrounding the text inside the value bubble
    static var bubblePadding: CGSize = CGSize(width: 10.0, height: 2.0)

    /// Margin between the top of the tap and the value bubble
    static var bubbleMargin: CGFloat = 10.0

    /// Corner radius for the value bubble
    static var bubbleCornerRadius: CGFloat = 2.0

    /// Background color
    @IBInspectable open var bgColor: UIColor?

    /// Slider border color
    @IBInspectable open var sliderBorderColor: UIColor?

    /// Indicator border color
    @IBInspectable open var indicatorBorderColor: UIColor?

    /// Slider overlay color
    @IBInspectable open var color: UIColor = AKStylist.sharedInstance.nextColor

    /// Text color
    @IBInspectable open var textColor: UIColor?

    /// Bubble font size
    @IBInspectable open var bubbleFontSize: CGFloat = 12

    /// Fonts for display above the slider
    public var labelFont: UIFont { return UIFont.systemFont(ofSize: fontSize) }
    public var valueFont: UIFont { return UIFont.systemFont(ofSize: fontSize) }
    public var bubbleFont: UIFont { return UIFont.systemFont(ofSize: bubbleFontSize) }

    /// Only integer
    @IBInspectable open var onlyIntegers: Bool = false

    /// Slider style
    open var sliderStyle: AKSliderStyle = AKSliderStyle.tabIndicator

    // Border width
    @IBInspectable open var sliderBorderWidth: CGFloat = 3.0

    /// Show value bubble
    @IBInspectable open var showsValueBubble: Bool = false

    /// Value bubble border width
    @IBInspectable open var valueBubbleBorderWidth: CGFloat = 1.0

    // Calculated height of the slider based on text size and view bounds
    private var sliderHeight: CGFloat = 0.0

    /// Initialize the slider
    public init(property: String,
                value: Double = 0.0,
                range: ClosedRange<Double> = 0 ... 1,
                taper: Double = 1,
                format: String = "%0.3f",
                color: AKColor = AKStylist.sharedInstance.nextColor,
                frame: CGRect = CGRect(x: 0, y: 0, width: 440, height: 60),
                callback: @escaping (_ x: Double) -> Void = { _ in }) {

        self.color = color

        super.init(property: property,
                   value: value,
                   range: range,
                   taper: taper,
                   format: format,
                   frame: frame,
                   callback: callback)

        self.backgroundColor = UIColor.clear
    }

    /// Initialization within Interface Builder
    required public init?(coder: NSCoder) {
        super.init(coder: coder)
        self.backgroundColor = UIColor.clear

        self.isUserInteractionEnabled = true
        contentMode = .redraw
    }
    // More required initialization from IB
    override init(frame: CGRect) {
        super.init(frame: frame)
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
        super.touchesBegan(touches, with: event)
        touchBeganCallback()
    }
    open var touchBeganCallback: () -> Void = { }
    /// Handle moved touches
    override open func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first {
            let touchLocation = touch.location(in: self)
            lastTouch = touchLocation
            let sliderMargin = (indicatorWidth + sliderBorderWidth) / 2.0
            val = Double((touchLocation.x - sliderMargin) / (bounds.width - sliderMargin))
            val = (0 ... 1).clamp(val)
            value = val.denormalized(to: range, taper: taper)
            callback(value)
        }
        super.touchesMoved(touches, with: event)
    }

    /// Handle touches ended
    open override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        if touches.first != nil {
            isDragging = false
            setNeedsDisplay()
        }
        touchEndedCallback()
    }
    open var touchEndedCallback: () -> Void = { }
    open override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        touchCancelledCallback()
    }
    open var touchCancelledCallback: () -> Void = { }

    private var indicatorWidth: CGFloat {
        switch sliderStyle {
        case .roundIndicator: return sliderHeight
        case .tabIndicator: return AKSlider.tabIndicatorWidth
        }
    }

    var bgColorForTheme: AKColor {
        if let bgColor = bgColor { return bgColor }

        switch AKStylist.sharedInstance.theme {
        case .basic: return AKColor(white: 0.3, alpha: 1.0)
        case .midnight: return AKColor(white: 0.7, alpha: 1.0)
        }
    }

    var indicatorBorderColorForTheme: AKColor {
        if let indicatorBorderColor = indicatorBorderColor { return indicatorBorderColor }

        switch AKStylist.sharedInstance.theme {
        case .basic: return AKColor(white: 0.3, alpha: 1.0)
        case .midnight: return AKColor.white
        }
    }

    var sliderBorderColorForTheme: AKColor {
        if let sliderBorderColor = sliderBorderColor { return sliderBorderColor }

        switch AKStylist.sharedInstance.theme {
        case .basic: return AKColor(white: 0.2, alpha: 1.0)
        case .midnight: return AKColor(white: 0.9, alpha: 1.0)
        }
    }

    var textColorForTheme: AKColor {
        if let textColor = textColor { return textColor }

        switch AKStylist.sharedInstance.theme {
        case .basic: return AKColor(white: 0.3, alpha: 1.0)
        case .midnight: return AKColor.white
        }
    }

    /// Draw the slider
    override open func draw(_ rect: CGRect) {
        guard let context = UIGraphicsGetCurrentContext() else {
            AKLog("No current graphics context")
            return
        }
        context.clear(rect)

        drawFlatSlider(currentValue: CGFloat(val),
            propertyName: property,
            currentValueText: String(format: format, value)
        )
    }

    func drawFlatSlider(currentValue: CGFloat = 0,
                        initialValue: CGFloat = 0,
                        propertyName: String = "Property Name",
                        currentValueText: String = "0.0") {

        //// General Declarations
        guard let context = UIGraphicsGetCurrentContext() else {
            AKLog("No current graphics context")
            return
        }

        let width = self.frame.width
        let height = self.frame.height

        let themeTextColor = textColorForTheme

        let nameLabelRect = CGRect(x: 0, y: 0, width: width, height: height)
        let nameLabelStyle = NSMutableParagraphStyle()
        nameLabelStyle.alignment = .left

        let nameLabelFontAttributes = [NSAttributedString.Key.font: labelFont,
                                       NSAttributedString.Key.foregroundColor: themeTextColor,
                                       NSAttributedString.Key.paragraphStyle: nameLabelStyle]

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
        let currentWidth: CGFloat = currentValue < 0 ? sliderMargin :
            (currentValue < 1 ?
                currentValue * (width - (sliderMargin * 2.0)) + sliderMargin :
                width - sliderMargin)

        //// sliderArea Drawing
        let sliderAreaRect = CGRect(x: sliderBorderWidth / 2.0,
                                    y: sliderOrigin + sliderBorderWidth / 2.0,
                                    width: width - sliderBorderWidth,
                                    height: sliderHeight)
        let sliderAreaPath = UIBezierPath(roundedRect: sliderAreaRect,
                                          byRoundingCorners: .allCorners,
                                          cornerRadii: CGSize(width: sliderCornerRadius, height: sliderCornerRadius))
        bgColorForTheme.setFill()
        sliderAreaPath.fill()
        sliderAreaPath.lineWidth = sliderBorderWidth

        //// valueRectangle Drawing
        let valueWidth = currentWidth < indicatorSize.width ? indicatorSize.width : currentWidth
        let valueCorners = currentWidth < indicatorSize.width ? UIRectCorner.allCorners : [.topLeft, .bottomLeft]
        let valueAreaRect = CGRect(x: sliderBorderWidth / 2.0,
                                   y: sliderOrigin + sliderBorderWidth / 2.0,
                                   width: valueWidth + indicatorSize.width / 2.0,
                                   height: sliderHeight - sliderBorderWidth)
        let valueAreaPath = UIBezierPath(roundedRect: valueAreaRect,
                                         byRoundingCorners: valueCorners,
                                         cornerRadii: CGSize(width: sliderCornerRadius, height: sliderCornerRadius))
        color.withAlphaComponent(0.6).setFill()
        valueAreaPath.fill()

        // sliderArea Border
        sliderBorderColorForTheme.setStroke()
        sliderAreaPath.stroke()

        // Indicator view drawing
        let indicatorRect = CGRect(x: currentWidth - indicatorSize.width / 2.0,
                                   y: sliderOrigin,
                                   width: indicatorSize.width,
                                   height: indicatorSize.height)
        let indicatorPath = UIBezierPath(roundedRect: indicatorRect,
                                         byRoundingCorners: .allCorners,
                                         cornerRadii: CGSize(width: sliderCornerRadius, height: sliderCornerRadius))
        color.setFill()
        indicatorPath.fill()
        indicatorPath.lineWidth = sliderBorderWidth
        indicatorBorderColorForTheme.setStroke()
        indicatorPath.stroke()

        //// valueLabel Drawing
        if showsValueBubble && isDragging {
            let valueLabelRect = CGRect(x: 0, y: 0, width: width, height: height)
            let valueLabelStyle = NSMutableParagraphStyle()
            valueLabelStyle.alignment = .center

            let valueLabelFontAttributes = [NSAttributedString.Key.font: bubbleFont,
                                            NSAttributedString.Key.foregroundColor: themeTextColor,
                                            NSAttributedString.Key.paragraphStyle: valueLabelStyle]

            let valueLabelInset: CGRect = valueLabelRect.insetBy(dx: 0, dy: 0)
            let valueLabelTextSize = NSString(string: currentValueText).boundingRect(
                with: CGSize(width: valueLabelInset.width, height: CGFloat.infinity),
                options: NSStringDrawingOptions.usesLineFragmentOrigin,
                attributes: valueLabelFontAttributes,
                context: nil).size

            let bubbleSize = CGSize(width: valueLabelTextSize.width + AKSlider.bubblePadding.width,
                                    height: valueLabelTextSize.height + AKSlider.bubblePadding.height)
            var bubbleOriginX = (currentWidth - bubbleSize.width / 2.0 - valueBubbleBorderWidth)
            if bubbleOriginX < 0.0 {
                bubbleOriginX = valueBubbleBorderWidth
            } else if (bubbleOriginX + bubbleSize.width) > bounds.width {
                bubbleOriginX = bounds.width - bubbleSize.width - valueBubbleBorderWidth
            }
            let bubbleRect = CGRect(x: bubbleOriginX,
                                    y: sliderOrigin - valueLabelTextSize.height - AKSlider.bubbleMargin,
                                    width: bubbleSize.width,
                                    height: bubbleSize.height)
            let bubblePath = UIBezierPath(roundedRect: bubbleRect,
                                          byRoundingCorners: .allCorners,
                                          cornerRadii: CGSize(width: AKSlider.bubbleCornerRadius,
                                                              height: AKSlider.bubbleCornerRadius))
            color.setFill()
            bubblePath.fill()
            bubblePath.lineWidth = valueBubbleBorderWidth
            indicatorBorderColorForTheme.setStroke()
            bubblePath.stroke()

            context.saveGState()
            context.clip(to: valueLabelInset)
            NSString(string: currentValueText).draw(
                in: CGRect(x: bubbleOriginX + ((bubbleSize.width - valueLabelTextSize.width) / 2.0),
                           y: sliderOrigin - valueLabelTextSize.height - AKSlider.bubbleMargin +
                            AKSlider.bubblePadding.height / 2.0,
                           width: valueLabelTextSize.width,
                           height: valueLabelTextSize.height),
                withAttributes: valueLabelFontAttributes)
            context.restoreGState()

        } else if showsValueBubble == false {
            let valueLabelRect = CGRect(x: 0, y: 0, width: width, height: height)
            let valueLabelStyle = NSMutableParagraphStyle()
            valueLabelStyle.alignment = .right

            let valueLabelFontAttributes = [NSAttributedString.Key.font: valueFont,
                                            NSAttributedString.Key.foregroundColor: themeTextColor,
                                            NSAttributedString.Key.paragraphStyle: valueLabelStyle]

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
