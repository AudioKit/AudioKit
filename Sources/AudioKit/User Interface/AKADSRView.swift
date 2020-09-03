// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

#if !os(macOS) || targetEnvironment(macCatalyst)

import AVFoundation
import UIKit

/// A click and draggable view of an ADSR Envelope (Atttack, Decay, Sustain, Release)
@IBDesignable public class AKADSRView: UIView {

    /// Type of function to call when values of the ADSR have changed
    public typealias ADSRCallback = (AUValue, AUValue, AUValue, AUValue) -> Void

    /// Attack duration in seconds, Default: 0.1
    open var attackDuration: AUValue = 0.100

    /// Decay duration in seconds, Default: 0.1
    open var decayDuration: AUValue = 0.100

    /// Sustain Level (0-1), Default: 0.5
    open var sustainLevel: AUValue = 1.0

    /// Release duration in seconds, Default: 0.1
    open var releaseDuration: AUValue = 0.100

    /// Attack duration in milliseconds
    var attackTime: CGFloat {
        get {
            return CGFloat(attackDuration * 1_000.0)
        }
        set {
            attackDuration = AUValue(newValue / 1_000.0)
        }
    }

    /// Decay duration in milliseconds
    var decayTime: CGFloat {
        get {
            return CGFloat(decayDuration * 1_000.0)
        }
        set {
            decayDuration = AUValue(newValue / 1_000.0)
        }
    }

    /// Sustain level as a percentage 0% - 100%
    var sustainPercent: CGFloat {
        get {
            return CGFloat(sustainLevel * 100.0)
        }
        set {
            sustainLevel = AUValue(newValue / 100.0)
        }
    }

    /// Release duration in milliseconds
    var releaseTime: CGFloat {
        get {
            return CGFloat(releaseDuration * 1_000.0)
        }
        set {
            releaseDuration = AUValue(newValue / 1_000.0)
        }
    }

    private var decaySustainTouchAreaPath = UIBezierPath()
    private var attackTouchAreaPath = UIBezierPath()
    private var releaseTouchAreaPath = UIBezierPath()

    /// Function to call when the values of the ADSR changes
    open var callback: ADSRCallback?
    private var currentDragArea = ""

    //// Color Declarations

    /// Color in the attack portion of the UI element
    @IBInspectable open var attackColor: UIColor = #colorLiteral(red: 0.767, green: 0.000, blue: 0.000, alpha: 1.000)

    /// Color in the decay portion of the UI element
    @IBInspectable open var decayColor: UIColor = #colorLiteral(red: 0.942, green: 0.648, blue: 0.000, alpha: 1.000)

    /// Color in the sustain portion of the UI element
    @IBInspectable open var sustainColor: UIColor = #colorLiteral(red: 0.320, green: 0.800, blue: 0.616, alpha: 1.000)

    /// Color in the release portion of the UI element
    @IBInspectable open var releaseColor: UIColor = #colorLiteral(red: 0.720, green: 0.519, blue: 0.888, alpha: 1.000)

    /// Background color
    @IBInspectable open var bgColor: UIColor = AKStylist.sharedInstance.bgColor

    /// Width of the envelope curve
    @IBInspectable open var curveStrokeWidth: CGFloat = 1

    /// Color of the envelope curve
    @IBInspectable open var curveColor: UIColor = .black

    var lastPoint = CGPoint.zero

    // MARK: - Initialization

    /// Initialize the view, usually with a callback
    public init(callback: ADSRCallback? = nil) {
        self.callback = callback
        super.init(frame: CGRect(x: 0, y: 0, width: 440, height: 150))
        backgroundColor = .clear
    }

    /// Initialization of the view from within interface builder
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    // MARK: - Storyboard Rendering

    /// Perform necessary operation to allow the view to be rendered in interface builder
    public override func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()

        contentMode = .scaleAspectFill
        clipsToBounds = true
    }

    /// Size of the view
    public override var intrinsicContentSize: CGSize {
        return CGSize(width: 440, height: 150)
    }

    /// Requeire a constraint based layout with interface builder
    public class override var requiresConstraintBasedLayout: Bool {
        return true
    }

    // MARK: - Touch Handling

    /// Handle new touches
    public override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first {
            let touchLocation = touch.location(in: self)

            if decaySustainTouchAreaPath.contains(touchLocation) {
                currentDragArea = "ds"
            }
            if attackTouchAreaPath.contains(touchLocation) {
                currentDragArea = "a"
            }
            if releaseTouchAreaPath.contains(touchLocation) {
                currentDragArea = "r"
            }
            lastPoint = touchLocation
        }
        setNeedsDisplay()
    }

    /// Handle moving touches
    public override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first {
            let touchLocation = touch.location(in: self)

            if currentDragArea != "" {
                if currentDragArea == "ds" {
                    sustainPercent -= (touchLocation.y - lastPoint.y) / 10.0
                    decayTime += touchLocation.x - lastPoint.x
                }
                if currentDragArea == "a" {
                    attackTime += touchLocation.x - lastPoint.x
                    attackTime -= touchLocation.y - lastPoint.y
                }
                if currentDragArea == "r" {
                    releaseTime += touchLocation.x - lastPoint.x
                    releaseTime -= touchLocation.y - lastPoint.y
                }
            }
            attackTime = max(attackTime, 0)
            decayTime = max(decayTime, 0)
            releaseTime = max(releaseTime, 0)
            sustainPercent = min(max(sustainPercent, 0), 100)

            if let realCallback = self.callback {
                realCallback(AUValue(attackTime / 1_000.0),
                             AUValue(decayTime / 1_000.0),
                             AUValue(sustainPercent / 100.0),
                             AUValue(releaseTime / 1_000.0))
            }
            lastPoint = touchLocation
        }
        setNeedsDisplay()
    }

    // MARK: - Drawing

    /// Draw the ADSR envelope
    func drawCurveCanvas(size: CGSize = CGSize(width: 440, height: 151),
                         attackDurationMS: CGFloat = 449,
                         decayDurationMS: CGFloat = 262,
                         releaseDurationMS: CGFloat = 448,
                         sustainLevel: CGFloat = 0.583,
                         maxADFraction: CGFloat = 0.75) {
        //// General Declarations
        let context = UIGraphicsGetCurrentContext()

        //// Variable Declarations
        let attackClickRoom = CGFloat(30) // to allow the attack to be clicked even if is zero
        let oneSecond: CGFloat = 0.65 * size.width
        let initialPoint = CGPoint(x: attackClickRoom, y: size.height)
        let buffer = CGFloat(10)//curveStrokeWidth / 2.0 // make a little room for drwing the stroke
        let endAxes = CGPoint(x: size.width, y: size.height)
        let releasePoint = CGPoint(x: attackClickRoom + oneSecond, y: sustainLevel * (size.height - buffer) + buffer)
        let endPoint = CGPoint(x: releasePoint.x + releaseDurationMS / 1_000.0 * oneSecond, y: size.height)
        let endMax = CGPoint(x: min(endPoint.x, size.width), y: buffer)
        let releaseAxis = CGPoint(x: releasePoint.x, y: endPoint.y)
        let releaseMax = CGPoint(x: releasePoint.x, y: buffer)
        let highPoint = CGPoint(x: attackClickRoom +
            min(oneSecond * maxADFraction, attackDurationMS / 1_000.0 * oneSecond),
                                y: buffer)
        let highPointAxis = CGPoint(x: highPoint.x, y: size.height)
        let highMax = CGPoint(x: highPoint.x, y: buffer)
        let minthing = min(oneSecond * maxADFraction, (attackDurationMS + decayDurationMS) / 1_000.0 * oneSecond)
        let sustainPoint = CGPoint(x: max(highPoint.x, attackClickRoom + minthing),
                                   y: sustainLevel * (size.height - buffer) + buffer)
        let sustainAxis = CGPoint(x: sustainPoint.x, y: size.height)
        let initialMax = CGPoint(x: 0, y: buffer)

        let initialToHighControlPoint = CGPoint(x: initialPoint.x, y: highPoint.y)
        let highToSustainControlPoint = CGPoint(x: highPoint.x, y: sustainPoint.y)
        let releaseToEndControlPoint = CGPoint(x: releasePoint.x, y: endPoint.y)

        //// attackTouchArea Drawing
        context?.saveGState()

        attackTouchAreaPath = UIBezierPath()
        attackTouchAreaPath.move(to: CGPoint(x: 0, y: size.height))
        attackTouchAreaPath.addLine(to: highPointAxis)
        attackTouchAreaPath.addLine(to: highMax)
        attackTouchAreaPath.addLine(to: initialMax)
        attackTouchAreaPath.addLine(to: CGPoint(x: 0, y: size.height))
        attackTouchAreaPath.close()
        bgColor.setFill()
        attackTouchAreaPath.fill()

        context?.restoreGState()

        //// decaySustainTouchArea Drawing
        context?.saveGState()

        decaySustainTouchAreaPath = UIBezierPath()
        decaySustainTouchAreaPath.move(to: highPointAxis)
        decaySustainTouchAreaPath.addLine(to: releaseAxis)
        decaySustainTouchAreaPath.addLine(to: releaseMax)
        decaySustainTouchAreaPath.addLine(to: highMax)
        decaySustainTouchAreaPath.addLine(to: highPointAxis)
        decaySustainTouchAreaPath.close()
        bgColor.setFill()
        decaySustainTouchAreaPath.fill()

        context?.restoreGState()

        //// releaseTouchArea Drawing
        context?.saveGState()

        releaseTouchAreaPath = UIBezierPath()
        releaseTouchAreaPath.move(to: releaseAxis)
        releaseTouchAreaPath.addLine(to: endAxes)
        releaseTouchAreaPath.addLine(to: endMax)
        releaseTouchAreaPath.addLine(to: releaseMax)
        releaseTouchAreaPath.addLine(to: releaseAxis)
        releaseTouchAreaPath.close()
        bgColor.setFill()
        releaseTouchAreaPath.fill()

        context?.restoreGState()

        //// releaseArea Drawing
        context?.saveGState()

        let releaseAreaPath = UIBezierPath()
        releaseAreaPath.move(to: releaseAxis)
        releaseAreaPath.addCurve(to: endPoint,
                                        controlPoint1: releaseAxis,
                                        controlPoint2: endPoint)
        releaseAreaPath.addCurve(to: releasePoint,
                                        controlPoint1: releaseToEndControlPoint,
                                        controlPoint2: releasePoint)
        releaseAreaPath.addLine(to: releaseAxis)
        releaseAreaPath.close()
        releaseColor.setFill()
        releaseAreaPath.fill()

        context?.restoreGState()

        //// sustainArea Drawing
        context?.saveGState()

        let sustainAreaPath = UIBezierPath()
        sustainAreaPath.move(to: sustainAxis)
        sustainAreaPath.addLine(to: releaseAxis)
        sustainAreaPath.addLine(to: releasePoint)
        sustainAreaPath.addLine(to: sustainPoint)
        sustainAreaPath.addLine(to: sustainAxis)
        sustainAreaPath.close()
        sustainColor.setFill()
        sustainAreaPath.fill()

        context?.restoreGState()

        //// decayArea Drawing
        context?.saveGState()

        let decayAreaPath = UIBezierPath()
        decayAreaPath.move(to: highPointAxis)
        decayAreaPath.addLine(to: sustainAxis)
        decayAreaPath.addCurve(to: sustainPoint,
                                      controlPoint1: sustainAxis,
                                      controlPoint2: sustainPoint)
        decayAreaPath.addCurve(to: highPoint,
                                      controlPoint1: highToSustainControlPoint,
                                      controlPoint2: highPoint)
        decayAreaPath.addLine(to: highPoint)
        decayAreaPath.close()
        decayColor.setFill()
        decayAreaPath.fill()

        context?.restoreGState()

        //// attackArea Drawing
        context?.saveGState()

        let attackAreaPath = UIBezierPath()
        attackAreaPath.move(to: initialPoint)
        attackAreaPath.addLine(to: highPointAxis)
        attackAreaPath.addLine(to: highPoint)
        attackAreaPath.addCurve(to: initialPoint,
                                       controlPoint1: initialToHighControlPoint,
                                       controlPoint2: initialPoint)
        attackAreaPath.close()
        attackColor.setFill()
        attackAreaPath.fill()

        context?.restoreGState()

        //// Curve Drawing
        context?.saveGState()

        let curvePath = UIBezierPath()
        curvePath.move(to: initialPoint)
        curvePath.addCurve(to: highPoint,
                                  controlPoint1: initialPoint,
                                  controlPoint2: initialToHighControlPoint)
        curvePath.addCurve(to: sustainPoint,
                                  controlPoint1: highPoint,
                                  controlPoint2: highToSustainControlPoint)
        curvePath.addLine(to: releasePoint)
        curvePath.addCurve(to: endPoint,
                                  controlPoint1: releasePoint,
                                  controlPoint2: releaseToEndControlPoint)
        curveColor.setStroke()
        curvePath.lineWidth = curveStrokeWidth
        curvePath.stroke()

        context?.restoreGState()
    }

    /// Draw the view
    public override func draw(_ rect: CGRect) {
        drawCurveCanvas(size: rect.size, attackDurationMS: attackTime,
                        decayDurationMS: decayTime,
                        releaseDurationMS: releaseTime,
                        sustainLevel: 1.0 - sustainPercent / 100.0)
    }
}

#else

import AVFoundation
import Cocoa

public typealias ADSRCallback = (AUValue, AUValue, AUValue, AUValue) -> Void

public class AKADSRView: NSView {

    public var attackDuration: AUValue = 0.1
    public var decayDuration: AUValue = 0.1
    public var sustainLevel: AUValue = 0.1
    public var releaseDuration: AUValue = 0.1

    var decaySustainTouchAreaPath = NSBezierPath()
    var attackTouchAreaPath = NSBezierPath()
    var releaseTouchAreaPath = NSBezierPath()

    public var callback: ADSRCallback
    var currentDragArea = ""

    var lastPoint = CGPoint.zero

    override public var isFlipped: Bool {
        return true
    }
    override public var wantsDefaultClipping: Bool {
        return false
    }

    override public func mouseDown(with theEvent: NSEvent) {

        let touchLocation = convert(theEvent.locationInWindow, from: nil)
        if decaySustainTouchAreaPath.contains(touchLocation) {
            currentDragArea = "ds"
        }
        if attackTouchAreaPath.contains(touchLocation) {
            currentDragArea = "a"
        }
        if releaseTouchAreaPath.contains(touchLocation) {
            currentDragArea = "r"
        }
        lastPoint = touchLocation
        needsDisplay = true
    }

    override public func mouseDragged(with theEvent: NSEvent) {

        let touchLocation = convert(theEvent.locationInWindow, from: nil)

        if currentDragArea != "" {
            if currentDragArea == "ds" {
                sustainLevel = 1.0 - AUValue(touchLocation.y) / AUValue(frame.height)
                decayDuration += AUValue(touchLocation.x - lastPoint.x) / 1_000.0
            }
            if currentDragArea == "a" {
                attackDuration += AUValue(touchLocation.x - lastPoint.x) / 1_000.0
                attackDuration -= AUValue(touchLocation.y - lastPoint.y) / 1_000.0
            }
            if currentDragArea == "r" {
                releaseDuration += AUValue(touchLocation.x - lastPoint.x) / 500.0
                releaseDuration -= AUValue(touchLocation.y - lastPoint.y) / 500.0
            }
        }
        if attackDuration < 0 { attackDuration = 0 }
        if decayDuration < 0 { decayDuration = 0 }
        if releaseDuration < 0 { releaseDuration = 0 }
        if sustainLevel < 0 { sustainLevel = 0 }
        if sustainLevel > 1 { sustainLevel = 1 }

        self.callback(attackDuration, decayDuration, sustainLevel, releaseDuration)
        lastPoint = touchLocation
        needsDisplay = true
    }

    public init(frame: CGRect = CGRect(width: 440, height: 150),
                callback: @escaping ADSRCallback) {
        self.callback = callback
        super.init(frame: frame)
    }

    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func drawCurveCanvas(size: NSSize = NSSize(width: 440, height: 151),
                         attackDurationMS: CGFloat = 456,
                         decayDurationMS: CGFloat = 262,
                         releaseDurationMS: CGFloat = 448,
                         sustainLevel: CGFloat = 0.583,
                         maxADFraction: CGFloat = 0.75) {
        //// General Declarations
        _ = NSGraphicsContext.current?.cgContext

        //// Color Declarations
        let attackColor = #colorLiteral(red: 0.767, green: 0, blue: 0, alpha: 1)
        let decayColor = #colorLiteral(red: 0.942, green: 0.648, blue: 0, alpha: 1)
        let sustainColor = #colorLiteral(red: 0.32, green: 0.8, blue: 0.616, alpha: 1)
        let releaseColor = #colorLiteral(red: 0.72, green: 0.519, blue: 0.888, alpha: 1)
        let backgroundColor = AKStylist.sharedInstance.bgColor

        self.wantsLayer = true
        self.layer?.backgroundColor = backgroundColor.cgColor

        //// Variable Declarations
        let attackClickRoom = CGFloat(30) // to allow the attack to be clicked even if is zero
        let oneSecond: CGFloat = 0.7 * size.width
        let initialPoint = NSPoint(x: attackClickRoom, y: size.height)
        let curveStrokeWidth: CGFloat = min(max(1, size.height / 50.0), max(1, size.width / 100.0))
        let buffer = CGFloat(10)//curveStrokeWidth / 2.0 // make a little room for drwing the stroke
        let endAxes = NSPoint(x: size.width, y: size.height)
        let releasePoint = NSPoint(x: attackClickRoom + oneSecond,
                                   y: sustainLevel * (size.height - buffer) + buffer)
        let endPoint = NSPoint(x: releasePoint.x + releaseDurationMS / 1_000.0 * oneSecond,
                               y: size.height)
        let endMax = NSPoint(x: min(endPoint.x, size.width), y: buffer)
        let releaseAxis = NSPoint(x: releasePoint.x, y: endPoint.y)
        let releaseMax = NSPoint(x: releasePoint.x, y: buffer)
        let highPoint = NSPoint(x: attackClickRoom +
            min(oneSecond * maxADFraction, attackDurationMS / 1_000.0 * oneSecond),
                                y: buffer)
        let highPointAxis = NSPoint(x: highPoint.x, y: size.height)
        let highMax = NSPoint(x: highPoint.x, y: buffer)
        let sustainPoint = NSPoint(
            x: max(highPoint.x, attackClickRoom +
                min(oneSecond * maxADFraction,
                    (attackDurationMS + decayDurationMS) / 1_000.0 * oneSecond)),
            y: sustainLevel * (size.height - buffer) + buffer)
        let sustainAxis = NSPoint(x: sustainPoint.x, y: size.height)
        let initialMax = NSPoint(x: 0, y: buffer)

        let initialToHighControlPoint = NSPoint(x: initialPoint.x, y: highPoint.y)
        let highToSustainControlPoint = NSPoint(x: highPoint.x, y: sustainPoint.y)
        let releaseToEndControlPoint = NSPoint(x: releasePoint.x, y: endPoint.y)

        //// attackTouchArea Drawing
        NSGraphicsContext.saveGraphicsState()

        attackTouchAreaPath = NSBezierPath()
        attackTouchAreaPath.move(to: NSPoint(x: 0, y: size.height))
        attackTouchAreaPath.line(to: highPointAxis)
        attackTouchAreaPath.line(to: highMax)
        attackTouchAreaPath.line(to: initialMax)
        attackTouchAreaPath.line(to: NSPoint(x: 0, y: size.height))
        attackTouchAreaPath.close()
        backgroundColor.setFill()
        attackTouchAreaPath.fill()

        NSGraphicsContext.restoreGraphicsState()

        //// decaySustainTouchArea Drawing
        NSGraphicsContext.saveGraphicsState()

        decaySustainTouchAreaPath = NSBezierPath()
        decaySustainTouchAreaPath.move(to: highPointAxis)
        decaySustainTouchAreaPath.line(to: releaseAxis)
        decaySustainTouchAreaPath.line(to: releaseMax)
        decaySustainTouchAreaPath.line(to: highMax)
        decaySustainTouchAreaPath.line(to: highPointAxis)
        decaySustainTouchAreaPath.close()
        backgroundColor.setFill()
        decaySustainTouchAreaPath.fill()

        NSGraphicsContext.restoreGraphicsState()

        //// releaseTouchArea Drawing
        NSGraphicsContext.saveGraphicsState()

        releaseTouchAreaPath = NSBezierPath()
        releaseTouchAreaPath.move(to: releaseAxis)
        releaseTouchAreaPath.line(to: endAxes)
        releaseTouchAreaPath.line(to: endMax)
        releaseTouchAreaPath.line(to: releaseMax)
        releaseTouchAreaPath.line(to: releaseAxis)
        releaseTouchAreaPath.close()
        backgroundColor.setFill()
        releaseTouchAreaPath.fill()

        NSGraphicsContext.restoreGraphicsState()

        //// releaseArea Drawing
        NSGraphicsContext.saveGraphicsState()

        let releaseAreaPath = NSBezierPath()
        releaseAreaPath.move(to: releaseAxis)
        releaseAreaPath.curve(to: endPoint,
                              controlPoint1: releaseAxis,
                              controlPoint2: endPoint)
        releaseAreaPath.curve(to: releasePoint,
                              controlPoint1: releaseToEndControlPoint,
                              controlPoint2: releasePoint)
        releaseAreaPath.line(to: releaseAxis)
        releaseAreaPath.close()
        releaseColor.setFill()
        releaseAreaPath.fill()

        NSGraphicsContext.restoreGraphicsState()

        //// sustainArea Drawing
        NSGraphicsContext.saveGraphicsState()

        let sustainAreaPath = NSBezierPath()
        sustainAreaPath.move(to: sustainAxis)
        sustainAreaPath.line(to: releaseAxis)
        sustainAreaPath.line(to: releasePoint)
        sustainAreaPath.line(to: sustainPoint)
        sustainAreaPath.line(to: sustainAxis)
        sustainAreaPath.close()
        sustainColor.setFill()
        sustainAreaPath.fill()

        NSGraphicsContext.restoreGraphicsState()

        //// decayArea Drawing
        NSGraphicsContext.saveGraphicsState()

        let decayAreaPath = NSBezierPath()
        decayAreaPath.move(to: highPointAxis)
        decayAreaPath.line(to: sustainAxis)
        decayAreaPath.curve(to: sustainPoint,
                            controlPoint1: sustainAxis,
                            controlPoint2: sustainPoint)
        decayAreaPath.curve(to: highPoint,
                            controlPoint1: highToSustainControlPoint,
                            controlPoint2: highPoint)
        decayAreaPath.line(to: highPoint)
        decayAreaPath.close()
        decayColor.setFill()
        decayAreaPath.fill()

        NSGraphicsContext.restoreGraphicsState()

        //// attackArea Drawing
        NSGraphicsContext.saveGraphicsState()

        let attackAreaPath = NSBezierPath()
        attackAreaPath.move(to: initialPoint)
        attackAreaPath.line(to: highPointAxis)
        attackAreaPath.line(to: highPoint)
        attackAreaPath.curve(to: initialPoint,
                             controlPoint1: initialToHighControlPoint,
                             controlPoint2: initialPoint)
        attackAreaPath.close()
        attackColor.setFill()
        attackAreaPath.fill()

        NSGraphicsContext.restoreGraphicsState()

        //// Curve Drawing
        NSGraphicsContext.saveGraphicsState()

        let curvePath = NSBezierPath()
        curvePath.move(to: initialPoint)
        curvePath.curve(to: highPoint,
                        controlPoint1: initialPoint,
                        controlPoint2: initialToHighControlPoint)
        curvePath.curve(to: sustainPoint,
                        controlPoint1: highPoint,
                        controlPoint2: highToSustainControlPoint)
        curvePath.line(to: releasePoint)
        curvePath.curve(to: endPoint,
                        controlPoint1: releasePoint,
                        controlPoint2: releaseToEndControlPoint)
        NSColor.black.setStroke()
        curvePath.lineWidth = curveStrokeWidth
        curvePath.stroke()

        NSGraphicsContext.restoreGraphicsState()
    }

    override public func draw(_ rect: CGRect) {
        drawCurveCanvas(size: rect.size,
                        attackDurationMS: CGFloat(attackDuration * 1_000),
                        decayDurationMS: CGFloat(decayDuration * 1_000),
                        releaseDurationMS: CGFloat(releaseDuration * 500),
                        sustainLevel: CGFloat(1.0 - sustainLevel))
    }
}
#endif
