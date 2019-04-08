//
//  AKSlider.swift
//  AudioKit for macOS
//
//  Created by Aurelius Prochazka, revision history on Githbub.
//  Copyright © 2017 Aurelius Prochazka. All rights reserved.
//
import AudioKit

public enum AKSliderStyle {
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

@IBDesignable public class AKSlider: AKPropertyControl {

    // Width for the tab indicator
    static var tabIndicatorWidth: CGFloat = 20.0

    // Padding surrounding the text inside the value bubble
    static var bubblePadding: CGSize = CGSize(width: 10.0, height: 2.0)

    // Margin between the top of the tap and the value bubble
    static var bubbleMargin: CGFloat = 10.0

    // Corner radius for the value bubble
    static var bubbleCornerRadius: CGFloat = 2.0

    /// Background color
    @IBInspectable public var bgColor: NSColor?

    /// Slider border color
    @IBInspectable public var sliderBorderColor: NSColor?

    /// Indicator border color
    @IBInspectable public var indicatorBorderColor: NSColor?

    /// Slider overlay color
    @IBInspectable public var color: NSColor = AKStylist.sharedInstance.nextColor

    /// Text color
    @IBInspectable public var textColor: NSColor?

    /// Bubble font size
    @IBInspectable public var bubbleFontSize: CGFloat = 12

    // Slider style
    open var sliderStyle: AKSliderStyle = .tabIndicator

    // Border width
    @IBInspectable public var sliderBorderWidth: CGFloat = 3.0

    // Show value bubble
    @IBInspectable public var showsValueBubble: Bool = false

    // Value bubble border width
    @IBInspectable public var valueBubbleBorderWidth: CGFloat = 1.0

    // Calculated height of the slider based on text size and view bounds
    private var sliderHeight: CGFloat = 0.0

    public init(property: String,
                value: Double = 0.0,
                range: ClosedRange<Double> = 0 ... 1,
                taper: Double = 1,
                format: String = "%0.3f",
                color: AKColor = AKStylist.sharedInstance.nextColor,
                frame: CGRect = CGRect(width: 440, height: 60),
                callback: @escaping (_ x: Double) -> Void = { _ in }) {

        self.color = color

        super.init(property: property,
                   value: value,
                   range: range,
                   taper: taper,
                   format: format,
                   frame: frame,
                   callback: callback)

    }

    /// Initialization within Interface Builder
    required public init?(coder: NSCoder) {
        super.init(coder: coder)

        self.wantsLayer = true
    }

    override public func mouseDragged(with theEvent: NSEvent) {
        let loc = convert(theEvent.locationInWindow, from: nil)
        let sliderMargin = (indicatorWidth + sliderBorderWidth) / 2.0

        val = (0 ... 1).clamp(Double( (loc.x - sliderMargin) / (bounds.width - sliderMargin * 2.0) ))

        value = val.denormalized(to: range, taper: taper)
        callback(value)
    }

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
    override public func draw(_ rect: NSRect) {
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
        let context = unsafeBitCast(NSGraphicsContext.current?.graphicsPort, to: CGContext.self)

        let width = self.frame.width
        let height = self.frame.height

        // Calculate name label height
        let themeTextColor = textColorForTheme

        let nameLabelRect = CGRect(width: width, height: height)
        let nameLabelStyle = NSMutableParagraphStyle()
        nameLabelStyle.alignment = .left

        let nameLabelFontAttributes: [NSAttributedString.Key: Any] = [.font: NSFont.boldSystemFont(ofSize: fontSize),
                                       .foregroundColor: themeTextColor,
                                       .paragraphStyle: nameLabelStyle]

        let nameLabelTextHeight: CGFloat = NSString(string: propertyName).boundingRect(
            with: CGSize(width: width, height: .infinity),
            options: .usesLineFragmentOrigin,
            attributes: nameLabelFontAttributes).size.height
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
        let sliderAreaRect = NSRect(x: sliderBorderWidth / 2.0,
                                    y: sliderOrigin,
                                    width: width - sliderBorderWidth,
                                    height: sliderHeight)
        let sliderAreaPath = NSBezierPath(roundedRect: sliderAreaRect,
                                          xRadius: sliderCornerRadius,
                                          yRadius: sliderCornerRadius)
        bgColorForTheme.setFill()
        sliderAreaPath.fill()
        sliderAreaPath.lineWidth = sliderBorderWidth

        //// valueRectangle Drawing
        let valueWidth = currentWidth //  < indicatorSize.width ? indicatorSize.width : currentWidth
        let valueAreaRect = NSRect(x: sliderBorderWidth / 2.0,
                                   y: sliderOrigin + sliderBorderWidth / 2.0,
                                   width: valueWidth + indicatorSize.width / 2.0,
                                   height: sliderHeight - sliderBorderWidth)
        let valueAreaPath = NSBezierPath(roundedRect: valueAreaRect,
                                         xRadius: sliderCornerRadius,
                                         yRadius: sliderCornerRadius)
        color.withAlphaComponent(0.6).setFill()
        valueAreaPath.fill()

        // sliderArea Border
        sliderBorderColorForTheme.setStroke()
        sliderAreaPath.stroke()

        // Indicator view drawing
        let indicatorRect = NSRect(x: currentWidth - indicatorSize.width / 2.0,
                                   y: sliderOrigin,
                                   width: indicatorSize.width,
                                   height: indicatorSize.height)
        let indicatorPath = NSBezierPath(roundedRect: indicatorRect,
                                         xRadius: sliderCornerRadius,
                                         yRadius: sliderCornerRadius)
        color.setFill()
        indicatorPath.fill()
        indicatorPath.lineWidth = sliderBorderWidth
        indicatorBorderColorForTheme.setStroke()
        indicatorPath.stroke()

        //// valueLabel Drawing
        if showsValueBubble && isDragging {
            let valueLabelRect = NSRect(width: width, height: height)
            let valueLabelStyle = NSMutableParagraphStyle()
            valueLabelStyle.alignment = .center

            let valueLabelFontAttributes: [NSAttributedString.Key: Any] = [.font: NSFont.boldSystemFont(ofSize: bubbleFontSize),
                                            .foregroundColor: themeTextColor,
                                            .paragraphStyle: valueLabelStyle]

            let valueLabelInset: NSRect = valueLabelRect.insetBy(dx: 0, dy: 0)
            let valueLabelTextSize = NSString(string: currentValueText).boundingRect(
                with: CGSize(width: valueLabelInset.width, height: .infinity),
                options: .usesLineFragmentOrigin,
                attributes: valueLabelFontAttributes).size

            let bubbleSize = CGSize(width: valueLabelTextSize.width + AKSlider.bubblePadding.width,
                                    height: valueLabelTextSize.height + AKSlider.bubblePadding.height)
            var bubbleOriginX = (currentWidth - bubbleSize.width / 2.0 - valueBubbleBorderWidth)
            if bubbleOriginX < 0.0 {
                bubbleOriginX = valueBubbleBorderWidth
            } else if (bubbleOriginX + bubbleSize.width) > bounds.width {
                bubbleOriginX = bounds.width - bubbleSize.width - valueBubbleBorderWidth
            }
            let bubbleRect = NSRect(x: bubbleOriginX,
                                    y: sliderHeight + valueLabelTextSize.height - AKSlider.bubbleMargin + sliderOrigin,
                                    width: bubbleSize.width,
                                    height: bubbleSize.height)
            let bubblePath = NSBezierPath(roundedRect: bubbleRect, xRadius: AKSlider.bubbleCornerRadius,
                                          yRadius: AKSlider.bubbleCornerRadius)
            color.setFill()
            bubblePath.fill()
            bubblePath.lineWidth = valueBubbleBorderWidth
            indicatorBorderColorForTheme.setStroke()
            bubblePath.stroke()

            context.saveGState()
            context.clip(to: valueLabelInset)
            NSString(string: currentValueText).draw(
                in: CGRect(x: bubbleOriginX + ((bubbleSize.width - valueLabelTextSize.width) / 2.0),
                           y: sliderHeight + valueLabelTextSize.height - AKSlider.bubbleMargin +
                            AKSlider.bubblePadding.height / 2.0 + sliderOrigin,
                           width: valueLabelTextSize.width,
                           height: valueLabelTextSize.height),
                withAttributes: valueLabelFontAttributes)
            context.restoreGState()

        } else if showsValueBubble == false {
            let valueLabelRect = CGRect(width: width, height: height)
            let valueLabelStyle = NSMutableParagraphStyle()
            valueLabelStyle.alignment = .right

            let valueLabelFontAttributes: [NSAttributedString.Key: Any] = [.font: NSFont.boldSystemFont(ofSize: fontSize),
                                            .foregroundColor: themeTextColor,
                                            .paragraphStyle: valueLabelStyle]

            let valueLabelInset: CGRect = valueLabelRect.insetBy(dx: sliderCornerRadius, dy: sliderOrigin * 2.0)
            let valueLabelTextHeight: CGFloat = NSString(string: currentValueText).boundingRect(
                with: CGSize(width: valueLabelInset.width, height: .infinity),
                options: .usesLineFragmentOrigin,
                attributes: valueLabelFontAttributes).size.height
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
