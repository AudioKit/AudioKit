// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

#if !os(macOS) || targetEnvironment(macCatalyst)

import UIKit
import AVFoundation

/// Style of knob to use
public enum AKRotaryKnobStyle {
    /// Circular knob
    case round
    /// Polygon knob with curvature inwards or outwards to make lots of shapes
    case polygon(numberOfSides: Int, curvature: Double)
}

/// Round control for a property
@IBDesignable public class AKRotaryKnob: AKPropertyControl {
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
                value: AUValue,
                range: ClosedRange<AUValue> = 0...1,
                taper: AUValue = 1,
                format: String = "%0.3f",
                color: AKColor = AKStylist.sharedInstance.nextColor,
                frame: CGRect = CGRect(x: 0, y: 0, width: 150, height: 170),
                callback: @escaping (_ x: AUValue) -> Void) {
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
    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.backgroundColor = UIColor.clear

        self.isUserInteractionEnabled = true
        contentMode = .redraw
    }

    /// Actions to perform to make sure the view is renderable in Interface Builder
    public override func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()
        clipsToBounds = true
    }

    func angleBetween(pointA: CGPoint, pointB: CGPoint) -> Double {
        let deltaX = Double(pointB.x - pointA.x)
        let deltaY = Double(pointB.y - pointA.y)
        let radians = atan2(-deltaX, deltaY)
        let degrees = radians * 180 / Double.pi
        return degrees
    }

    /// Handle new touches
    public override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        isDragging = true
        touchesMoved(touches, with: event)
    }

    /// Handle moved touches
    public override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first {
            let touchLocation = touch.location(in: self)
            if lastTouch.x != touchLocation.x {
                let angle = angleBetween(pointA: knobCenter, pointB: touchLocation)
                if angle < 0.0 {
                    val = (0.5 + 0.5 * (180.0 + AUValue(angle)) / 105.0)
                } else {
                    val = AUValue(((angle - 75.0) / 110.0) * 0.5)
                }
                value = val.denormalized(to: range, taper: taper)
                callback(value)
                lastTouch = touchLocation
            }
        }
    }

    /// Handle touches ending
    public override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        if touches.first != nil {
            isDragging = false
            setNeedsDisplay()
        }
    }

    /// Color for the arrow on the knob for the current theme
    public func indicatorColorForTheme() -> AKColor {
        if let indicatorColor = indicatorColor {
            return indicatorColor
        }
        switch AKStylist.sharedInstance.theme {
        case .basic:
            return AKColor(white: 0.3, alpha: 1.0)
        case .midnight:
            return AKColor.white
        }
    }

    /// Color for the border for the current theme
    public func knobBorderColorForTheme() -> AKColor {
        if let knobBorderColor = knobBorderColor {
            return knobBorderColor
        }
        switch AKStylist.sharedInstance.theme {
        case .basic:
            return AKColor(white: 0.2, alpha: 1.0)
        case .midnight:
            return AKColor(white: 1.0, alpha: 1.0)
        }
    }

    /// Text color for the current theme
    public func textColorForTheme() -> AKColor {
        if let textColor = textColor {
            return textColor
        }
        switch AKStylist.sharedInstance.theme {
        case .basic:
            return AKColor(white: 0.3, alpha: 1.0)
        case .midnight:
            return AKColor.white
        }
    }

    /// Draw the knob
    public override func draw(_ rect: CGRect) {
        drawKnob(currentValue: CGFloat(val),
                 propertyName: property,
                 currentValueText: String(format: format, value))
    }

    func drawKnob(currentValue: CGFloat = 0,
                  initialValue: CGFloat = 0,
                  propertyName: String = "Property Name",
                  currentValueText: String = "0.0") {
        guard let context = UIGraphicsGetCurrentContext() else {
            AKLog("No current graphics context")
            return
        }

        let width = frame.width
        let height = frame.height

        let nameLabelRect = CGRect(x: 0, y: 0, width: width, height: height)
        let nameLabelStyle = NSMutableParagraphStyle()
        nameLabelStyle.alignment = .center
        let textColor = textColorForTheme()

        let nameLabelFontAttributes = [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: fontSize),
                                       NSAttributedString.Key.foregroundColor: textColor,
                                       NSAttributedString.Key.paragraphStyle: nameLabelStyle]

        let nameLabelTextHeight: CGFloat =
            NSString(string: propertyName).boundingRect(with: CGSize(width: width, height: CGFloat.infinity),
                                                        options: NSStringDrawingOptions.usesLineFragmentOrigin,
                                                        attributes: nameLabelFontAttributes,
                                                        context: nil).size.height
        context.saveGState()

        let knobHeight = height - nameLabelTextHeight

        let nameLabelInset: CGRect = nameLabelRect.insetBy(dx: 0.0, dy: 0)
        context.clip(to: nameLabelInset)
        NSString(string: propertyName).draw(in: CGRect(x: nameLabelInset.minX,
                                                       y: nameLabelInset.minY + knobHeight,
                                                       width: nameLabelInset.width,
                                                       height: nameLabelTextHeight),
                                            withAttributes: nameLabelFontAttributes)
        context.restoreGState()

        let knobDiameter = min(width, height) - AKRotaryKnob.marginSize * 2.0
        knobCenter = CGPoint(x: AKRotaryKnob.marginSize + knobDiameter / 2.0,
                             y: AKRotaryKnob.marginSize + knobDiameter / 2.0)

        let valuePercent = val
        let angle = Double.pi * (0.75 + Double(valuePercent) * 1.5)
        let indicatorStart = CGPoint(x: (knobDiameter / 5.0) * CGFloat(cos(angle)),
                                     y: (knobDiameter / 5.0) * CGFloat(sin(angle)))
        let indicatorEnd = CGPoint(x: (knobDiameter / 2.0) * CGFloat(cos(angle)),
                                   y: (knobDiameter / 2.0) * CGFloat(sin(angle)))

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
            case .polygon(let numberOfSides, let curvature):
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

        let indicatorPath = UIBezierPath()
        indicatorPath.move(to: CGPoint(x: AKRotaryKnob.marginSize + knobDiameter / 2.0 + indicatorStart.x,
                                       y: AKRotaryKnob.marginSize + knobDiameter / 2.0 + indicatorStart.y))
        indicatorPath.addLine(to: CGPoint(x: AKRotaryKnob.marginSize + knobDiameter / 2.0 + indicatorEnd.x,
                                          y: AKRotaryKnob.marginSize + knobDiameter / 2.0 + indicatorEnd.y))
        indicatorPath.lineWidth = knobBorderWidth / 2.0
        indicatorColorForTheme().setStroke()
        indicatorPath.stroke()

        let pointRadius = (knobDiameter / 2.0) + AKRotaryKnob.marginSize * 0.6
        for index in 0...numberOfIndicatorPoints - 1 {
            let pointPercent = Double(index) / Double(numberOfIndicatorPoints - 1)
            let pointAngle = Double.pi * (0.75 + pointPercent * 1.5)
            let pointX = AKRotaryKnob.marginSize + knobDiameter / 2.0 + pointRadius * CGFloat(cos(pointAngle)) -
                AKRotaryKnob.indicatorPointRadius
            let pointY = AKRotaryKnob.marginSize + knobDiameter / 2.0 + pointRadius * CGFloat(sin(pointAngle)) -
                AKRotaryKnob.indicatorPointRadius
            let pointRect = CGRect(x: pointX, y: pointY, width: AKRotaryKnob.indicatorPointRadius * 2.0,
                                   height: AKRotaryKnob.indicatorPointRadius * 2.0)
            let pointPath = UIBezierPath(roundedRect: pointRect,
                                         byRoundingCorners: .allCorners,
                                         cornerRadii: CGSize(width: AKRotaryKnob.indicatorPointRadius,
                                                             height: AKRotaryKnob.indicatorPointRadius))
            if valuePercent > 0.0, pointPercent <= Double(valuePercent) {
                knobColor.setFill()
            } else {
                knobColor.withAlphaComponent(0.2).setFill()
            }
            pointPath.fill()
        }

        if isDragging {
            let valueLabelRect = CGRect(x: 0, y: 0, width: width, height: height)
            let valueLabelStyle = NSMutableParagraphStyle()
            valueLabelStyle.alignment = .center

            let valueLabelFontAttributes = [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: bubbleFontSize),
                                            NSAttributedString.Key.foregroundColor: bubbleTextColor ?? textColor,
                                            NSAttributedString.Key.paragraphStyle: valueLabelStyle]

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
        for index in 0...numberOfSides {
            let angle = 2 * Double.pi * Double(index) / Double(numberOfSides) + offsetAngle
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
                let arcAngle = 2 * Double.pi * (Double(index) - 0.5) / Double(numberOfSides) + offsetAngle
                let arcX = rect.midX + (rect.width * CGFloat(1 + actualCurvature * 0.5)) / 2 * CGFloat(cos(arcAngle))
                let arcY = rect.midY + (rect.height * CGFloat(1 + actualCurvature * 0.5)) / 2 * CGFloat(sin(arcAngle))
                path.addQuadCurve(to: CGPoint(x: nextX, y: nextY), controlPoint: CGPoint(x: arcX, y: arcY))
            }
        }
        path.close()
        return path
    }
}

#else

import Cocoa
import AVFoundation

public enum AKRotaryKnobStyle {
    case round
    case polygon(numberOfSides: Int, curvature: Double)
}

@IBDesignable public class AKRotaryKnob: AKPropertyControl {

    // Default margin size
    static var marginSize: CGFloat = 30.0

    // Indicator point radius
    static var indicatorPointRadius: CGFloat = 3.0

    // Padding surrounding the text inside the value bubble
    static var bubblePadding = CGSize(width: 10.0, height: 2.0)

    // Margin between the top of the tap and the value bubble
    static var bubbleMargin: CGFloat = 3.0

    // Corner radius for the value bubble
    static var bubbleCornerRadius: CGFloat = 2.0

    // Maximum curvature value for polygon style knob
    static var maximumPolygonCurvature = 1.0

    /// Background color
    @IBInspectable open var bgColor: NSColor?

    /// Knob border color
    @IBInspectable open var knobBorderColor: NSColor?

    /// Knob indicator color
    @IBInspectable open var indicatorColor: NSColor?

    /// Knob overlay color
    @IBInspectable open var knobColor: NSColor = AKStylist.sharedInstance.nextColor

    /// Text color
    @IBInspectable open var textColor: NSColor?

    /// Bubble font size
    @IBInspectable open var bubbleFontSize: CGFloat = 12

    // Slider style. Curvature is a value between -1.0 and 1.0, where 0.0 indicates no curves
    open var knobStyle = AKRotaryKnobStyle.polygon(numberOfSides: 9, curvature: 0.0)

    // Border width
    @IBInspectable open var knobBorderWidth: CGFloat = 8.0

    // Value bubble border width
    @IBInspectable open var valueBubbleBorderWidth: CGFloat = 1.0

    // Number of indicator points
    @IBInspectable open var numberOfIndicatorPoints: Int = 11

    // Calculate knob center
    private var knobCenter: CGPoint = CGPoint.zero

    /// Initialize the slider
    public init(property: String,
                value: AUValue = 0.0,
                range: ClosedRange<AUValue> = 0 ... 1,
                taper: AUValue = 1,
                format: String = "%0.3f",
                color: AKColor = AKStylist.sharedInstance.nextColor,
                frame: CGRect = CGRect(width: 150, height: 170),
                callback: @escaping (_ x: AUValue) -> Void = { _ in }) {

        self.knobColor = color

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

    func angleBetween(pointA: CGPoint, pointB: CGPoint) -> Double {
        let deltaX = Double(pointB.x - pointA.x)
        let deltaY = Double(pointB.y - pointA.y)
        let radians = atan2(-deltaX, -deltaY)
        let degrees = radians * 180 / Double.pi
        return degrees
    }

    override public func mouseDown(with theEvent: NSEvent) {
        isDragging = true
        mouseDragged(with: theEvent)
    }

    override public func mouseDragged(with theEvent: NSEvent) {
        let loc = convert(theEvent.locationInWindow, from: nil)
        lastTouch = loc
        let angle = angleBetween(pointA: knobCenter, pointB: loc)
        if angle < 0.0 {
            val = (0.5 + 0.5 * (180.0 + AUValue(angle)) / 105.0)
        } else {
            val = AUValue(((angle - 75.0) / 110.0) * 0.5)
        }
        value = val.denormalized(to: range, taper: taper)
        callback(value)
    }

    public override func mouseUp(with theEvent: NSEvent) {
        isDragging = false
        needsDisplay = true
    }

    public func indicatorColorForTheme() -> AKColor {
        if let indicatorColor = indicatorColor {
            return indicatorColor
        }

        switch AKStylist.sharedInstance.theme {
        case .basic:
            return AKColor(white: 0.3, alpha: 1.0)
        case .midnight:
            return AKColor.white
        }
    }

    public func knobBorderColorForTheme() -> AKColor {
        if let knobBorderColor = knobBorderColor {
            return knobBorderColor
        }

        switch AKStylist.sharedInstance.theme {
        case .basic:
            return AKColor(white: 0.2, alpha: 1.0)
        case .midnight:
            return AKColor(white: 1.0, alpha: 1.0)
        }
    }

    public func textColorForTheme() -> AKColor {
        if let textColor = textColor {
            return textColor
        }

        switch AKStylist.sharedInstance.theme {
        case .basic:
            return AKColor(white: 0.3, alpha: 1.0)
        case .midnight:
            return AKColor.white
        }
    }

    override public func draw(_ rect: NSRect) {
        drawKnob(currentValue: CGFloat(val),
                 propertyName: property,
                 currentValueText: String(format: format, value))
    }

    func drawKnob(currentValue: CGFloat = 0,
                  initialValue: CGFloat = 0,
                  propertyName: String = "Property Name",
                  currentValueText: String = "0.0") {

        //// General Declarations
        let context = unsafeBitCast(NSGraphicsContext.current?.graphicsPort, to: CGContext.self)

        let width = self.frame.width
        let height = self.frame.height

        let nameLabelRect = CGRect(width: width, height: height)
        let nameLabelStyle = NSMutableParagraphStyle()
        nameLabelStyle.alignment = .center

        let textColor = textColorForTheme()

        let nameLabelFontAttributes: [NSAttributedString.Key: Any] = [.font: NSFont.boldSystemFont(ofSize: fontSize),
                                       .foregroundColor: textColor,
                                       .paragraphStyle: nameLabelStyle]

        let nameLabelTextHeight: CGFloat = NSString(string: propertyName).boundingRect(
            with: CGSize(width: width, height: .infinity),
            options: .usesLineFragmentOrigin,
            attributes: nameLabelFontAttributes).size.height
        context.saveGState()

        // Draw name label
        let nameLabelInset: CGRect = nameLabelRect.insetBy(dx: 0.0, dy: 0)
        context.clip(to: nameLabelInset)
        NSString(string: propertyName).draw(
            in: CGRect(x: nameLabelInset.minX,
                       y: nameLabelInset.minY,
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
        let angle = AUValue(Double.pi * (0.75 + Double(valuePercent) * 1.5))
        let indicatorStart = CGPoint(x: (knobDiameter / 5.0) * CGFloat(cos(angle)),
                                     y: nameLabelTextHeight - (knobDiameter / 5.0) * CGFloat(sin(angle)))
        let indicatorEnd = CGPoint(x: (knobDiameter / 2.0) * CGFloat(cos(angle)),
                                   y: nameLabelTextHeight - (knobDiameter / 2.0) * CGFloat(sin(angle)))

        // Draw knob
        let knobRect = CGRect(x: AKRotaryKnob.marginSize,
                              y: nameLabelTextHeight + AKRotaryKnob.marginSize,
                              width: knobDiameter,
                              height: knobDiameter)
        let knobPath: NSBezierPath = {
            switch self.knobStyle {
            case .round:
                return NSBezierPath(roundedRect: knobRect,
                                    xRadius: knobDiameter / 2.0,
                                    yRadius: knobDiameter / 2.0)
            case .polygon (let numberOfSides, let curvature):
                return bezierPathWithPolygonInRect(
                    knobRect,
                    numberOfSides: numberOfSides,
                    curvature: curvature,
                    startPoint: CGPoint(x: AKRotaryKnob.marginSize + knobDiameter / 2.0 + indicatorEnd.x,
                                        y: AKRotaryKnob.marginSize + knobDiameter / 2.0 + indicatorEnd.y),
                    offsetAngle: Double(angle))
            }
        }()

        knobPath.lineWidth = knobBorderWidth
        knobBorderColorForTheme().setStroke()
        knobPath.stroke()
        knobColor.setFill()
        knobPath.fill()

        // Draw indicator
        let indicatorPath = NSBezierPath()
        indicatorPath.move(to: CGPoint(x: AKRotaryKnob.marginSize + knobDiameter / 2.0 + indicatorStart.x,
                                       y: AKRotaryKnob.marginSize + knobDiameter / 2.0 + indicatorStart.y))
        indicatorPath.line(to: NSPoint(x: AKRotaryKnob.marginSize + knobDiameter / 2.0 + indicatorEnd.x,
                                       y: AKRotaryKnob.marginSize + knobDiameter / 2.0 + indicatorEnd.y))
        indicatorPath.lineWidth = knobBorderWidth / 2.0
        indicatorColorForTheme().setStroke()
        indicatorPath.stroke()

        // Draw points
        let pointRadius = (knobDiameter / 2.0) + AKRotaryKnob.marginSize * 0.6
        for i in 0...numberOfIndicatorPoints - 1 {
            let pointPercent = Double(i) / Double(numberOfIndicatorPoints - 1)
            let pointAngle = Double.pi * ( 0.75 + pointPercent * 1.5)
            let pointX = AKRotaryKnob.marginSize + knobDiameter / 2.0 +
                (pointRadius) * CGFloat(cos(pointAngle)) - AKRotaryKnob.indicatorPointRadius
            let pointY = AKRotaryKnob.marginSize + knobDiameter / 2.0 -
                (pointRadius) * CGFloat(sin(pointAngle)) - AKRotaryKnob.indicatorPointRadius + nameLabelTextHeight
            let pointRect = CGRect(x: pointX,
                                   y: pointY,
                                   width: AKRotaryKnob.indicatorPointRadius * 2.0,
                                   height: AKRotaryKnob.indicatorPointRadius * 2.0)
            let pointPath = NSBezierPath(roundedRect: pointRect,
                                         xRadius: AKRotaryKnob.indicatorPointRadius,
                                         yRadius: AKRotaryKnob.indicatorPointRadius)
            if valuePercent > 0.0 && pointPercent <= Double(valuePercent) {
                knobColor.setFill()
            } else {
                knobColor.withAlphaComponent(0.2).setFill()
            }
            pointPath.fill()
        }

        //// valueLabel Drawing
        if isDragging {
            let valueLabelRect = CGRect(width: width, height: height)
            let valueLabelStyle = NSMutableParagraphStyle()
            valueLabelStyle.alignment = .center

            let valueLabelFontAttributes: [NSAttributedString.Key: Any] =
                [.font: NSFont.boldSystemFont(ofSize: bubbleFontSize),
                 .foregroundColor: textColor,
                 .paragraphStyle: valueLabelStyle]

            let valueLabelInset: CGRect = valueLabelRect.insetBy(dx: 0, dy: 0)
            let valueLabelTextSize = NSString(string: currentValueText).boundingRect(
                with: CGSize(width: valueLabelInset.width, height: .infinity),
                options: .usesLineFragmentOrigin,
                attributes: valueLabelFontAttributes).size

            let bubbleSize = CGSize(width: valueLabelTextSize.width + AKRotaryKnob.bubblePadding.width,
                                    height: valueLabelTextSize.height + AKRotaryKnob.bubblePadding.height)

            var bubbleOriginX = (lastTouch.x - bubbleSize.width / 2.0 - valueBubbleBorderWidth)
            if bubbleOriginX < 0.0 {
                bubbleOriginX = valueBubbleBorderWidth
            } else if (bubbleOriginX + bubbleSize.width) > bounds.width {
                bubbleOriginX = bounds.width - bubbleSize.width - valueBubbleBorderWidth
            }

            var bubbleOriginY = (lastTouch.y + bubbleSize.height / 2.0 + valueBubbleBorderWidth)
            if bubbleOriginY > height - bubbleSize.height {
                bubbleOriginY = height - bubbleSize.height
            } else if bubbleOriginY < 0.0 {
                bubbleOriginY = 0.0
            }

            let bubbleRect = CGRect(x: bubbleOriginX,
                                    y: bubbleOriginY,
                                    width: bubbleSize.width,
                                    height: bubbleSize.height)

            let bubblePath = NSBezierPath(roundedRect: bubbleRect,
                                          xRadius: AKRotaryKnob.bubbleCornerRadius,
                                          yRadius: AKRotaryKnob.bubbleCornerRadius)
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
                                     offsetAngle: Double) -> NSBezierPath {
        guard numberOfSides > 2 else {
            return NSBezierPath(rect: rect)
        }

        let path = NSBezierPath()
        path.move(to: startPoint)
        for i in 0...numberOfSides {
            let angle = AUValue(2 * Double.pi * Double(i) / Double(numberOfSides) + offsetAngle)
            let nextX = rect.midX + rect.width / 2.0 * CGFloat(cos(angle))
            let nextY = rect.midY - rect.height / 2.0 * CGFloat(sin(angle))
            if curvature == 0.0 {
                path.line(to: NSPoint(x: nextX, y: nextY))
            } else {
                var actualCurvature = curvature
                if curvature > AKRotaryKnob.maximumPolygonCurvature {
                    actualCurvature = AKRotaryKnob.maximumPolygonCurvature
                }
                if curvature < AKRotaryKnob.maximumPolygonCurvature * -1.0 {
                    actualCurvature = AKRotaryKnob.maximumPolygonCurvature * -1.0
                }
                let arcAngle = 2 * Double.pi * (Double(i) - 0.5) / Double(numberOfSides) + offsetAngle
                let arcX = rect.midX + (rect.width * CGFloat(1 + actualCurvature * 0.25)) / 2 * CGFloat(cos(arcAngle))
                let arcY = rect.midY - (rect.height * CGFloat(1 + actualCurvature * 0.25)) / 2 * CGFloat(sin(arcAngle))
                path.curve(to: NSPoint(x: nextX, y: nextY),
                           controlPoint1: NSPoint(x: arcX, y: arcY),
                           controlPoint2: NSPoint(x: arcX, y: arcY))
            }
        }
        path.close()
        return path
    }
}

#endif
