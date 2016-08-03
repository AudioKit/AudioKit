//
//  AKADSRView.swift
//  AudioKit for macOS
//
//  Created by Aurelius Prochazka on 8/2/16.
//  Copyright © 2016 AudioKit. All rights reserved.
//

import Foundation
public typealias ADSRCallback = (Double, Double, Double, Double)->()

public class AKADSRView: NSView {

    var node: AKNode
    public var attackDuration = 0.1
    public var decayDuration = 0.1
    public var sustainLevel = 0.1
    public var releaseDuration = 0.1
    
    var decaySustainTouchAreaPath = NSBezierPath()
    var attackTouchAreaPath = NSBezierPath()
    var releaseTouchAreaPath = NSBezierPath()
    
    var callback: ADSRCallback
    var currentDragArea = ""
 
    var lastPoint = CGPointZero
    
    override public var flipped: Bool {
        get {
            return true
        }
    }
    
    override public func mouseDown(theEvent: NSEvent) {
        
        let touchLocation = convertPoint(theEvent.locationInWindow, fromView: nil)
        if decaySustainTouchAreaPath.containsPoint(touchLocation) {
            currentDragArea = "ds"
        }
        if attackTouchAreaPath.containsPoint(touchLocation) {
            currentDragArea = "a"
        }
        if releaseTouchAreaPath.containsPoint(touchLocation) {
            currentDragArea = "r"
        }
        lastPoint = touchLocation
        needsDisplay = true
    }

    override public func mouseDragged(theEvent: NSEvent) {

        let touchLocation = convertPoint(theEvent.locationInWindow, fromView: nil)

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
        self.callback(attackDuration, decayDuration, sustainLevel, releaseDuration)
        lastPoint = touchLocation
        needsDisplay = true
    }


    public init(node: AKNode, frame: CGRect = CGRect(x: 0, y: 0, width: 440, height: 150), callback: ADSRCallback) {
        self.node = node
        self.callback = callback
        super.init(frame: frame)
    }

    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func drawCurveCanvas(size size: NSSize = NSMakeSize(440, 151), attackDurationMS: CGFloat = 456, decayDurationMS: CGFloat = 262, releaseDurationMS: CGFloat = 448, sustainLevel: CGFloat = 0.583, maxADFraction: CGFloat = 0.75) {
        //// General Declarations
        let _ = NSGraphicsContext.currentContext()!.CGContext

        //// Color Declarations
        let attackColor     = NSColor(calibratedRed: 0.767, green: 0, blue: 0, alpha: 1)
        let decayColor      = NSColor(calibratedRed: 0.942, green: 0.648, blue: 0, alpha: 1)
        let sustainColor    = NSColor(calibratedRed: 0.32, green: 0.8, blue: 0.616, alpha: 1)
        let releaseColor    = NSColor(calibratedRed: 0.72, green: 0.519, blue: 0.888, alpha: 1)
        let backgroundColor = NSColor(calibratedRed: 1, green: 1, blue: 1, alpha: 1)

        //// Variable Declarations
        let oneSecond: CGFloat = 0.7 * size.width
        let initialPoint: NSPoint = NSMakePoint(0, size.height)
        let curveStrokeWidth: CGFloat = min(max(1, size.height / 50.0), max(1, size.width / 100.0))
        let endAxes: NSPoint = NSMakePoint(size.width, size.height)
        let releasePoint: NSPoint = NSMakePoint(oneSecond, sustainLevel * size.height)
        let endPoint: NSPoint = NSMakePoint(releasePoint.x + releaseDurationMS / 1000.0 * oneSecond, size.height + 0)
        let endMax: NSPoint = NSMakePoint(min(endPoint.x, size.width), 0)
        let releaseAxis: NSPoint = NSMakePoint(releasePoint.x, endPoint.y)
        let releaseMax: NSPoint = NSMakePoint(releasePoint.x, 0)
        let highPoint: NSPoint = NSMakePoint(max(0, min(oneSecond * maxADFraction, attackDurationMS / 1000.0 * oneSecond)), 2)
        let highPointAxis: NSPoint = NSMakePoint(highPoint.x, size.height)
        let highMax: NSPoint = NSMakePoint(highPoint.x, 0)
        let sustainPoint: NSPoint = NSMakePoint(max(highPoint.x, min(oneSecond * maxADFraction, (attackDurationMS + decayDurationMS) / 1000.0 * oneSecond)), sustainLevel * size.height)
        let sustainAxis: NSPoint = NSMakePoint(sustainPoint.x, size.height)
        let initialMax: NSPoint = NSMakePoint(0, 0)
        
        
        let halfInitialToHighPoint = NSMakePoint((highPoint.x + initialPoint.x) / 2.0, highPoint.y)
        let halfHighToSustainPoint = NSMakePoint((highPoint.x + sustainPoint.x) / 2.0, sustainPoint.y)
        let halfReleaseToEndPoint = NSMakePoint((releasePoint.x + endPoint.x) / 2.0, endPoint.y)


        //// attackTouchArea Drawing
        NSGraphicsContext.saveGraphicsState()

        attackTouchAreaPath = NSBezierPath()
        attackTouchAreaPath.moveToPoint(initialPoint)
        attackTouchAreaPath.lineToPoint(highPointAxis)
        attackTouchAreaPath.lineToPoint(highMax)
        attackTouchAreaPath.lineToPoint(initialMax)
        attackTouchAreaPath.lineToPoint(initialPoint)
        attackTouchAreaPath.closePath()
        backgroundColor.setFill()
        attackTouchAreaPath.fill()

        NSGraphicsContext.restoreGraphicsState()


        //// decaySustainTouchArea Drawing
        NSGraphicsContext.saveGraphicsState()

        decaySustainTouchAreaPath = NSBezierPath()
        decaySustainTouchAreaPath.moveToPoint(highPointAxis)
        decaySustainTouchAreaPath.lineToPoint(releaseAxis)
        decaySustainTouchAreaPath.lineToPoint(releaseMax)
        decaySustainTouchAreaPath.lineToPoint(highMax)
        decaySustainTouchAreaPath.lineToPoint(highPointAxis)
        decaySustainTouchAreaPath.closePath()
        backgroundColor.setFill()
        decaySustainTouchAreaPath.fill()

        NSGraphicsContext.restoreGraphicsState()


        //// releaseTouchArea Drawing
        NSGraphicsContext.saveGraphicsState()

        releaseTouchAreaPath = NSBezierPath()
        releaseTouchAreaPath.moveToPoint(releaseAxis)
        releaseTouchAreaPath.lineToPoint(endAxes)
        releaseTouchAreaPath.lineToPoint(endMax)
        releaseTouchAreaPath.lineToPoint(releaseMax)
        releaseTouchAreaPath.lineToPoint(releaseAxis)
        releaseTouchAreaPath.closePath()
        backgroundColor.setFill()
        releaseTouchAreaPath.fill()

        NSGraphicsContext.restoreGraphicsState()


        //// releaseArea Drawing
        NSGraphicsContext.saveGraphicsState()

        let releaseAreaPath = NSBezierPath()
        releaseAreaPath.moveToPoint(releaseAxis)
        releaseAreaPath.curveToPoint(endPoint,
                                     controlPoint1: releaseAxis,
                                     controlPoint2: endPoint)
        releaseAreaPath.curveToPoint(releasePoint,
                                     controlPoint1: halfReleaseToEndPoint,
                                     controlPoint2: releasePoint)
        releaseAreaPath.lineToPoint(releaseAxis)
        releaseAreaPath.closePath()
        releaseColor.setFill()
        releaseAreaPath.fill()

        NSGraphicsContext.restoreGraphicsState()


        //// sustainArea Drawing
        NSGraphicsContext.saveGraphicsState()

        let sustainAreaPath = NSBezierPath()
        sustainAreaPath.moveToPoint(sustainAxis)
        sustainAreaPath.lineToPoint(releaseAxis)
        sustainAreaPath.lineToPoint(releasePoint)
        sustainAreaPath.lineToPoint(sustainPoint)
        sustainAreaPath.lineToPoint(sustainAxis)
        sustainAreaPath.closePath()
        sustainColor.setFill()
        sustainAreaPath.fill()

        NSGraphicsContext.restoreGraphicsState()


        //// decayArea Drawing
        NSGraphicsContext.saveGraphicsState()

        let decayAreaPath = NSBezierPath()
        decayAreaPath.moveToPoint(highPointAxis)
        decayAreaPath.lineToPoint(sustainAxis)
        decayAreaPath.curveToPoint(sustainPoint,
                                   controlPoint1: sustainAxis,
                                   controlPoint2: sustainPoint)
        decayAreaPath.curveToPoint(highPoint,
                                   controlPoint1: halfHighToSustainPoint,
                                   controlPoint2: highPoint)
        decayAreaPath.lineToPoint(highPoint)
        decayAreaPath.closePath()
        decayColor.setFill()
        decayAreaPath.fill()

        NSGraphicsContext.restoreGraphicsState()


        //// attackArea Drawing
        NSGraphicsContext.saveGraphicsState()

        let attackAreaPath = NSBezierPath()
        attackAreaPath.moveToPoint(initialPoint)
        attackAreaPath.lineToPoint(highPointAxis)
        attackAreaPath.lineToPoint(highPoint)
        attackAreaPath.curveToPoint(initialPoint,
                                    controlPoint1: halfInitialToHighPoint,
                                    controlPoint2: initialPoint)
        attackAreaPath.closePath()
        attackColor.setFill()
        attackAreaPath.fill()

        NSGraphicsContext.restoreGraphicsState()

        //// Curve Drawing
        NSGraphicsContext.saveGraphicsState()

        let curvePath = NSBezierPath()
        curvePath.moveToPoint(initialPoint)
        curvePath.curveToPoint(highPoint,
                               controlPoint1: initialPoint,
                               controlPoint2: halfInitialToHighPoint)
        curvePath.curveToPoint(sustainPoint,
                               controlPoint1: highPoint,
                               controlPoint2: halfHighToSustainPoint)
        curvePath.lineToPoint(releasePoint)
        curvePath.curveToPoint(endPoint,
                               controlPoint1: releasePoint,
                               controlPoint2: halfReleaseToEndPoint)
        NSColor.blackColor().setStroke()
        curvePath.lineWidth = curveStrokeWidth
        curvePath.stroke()

        NSGraphicsContext.restoreGraphicsState()
    }



    override public func drawRect(rect: CGRect) {
        drawCurveCanvas(attackDurationMS: CGFloat(attackDuration * 1000),
                        decayDurationMS: CGFloat(decayDuration * 1000),
                        releaseDurationMS: CGFloat(releaseDuration * 500),
                        sustainLevel: CGFloat(1.0 - sustainLevel))
    }
}
