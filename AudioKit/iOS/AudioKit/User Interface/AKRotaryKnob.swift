//
//  AKBypassButton.swift
//  AudioKit for iOS
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright © 2018 AudioKit. All rights reserved.
//

import UIKit

/// Style of knob to use
public enum AKRotaryKnobStyle {
    /// Circular knob
    case round
    /// Polygon knob with curvature inwards or outwards to make lots of shapes
    case polygon(numberOfSides: Int, curvature: Double)
}

/// Round control for a property
@IBDesignable open class AKRotaryKnob: AKPropertyControl {

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

    // Maximum curvature value for polygon style knob
    static var maximumPolygonCurvature = 1.0

    /// Background color
    @IBInspectable open var bgColor: UIColor?

    /// Knob border color
    @IBInspectable open var knobBorderColor: UIColor?

    /// Knob indicator color
    @IBInspectable open var indicatorColor: UIColor?

    /// Knob overlay color
    @IBInspectable open var knobColor: UIColor = AKStylist.sharedInstance.nextColor

    /// Text color
    @IBInspectable open var textColor: UIColor?

    /// Bubble font size
    @IBInspectable open var bubbleFontSize: CGFloat = 12

    // Bubble text color
    @IBInspectable open var bubbleTextColor: UIColor?

    /// Slider style. Curvature is a value between -1.0 and 1.0, where 0.0 indicates no curves
    open var knobStyle: AKRotaryKnobStyle = AKRotaryKnobStyle.polygon(numberOfSides: 9, curvature: 0.0)

    /// Border width
    @IBInspectable open var knobBorderWidth: CGFloat = 8.0

    /// Value bubble border width
    @IBInspectable open var valueBubbleBorderWidth: CGFloat = 1.0

    /// Number of indicator points
    @IBInspectable open var numberOfIndicatorPoints: Int = 11

    /// Calculate knob center
    private var knobCenter: CGPoint = CGPoint.zero

    /// Initialize the slider
    public init(property: String,
                value: Double,
                range: ClosedRange<Double> = 0 ... 1,
                taper: Double = 1,
                format: String = "%0.3f",
                color: AKColor = AKStylist.sharedInstance.nextColor,
                frame: CGRect = CGRect(x: 0, y: 0, width: 150, height: 170),
                callback: @escaping (_ x: Double) -> Void) {

        self.knobColor = color

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
        isDragging = true
        touchesMoved(touches, with: event)
    }

    /// Handle moved touches
    override open func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first {
            let touchLocation = touch.location(in: self)
            if lastTouch.x != touchLocation.x {
                let angle = angleBetween(pointA: knobCenter, pointB: touchLocation)
                if angle < 0.0 {
                    val = (0.5 + 0.5 * (180.0 + angle) / 105.0)
                } else {
                    val = ((angle - 75.0) / 110.0) * 0.5
                }
                value = val.denormalized(to: range, taper: taper)
                callback(value)
                lastTouch = touchLocation
            }
        }
    }

    /// Handle touches ending
    open override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        if touches.first != nil {
            isDragging = false
            setNeedsDisplay()
        }
    }

    /// Color for the arrow on the knob for the current theme
    open func indicatorColorForTheme() -> AKColor {
        if let indicatorColor = indicatorColor { return indicatorColor }

        switch AKStylist.sharedInstance.theme {
        case .basic: return AKColor(white: 0.3, alpha: 1.0)
        case .midnight: return AKColor.white
        }
    }

    /// Color for the border for the current theme
    open func knobBorderColorForTheme() -> AKColor {
        if let knobBorderColor = knobBorderColor { return knobBorderColor }

        switch AKStylist.sharedInstance.theme {
        case .basic: return AKColor(white: 0.2, alpha: 1.0)
        case .midnight: return AKColor(white: 1.0, alpha: 1.0)
        }
    }

    /// Text color for the current theme
    open func textColorForTheme() -> AKColor {
        if let textColor = textColor { return textColor }

        switch AKStylist.sharedInstance.theme {
        case .basic: return AKColor(white: 0.3, alpha: 1.0)
        case .midnight: return AKColor.white
        }
    }

    /// Draw the knob
    override open func draw(_ rect: CGRect) {
        drawKnob(currentValue: CGFloat(val),
                 propertyName: property,
                 currentValueText: String(format: format, value))
    }

    func drawKnob(currentValue: CGFloat = 0,
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

        let nameLabelRect = CGRect(x: 0, y: 0, width: width, height: height)
        let nameLabelStyle = NSMutableParagraphStyle()
        nameLabelStyle.alignment = .center

        let textColor = textColorForTheme()

        let nameLabelFontAttributes = [NSAttributedStringKey.font: UIFont.boldSystemFont(ofSize: fontSize),
                                       NSAttributedStringKey.foregroundColor: textColor,
                                       NSAttributedStringKey.paragraphStyle: nameLabelStyle]

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
        knobCenter = CGPoint(x: AKRotaryKnob.marginSize + knobDiameter / 2.0,
                             y: AKRotaryKnob.marginSize + knobDiameter / 2.0)

        // Setup indicator
        let valuePercent = val
        let angle = Double.pi * ( 0.75 + valuePercent * 1.5)
        let indicatorStart = CGPoint(x: (knobDiameter / 5.0) * CGFloat(cos(angle)),
                                     y: (knobDiameter / 5.0) * CGFloat(sin(angle)))
        let indicatorEnd = CGPoint(x: (knobDiameter / 2.0) * CGFloat(cos(angle)),
                                   y: (knobDiameter / 2.0) * CGFloat(sin(angle)))

        // Draw knob
        let knobRect = CGRect(x: AKRotaryKnob.marginSize,
                              y: AKRotaryKnob.marginSize,
                              width: knobDiameter,
                              height: knobDiameter)
        let knobPath: UIBezierPath = {
            switch self.knobStyle {
            case .round:
                return UIBezierPath(roundedRect: knobRect,
                                    byRoundingCorners: .allCorners,
                                    cornerRadii: CGSize(width: knobDiameter / 2.0,
                                                        height: knobDiameter / 2.0))
            case .polygon (let numberOfSides, let curvature):
                return bezierPathWithPolygonInRect(
                    knobRect,
                    numberOfSides: numberOfSides,
                    curvature: curvature,
                    startPoint: CGPoint(x: AKRotaryKnob.marginSize + knobDiameter / 2.0 + indicatorEnd.x,
                                        y: AKRotaryKnob.marginSize + knobDiameter / 2.0 + indicatorEnd.y),
                    offsetAngle: angle)
            }
        }()

        knobPath.lineWidth = knobBorderWidth
        knobBorderColorForTheme().setStroke()
        knobPath.stroke()
        knobColor.setFill()
        knobPath.fill()

        // Draw indicator
        let indicatorPath = UIBezierPath()
        indicatorPath.move(to: CGPoint(x: AKRotaryKnob.marginSize + knobDiameter / 2.0 + indicatorStart.x,
                                       y: AKRotaryKnob.marginSize + knobDiameter / 2.0 + indicatorStart.y))
        indicatorPath.addLine(to: CGPoint(x: AKRotaryKnob.marginSize + knobDiameter / 2.0 + indicatorEnd.x,
                                          y: AKRotaryKnob.marginSize + knobDiameter / 2.0 + indicatorEnd.y))
        indicatorPath.lineWidth = knobBorderWidth / 2.0
        indicatorColorForTheme().setStroke()
        indicatorPath.stroke()

        // Draw points
        let pointRadius = (knobDiameter / 2.0) + AKRotaryKnob.marginSize * 0.6
        for i in 0...numberOfIndicatorPoints - 1 {
            let pointPercent = Double(i) / Double(numberOfIndicatorPoints - 1)
            let pointAngle = Double.pi * ( 0.75 + pointPercent * 1.5)
            let pointX = AKRotaryKnob.marginSize + knobDiameter / 2.0 + (pointRadius) * CGFloat(cos(pointAngle)) -
                AKRotaryKnob.indicatorPointRadius
            let pointY = AKRotaryKnob.marginSize + knobDiameter / 2.0 + (pointRadius) * CGFloat(sin(pointAngle)) -
                AKRotaryKnob.indicatorPointRadius
            let pointRect = CGRect(x: pointX, y: pointY, width: AKRotaryKnob.indicatorPointRadius * 2.0,
                                   height: AKRotaryKnob.indicatorPointRadius * 2.0)
            let pointPath = UIBezierPath(roundedRect: pointRect,
                                         byRoundingCorners: .allCorners,
                                         cornerRadii: CGSize(width: AKRotaryKnob.indicatorPointRadius,
                                                             height: AKRotaryKnob.indicatorPointRadius))
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

            let valueLabelFontAttributes = [NSAttributedStringKey.font: UIFont.boldSystemFont(ofSize: bubbleFontSize),
                                            NSAttributedStringKey.foregroundColor: bubbleTextColor ?? textColor,
                                            NSAttributedStringKey.paragraphStyle: valueLabelStyle]

            let valueLabelInset: CGRect = valueLabelRect.insetBy(dx: 0, dy: 0)
            let valueLabelTextSize = NSString(string: currentValueText).boundingRect(
                with: CGSize(width: valueLabelInset.width, height: CGFloat.infinity),
                options: NSStringDrawingOptions.usesLineFragmentOrigin,
                attributes: valueLabelFontAttributes,
                context: nil).size

            let bubbleSize = CGSize(width: valueLabelTextSize.width + AKRotaryKnob.bubblePadding.width,
                                    height: valueLabelTextSize.height + AKRotaryKnob.bubblePadding.height)

            var bubbleOriginX = (lastTouch.x - bubbleSize.width / 2.0 - valueBubbleBorderWidth)
            if bubbleOriginX < 0.0 {
                bubbleOriginX = valueBubbleBorderWidth
            } else if (bubbleOriginX + bubbleSize.width) > bounds.width {
                bubbleOriginX = bounds.width - bubbleSize.width - valueBubbleBorderWidth
            }

            var bubbleOriginY = (lastTouch.y - 3 * bubbleSize.height - valueBubbleBorderWidth)
            if bubbleOriginY < 0.0 {
                bubbleOriginY = 0.0
            }

            let bubbleRect = CGRect(x: bubbleOriginX,
                                    y: bubbleOriginY,
                                    width: bubbleSize.width,
                                    height: bubbleSize.height)
            let bubblePath = UIBezierPath(roundedRect: bubbleRect,
                                          byRoundingCorners: .allCorners,
                                          cornerRadii: CGSize(width: AKRotaryKnob.bubbleCornerRadius,
                                                              height: AKRotaryKnob.bubbleCornerRadius))
            knobColor.setFill()
            bubblePath.fill()
            bubblePath.lineWidth = valueBubbleBorderWidth
            knobBorderColorForTheme().setStroke()
            bubblePath.stroke()

            context.saveGState()
            context.clip(to: valueLabelInset)
            NSString(string: currentValueText).draw(
                in: CGRect(x: bubbleOriginX + ((bubbleSize.width - valueLabelTextSize.width) / 2.0),
                           y: bubbleOriginY + AKRotaryKnob.bubblePadding.height / 2.0,
                           width: valueLabelTextSize.width,
                           height: valueLabelTextSize.height),
                withAttributes: valueLabelFontAttributes)
            context.restoreGState()
        }
    }

    func bezierPathWithPolygonInRect(_ rect: CGRect,
                                     numberOfSides: Int,
                                     curvature: Double,
                                     startPoint: CGPoint,
                                     offsetAngle: Double) -> UIBezierPath {
        guard numberOfSides > 2 else {
            return UIBezierPath(rect: rect)
        }

        let path = UIBezierPath()
        path.move(to: startPoint)
        for i in 0...numberOfSides {
            let angle = 2 * Double.pi * i / numberOfSides + offsetAngle
            let nextX = rect.midX + rect.width / 2.0 * CGFloat(cos(angle))
            let nextY = rect.midY + rect.height / 2.0 * CGFloat(sin(angle))
            if curvature == 0.0 {
                path.addLine(to: CGPoint(x: nextX, y: nextY))
            } else {
                var actualCurvature = curvature
                if curvature > AKRotaryKnob.maximumPolygonCurvature {
                    actualCurvature = AKRotaryKnob.maximumPolygonCurvature
                }
                if curvature < AKRotaryKnob.maximumPolygonCurvature * -1.0 {
                    actualCurvature = AKRotaryKnob.maximumPolygonCurvature * -1.0
                }
                let arcAngle = 2 * Double.pi * (i - 0.5) / numberOfSides + offsetAngle
                let arcX = rect.midX + (rect.width * CGFloat(1 + actualCurvature * 0.5)) / 2 * CGFloat(cos(arcAngle))
                let arcY = rect.midY + (rect.height * CGFloat(1 + actualCurvature * 0.5)) / 2 * CGFloat(sin(arcAngle))
                path.addQuadCurve(to: CGPoint(x: nextX, y: nextY), controlPoint: CGPoint(x: arcX, y: arcY))
            }
        }
        path.close()
        return path
    }
}
