//
//  AKADSRView.swift
//  AudioKit for macOS
//
//  Created by Aurelius Prochazka on 8/2/16.
//  Copyright © 2016 AudioKit. All rights reserved.
//

import Foundation
public typealias ADSRCallback = (Double, Double, Double, Double)->Void

public class AKADSRView: NSView {

    public var attackDuration = 0.1
    public var decayDuration = 0.1
    public var sustainLevel = 0.1
    public var releaseDuration = 0.1

    var decaySustainTouchAreaPath = NSBezierPath()
    var attackTouchAreaPath = NSBezierPath()
    var releaseTouchAreaPath = NSBezierPath()

    var callback: ADSRCallback
    var currentDragArea = ""

    var lastPoint = CGPoint.zero

    override public var isFlipped: Bool {
        get {
            return true
        }
    }
    override public var wantsDefaultClipping: Bool {
        get {
            return false
        }
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
                sustainLevel = 1.0 - Double(touchLocation.y) / Double(frame.height)
                decayDuration += Double(touchLocation.x - lastPoint.x) / 1000.0
            }
            if currentDragArea == "a" {
                attackDuration += Double(touchLocation.x - lastPoint.x) / 1000.0
                attackDuration -= Double(touchLocation.y - lastPoint.y) / 1000.0
            }
            if currentDragArea == "r" {
                releaseDuration += Double(touchLocation.x - lastPoint.x) / 500.0
                releaseDuration -= Double(touchLocation.y - lastPoint.y) / 500.0
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

    public init(frame: CGRect = CGRect(x: 0, y: 0, width: 440, height: 150), callback: @escaping ADSRCallback) {
        self.callback = callback
        super.init(frame: frame)
    }

    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func drawCurveCanvas(size: NSSize = NSSize(width: 440, height: 151), attackDurationMS: CGFloat = 456, decayDurationMS: CGFloat = 262, releaseDurationMS: CGFloat = 448, sustainLevel: CGFloat = 0.583, maxADFraction: CGFloat = 0.75) {
        //// General Declarations
        let _ = NSGraphicsContext.current()!.cgContext

        //// Color Declarations
        let attackColor     = NSColor(calibratedRed: 0.767, green: 0, blue: 0, alpha: 1)
        let decayColor      = NSColor(calibratedRed: 0.942, green: 0.648, blue: 0, alpha: 1)
        let sustainColor    = NSColor(calibratedRed: 0.32, green: 0.8, blue: 0.616, alpha: 1)
        let releaseColor    = NSColor(calibratedRed: 0.72, green: 0.519, blue: 0.888, alpha: 1)
        let backgroundColor = NSColor(calibratedRed: 1, green: 1, blue: 1, alpha: 1)

        //// Variable Declarations
        let attackClickRoom = CGFloat(30) // to allow the attack to be clicked even if is zero
        let oneSecond: CGFloat = 0.7 * size.width
        let initialPoint = NSMakePoint(attackClickRoom, size.height)
        let curveStrokeWidth: CGFloat = min(max(1, size.height / 50.0), max(1, size.width / 100.0))
        let buffer = CGFloat(10)//curveStrokeWidth / 2.0 // make a little room for drwing the stroke
        let endAxes = NSMakePoint(size.width, size.height)
        let releasePoint = NSMakePoint(attackClickRoom + oneSecond, sustainLevel * (size.height - buffer) + buffer)
        let endPoint = NSMakePoint(releasePoint.x + releaseDurationMS / 1000.0 * oneSecond, size.height)
        let endMax = NSMakePoint(min(endPoint.x, size.width), buffer)
        let releaseAxis = NSMakePoint(releasePoint.x, endPoint.y)
        let releaseMax = NSMakePoint(releasePoint.x, buffer)
        let highPoint  = NSMakePoint(attackClickRoom + min(oneSecond * maxADFraction, attackDurationMS / 1000.0 * oneSecond), buffer)
        let highPointAxis = NSMakePoint(highPoint.x, size.height)
        let highMax = NSMakePoint(highPoint.x, buffer)
        let sustainPoint = NSMakePoint(max(highPoint.x, attackClickRoom + min(oneSecond * maxADFraction, (attackDurationMS + decayDurationMS) / 1000.0 * oneSecond)), sustainLevel * (size.height - buffer) + buffer)
        let sustainAxis = NSMakePoint(sustainPoint.x, size.height)
        let initialMax = NSPoint(x: 0, y: buffer)

        let initialToHighControlPoint = NSMakePoint(initialPoint.x, highPoint.y)
        let highToSustainControlPoint = NSMakePoint(highPoint.x, sustainPoint.y)
        let releaseToEndControlPoint = NSMakePoint(releasePoint.x, endPoint.y)

        //// attackTouchArea Drawing
        NSGraphicsContext.saveGraphicsState()

        attackTouchAreaPath = NSBezierPath()
        attackTouchAreaPath.move(to: NSMakePoint(0, size.height))
        attackTouchAreaPath.line(to: highPointAxis)
        attackTouchAreaPath.line(to: highMax)
        attackTouchAreaPath.line(to: initialMax)
        attackTouchAreaPath.line(to: NSMakePoint(0, size.height))
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
        drawCurveCanvas(attackDurationMS: CGFloat(attackDuration * 1000),
                        decayDurationMS: CGFloat(decayDuration * 1000),
                        releaseDurationMS: CGFloat(releaseDuration * 500),
                        sustainLevel: CGFloat(1.0 - sustainLevel))
    }
}
