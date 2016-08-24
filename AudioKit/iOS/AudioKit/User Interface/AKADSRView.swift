//
//  AKADSRView.swift
//  AudioKit for iOS
//
//  Created by Aurelius Prochazka on 8/3/16.
//  Copyright © 2016 AudioKit. All rights reserved.
//

import Foundation
import UIKit

@IBDesignable public class AKADSRView: UIView {
    public typealias ADSRCallback = (Double, Double, Double, Double)->()

    @IBInspectable public var attackDuration: Double  = 0.100
    @IBInspectable public var decayDuration: Double   = 0.100
    @IBInspectable public var sustainLevel: Double    = 0.50
    @IBInspectable public var releaseDuration: Double = 0.100

    var attackTime: CGFloat {
        get {
            return CGFloat(attackDuration * 1000.0)
        }
        set {
            attackDuration = Double(newValue / 1000.0)
        }
    }
    var decayTime: CGFloat {
        get {
            return CGFloat(decayDuration * 1000.0)
        }
        set {
            decayDuration = Double(newValue / 1000.0)
        }
    }
    
    var sustainPercent: CGFloat {
        get {
            return CGFloat(sustainLevel * 100.0)
        }
        set {
            sustainLevel = Double(newValue / 100.0)
        }
    }

    var releaseTime: CGFloat {
        get {
            return CGFloat(releaseDuration * 1000.0)
        }
        set {
            releaseDuration = Double(newValue / 1000.0)
        }
    }

    var decaySustainTouchAreaPath = UIBezierPath()
    var attackTouchAreaPath       = UIBezierPath()
    var releaseTouchAreaPath      = UIBezierPath()

    public var callback: ADSRCallback?
    var currentDragArea = ""

    //// Color Declarations
    @IBInspectable public var attackColor: UIColor  = UIColor(red: 0.767, green: 0.000, blue: 0.000, alpha: 1.000)
    @IBInspectable public var decayColor: UIColor   = UIColor(red: 0.942, green: 0.648, blue: 0.000, alpha: 1.000)
    @IBInspectable public var sustainColor: UIColor = UIColor(red: 0.320, green: 0.800, blue: 0.616, alpha: 1.000)
    @IBInspectable public var releaseColor: UIColor = UIColor(red: 0.720, green: 0.519, blue: 0.888, alpha: 1.000)
    let bgColor = UIColor(red: 1.000, green: 1.000, blue: 1.000, alpha: 1.000)
    
    @IBInspectable public var curveStrokeWidth: CGFloat = 1 //min(max(1, size.height / 50.0), max(1, size.width / 100.0))


    var lastPoint = CGPoint.zero

    override public func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        if let touch = touches.first {
            let touchLocation = touch.locationInView(self)

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
        }
        setNeedsDisplay()
    }

    override public func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?) {
        if let touch = touches.first {
            let touchLocation = touch.locationInView(self)

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
            if attackTime < 0 { attackTime = 0 }
            if decayTime < 0 { decayTime = 0 }
            if releaseTime < 0 { releaseTime = 0 }
            if sustainPercent < 0 { sustainPercent = 0 }
            if sustainPercent > 100 { sustainPercent = 100 }

            if let realCallback = self.callback {
                realCallback(Double(attackTime / 1000.0),
                             Double(decayTime / 1000.0),
                             Double(sustainPercent / 100.0),
                             Double(releaseTime / 1000.0))
            }
            lastPoint = touchLocation
        }
        setNeedsDisplay()
    }
    
    override public func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()
        
        // make sure we are filling the circle and masking by default
        contentMode = .ScaleAspectFill
        clipsToBounds = true
    }
    
    override public func intrinsicContentSize() -> CGSize {
        return CGSize(width: 440, height: 150)
    }

    public class override func requiresConstraintBasedLayout() -> Bool {
        return true
    }
        
    func setupViews() {
        // set default values
        layer.borderColor = UIColor.lightGrayColor().CGColor
        layer.borderWidth = 1.0
        layer.masksToBounds = true
        
        contentMode = .ScaleAspectFill
        clipsToBounds = true
        
        // make sure we are attempting to keep a 1:1 aspect ratio
        translatesAutoresizingMaskIntoConstraints = false
        widthAnchor.constraintEqualToAnchor(heightAnchor, multiplier: 1.0).active = true
        
//        drawCurveCanvas(attackDurationMS: CGFloat(attackDuration * 1000),
//                        decayDurationMS: CGFloat(decayDuration * 1000),
//                        releaseDurationMS: CGFloat(releaseDuration * 500),
//                        sustainLevel: CGFloat(1.0 - sustainLevel))
    }

    public init(callback: ADSRCallback? = nil) {
        self.callback = callback
        super.init(frame: CGRect(x: 0, y: 0, width: 440, height: 150))
        backgroundColor = UIColor.whiteColor()
    }

    override public init(frame: CGRect) {
        super.init(frame: frame)
    }

    required public init?(coder aDecoder: NSCoder) {
        print("init from coder")
        super.init(coder: aDecoder)
//        setupViews()
    }

    func drawCurveCanvas(size size: CGSize = CGSize(width: 440, height: 151), attackDurationMS: CGFloat = 449, decayDurationMS: CGFloat = 262, releaseDurationMS: CGFloat = 448, sustainLevel: CGFloat = 0.583, maxADFraction: CGFloat = 0.75) {
        //// General Declarations
        let context = UIGraphicsGetCurrentContext()

        //// Variable Declarations
        let attackClickRoom = CGFloat(30) // to allow the attack to be clicked even if is zero
        let oneSecond: CGFloat = 0.65 * size.width
        let initialPoint = CGPoint(x: attackClickRoom, y: size.height)
        let buffer = CGFloat(10)//curveStrokeWidth / 2.0 // make a little room for drwing the stroke
        let endAxes = CGPoint(x: size.width, y: size.height)
        let releasePoint = CGPoint(x: attackClickRoom + oneSecond, y: sustainLevel * (size.height - buffer) + buffer)
        let endPoint = CGPoint(x: releasePoint.x + releaseDurationMS / 1000.0 * oneSecond, y: size.height)
        let endMax = CGPoint(x: min(endPoint.x, size.width), y: buffer)
        let releaseAxis = CGPoint(x: releasePoint.x, y: endPoint.y)
        let releaseMax = CGPoint(x: releasePoint.x, y: buffer)
        let highPoint  = CGPoint(x: attackClickRoom + min(oneSecond * maxADFraction, attackDurationMS / 1000.0 * oneSecond), y: buffer)
        let highPointAxis = CGPoint(x: highPoint.x, y: size.height)
        let highMax = CGPoint(x: highPoint.x, y: buffer)
        let minthing = min(oneSecond * maxADFraction, (attackDurationMS + decayDurationMS) / 1000.0 * oneSecond)
        let sustainPoint = CGPoint(x: max(highPoint.x, attackClickRoom + minthing),
                                   y: sustainLevel * (size.height - buffer) + buffer)
        let sustainAxis = CGPoint(x: sustainPoint.x, y: size.height)
        let initialMax = CGPoint(x: 0, y: buffer)


        let initialToHighControlPoint = CGPoint(x: initialPoint.x, y: highPoint.y)
        let highToSustainControlPoint = CGPoint(x: highPoint.x, y: sustainPoint.y)
        let releaseToEndControlPoint  = CGPoint(x: releasePoint.x, y: endPoint.y)


        //// attackTouchArea Drawing
        CGContextSaveGState(context)

        attackTouchAreaPath = UIBezierPath()
        attackTouchAreaPath.moveToPoint(CGPoint(x: 0, y: size.height))
        attackTouchAreaPath.addLineToPoint(highPointAxis)
        attackTouchAreaPath.addLineToPoint(highMax)
        attackTouchAreaPath.addLineToPoint(initialMax)
        attackTouchAreaPath.addLineToPoint(CGPoint(x: 0, y: size.height))
        attackTouchAreaPath.closePath()
        bgColor.setFill()
        attackTouchAreaPath.fill()

        CGContextRestoreGState(context)

        //// decaySustainTouchArea Drawing
        CGContextSaveGState(context)

        decaySustainTouchAreaPath = UIBezierPath()
        decaySustainTouchAreaPath.moveToPoint(highPointAxis)
        decaySustainTouchAreaPath.addLineToPoint(releaseAxis)
        decaySustainTouchAreaPath.addLineToPoint(releaseMax)
        decaySustainTouchAreaPath.addLineToPoint(highMax)
        decaySustainTouchAreaPath.addLineToPoint(highPointAxis)
        decaySustainTouchAreaPath.closePath()
        bgColor.setFill()
        decaySustainTouchAreaPath.fill()

        CGContextRestoreGState(context)


        //// releaseTouchArea Drawing
        CGContextSaveGState(context)

        releaseTouchAreaPath = UIBezierPath()
        releaseTouchAreaPath.moveToPoint(releaseAxis)
        releaseTouchAreaPath.addLineToPoint(endAxes)
        releaseTouchAreaPath.addLineToPoint(endMax)
        releaseTouchAreaPath.addLineToPoint(releaseMax)
        releaseTouchAreaPath.addLineToPoint(releaseAxis)
        releaseTouchAreaPath.closePath()
        bgColor.setFill()
        releaseTouchAreaPath.fill()

        CGContextRestoreGState(context)


        //// releaseArea Drawing
        CGContextSaveGState(context)

        let releaseAreaPath = UIBezierPath()
        releaseAreaPath.moveToPoint(releaseAxis)
        releaseAreaPath.addCurveToPoint(endPoint,
                                        controlPoint1: releaseAxis,
                                        controlPoint2: endPoint)
        releaseAreaPath.addCurveToPoint(releasePoint,
                                        controlPoint1: releaseToEndControlPoint,
                                        controlPoint2: releasePoint)
        releaseAreaPath.addLineToPoint(releaseAxis)
        releaseAreaPath.closePath()
        releaseColor.setFill()
        releaseAreaPath.fill()

        CGContextRestoreGState(context)


        //// sustainArea Drawing
        CGContextSaveGState(context)

        let sustainAreaPath = UIBezierPath()
        sustainAreaPath.moveToPoint(sustainAxis)
        sustainAreaPath.addLineToPoint(releaseAxis)
        sustainAreaPath.addLineToPoint(releasePoint)
        sustainAreaPath.addLineToPoint(sustainPoint)
        sustainAreaPath.addLineToPoint(sustainAxis)
        sustainAreaPath.closePath()
        sustainColor.setFill()
        sustainAreaPath.fill()

        CGContextRestoreGState(context)


        //// decayArea Drawing
        CGContextSaveGState(context)

        let decayAreaPath = UIBezierPath()
        decayAreaPath.moveToPoint(highPointAxis)
        decayAreaPath.addLineToPoint(sustainAxis)
        decayAreaPath.addCurveToPoint(sustainPoint,
                                      controlPoint1: sustainAxis,
                                      controlPoint2: sustainPoint)
        decayAreaPath.addCurveToPoint(highPoint,
                                      controlPoint1: highToSustainControlPoint,
                                      controlPoint2: highPoint)
        decayAreaPath.addLineToPoint(highPoint)
        decayAreaPath.closePath()
        decayColor.setFill()
        decayAreaPath.fill()

        CGContextRestoreGState(context)


        //// attackArea Drawing
        CGContextSaveGState(context)

        let attackAreaPath = UIBezierPath()
        attackAreaPath.moveToPoint(initialPoint)
        attackAreaPath.addLineToPoint(highPointAxis)
        attackAreaPath.addLineToPoint(highPoint)
        attackAreaPath.addCurveToPoint(initialPoint,
                                       controlPoint1: initialToHighControlPoint,
                                       controlPoint2: initialPoint)
        attackAreaPath.closePath()
        attackColor.setFill()
        attackAreaPath.fill()

        CGContextRestoreGState(context)

        //// Curve Drawing
        CGContextSaveGState(context)

        let curvePath = UIBezierPath()
        curvePath.moveToPoint(initialPoint)
        curvePath.addCurveToPoint(highPoint,
                                  controlPoint1: initialPoint,
                                  controlPoint2: initialToHighControlPoint)
        curvePath.addCurveToPoint(sustainPoint,
                                  controlPoint1: highPoint,
                                  controlPoint2: highToSustainControlPoint)
        curvePath.addLineToPoint(releasePoint)
        curvePath.addCurveToPoint(endPoint,
                                  controlPoint1: releasePoint,
                                  controlPoint2: releaseToEndControlPoint)
        UIColor.blackColor().setStroke()
        curvePath.lineWidth = curveStrokeWidth
        curvePath.stroke()

        CGContextRestoreGState(context)
    }



    override public func drawRect(rect: CGRect) {
        drawCurveCanvas(size: rect.size, attackDurationMS: attackTime,
                        decayDurationMS: decayTime,
                        releaseDurationMS: releaseTime,
                        sustainLevel: 1.0 - sustainPercent / 100.0)
    }
}
