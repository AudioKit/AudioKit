//
//  AKStepper.swift
//  AudioKit for iOS
//
//  Created by Aurelius Prochazka on 3/11/17.
//  Copyright © 2017 Aurelius Prochazka. All rights reserved.
//

/// Incrementor view, normally used for MIDI presets, but could be useful elsehwere
open class AKStepper: UIView {

    var plusPath = UIBezierPath()
    var minusPath = UIBezierPath()

    /// Text / label to display
    open var text = "Value"

    /// Current value
    open var value: MIDIByte

    /// Function to call on change
    open var callback: (MIDIByte) -> Void

    /// Handle new touches
    override open func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first {            let touchLocation = touch.location(in: self)
            if minusPath.contains(touchLocation) {
                if value > 1 {
                    value -= 1
                }
            }
            if plusPath.contains(touchLocation) {
                if value < 127 {
                    value += 1
                }
            }
            self.callback(value)
            setNeedsDisplay()
        }
    }

    /// Initialize the stepper view
    public init(text: String,
                value: MIDIByte,
                frame: CGRect = CGRect(x: 0, y: 0, width: 440, height: 60),
                callback: @escaping (MIDIByte) -> Void) {
        self.callback = callback
        self.value = value
        self.text = text
        super.init(frame: frame)
    }

    /// Initialize within Interface Builder
    required public init?(coder aDecoder: NSCoder) {
        self.callback = { filename in return }
        self.value = 0
        self.text = "Value"
        super.init(coder: aDecoder)
    }

    /// Draw the stepper
    override open func draw(_ rect: CGRect) {
        //// General Declarations
        let context = UIGraphicsGetCurrentContext()!

        //// Color Declarations
        let red = UIColor(red: 1.000, green: 0.150, blue: 0.061, alpha: 1.000)
        let gray = UIColor(red: 0.866, green: 0.872, blue: 0.867, alpha: 0.925)
        let green = UIColor(red: 0.000, green: 0.977, blue: 0.000, alpha: 1.000)

        //// background Drawing
        let backgroundPath = UIBezierPath(rect: CGRect(x: 0, y: 0, width: 440, height: 60))
        gray.setFill()
        backgroundPath.fill()

        //// textLabel Drawing
        let textLabelRect = CGRect(x: 68, y: 0, width: 304, height: 60)
        let textLabelStyle = NSMutableParagraphStyle()
        textLabelStyle.alignment = .left
        let textLabelFontAttributes = [NSFontAttributeName: UIFont.boldSystemFont(ofSize: 24),
                                       NSForegroundColorAttributeName: UIColor.black,
                                       NSParagraphStyleAttributeName: textLabelStyle]

        let textLabelInset: CGRect = textLabelRect.insetBy(dx: 10, dy: 0)
        let textLabelTextHeight: CGFloat = text.boundingRect(with: CGSize(width: textLabelInset.width,
                                                                          height: CGFloat.infinity),
                                                             options: .usesLineFragmentOrigin,
                                                             attributes: textLabelFontAttributes,
                                                             context: nil).height
        context.saveGState()
        context.clip(to: textLabelInset)
        let newText = "\(text): \(value)"
        newText.draw(in: CGRect(x: textLabelInset.minX,
                                y: textLabelInset.minY + (textLabelInset.height - textLabelTextHeight) / 2,
                                width: textLabelInset.width,
                                height: textLabelTextHeight),
                     withAttributes: textLabelFontAttributes)
        context.restoreGState()

        //// minusGroup
        //// minusRectangle Drawing
        let minusRectanglePath = UIBezierPath(roundedRect: CGRect(x: 4, y: 5, width: 60, height: 50), cornerRadius: 16)
        red.setFill()
        minusRectanglePath.fill()
        UIColor.black.setStroke()
        minusRectanglePath.lineWidth = 2
        minusRectanglePath.stroke()

        //// minus Drawing
        minusPath = UIBezierPath(rect: CGRect(x: 19, y: 25, width: 31, height: 10))
        UIColor.black.setFill()
        minusPath.fill()

        //// plusGroup
        //// plusRectangle Drawing
        let plusRectanglePath = UIBezierPath(roundedRect: CGRect(x: 376, y: 5, width: 60, height: 50), cornerRadius: 16)
        green.setFill()
        plusRectanglePath.fill()
        UIColor.black.setStroke()
        plusRectanglePath.lineWidth = 2
        plusRectanglePath.stroke()

        //// plus Drawing
        plusPath = UIBezierPath()
        plusPath.move(to: CGPoint(x: 411, y: 15))
        plusPath.addCurve(to: CGPoint(x: 411, y: 25),
                          controlPoint1: CGPoint(x: 411, y: 15),
                          controlPoint2: CGPoint(x: 411, y: 19.49))
        plusPath.addLine(to: CGPoint(x: 421, y: 25))
        plusPath.addLine(to: CGPoint(x: 421, y: 35))
        plusPath.addLine(to: CGPoint(x: 411, y: 35))
        plusPath.addCurve(to: CGPoint(x: 411, y: 45),
                          controlPoint1: CGPoint(x: 411, y: 40.51),
                          controlPoint2: CGPoint(x: 411, y: 45))
        plusPath.addLine(to: CGPoint(x: 401, y: 45))
        plusPath.addCurve(to: CGPoint(x: 401, y: 35),
                          controlPoint1: CGPoint(x: 401, y: 45),
                          controlPoint2: CGPoint(x: 401, y: 40.51))
        plusPath.addLine(to: CGPoint(x: 391, y: 35))
        plusPath.addLine(to: CGPoint(x: 391, y: 25))
        plusPath.addLine(to: CGPoint(x: 401, y: 25))
        plusPath.addCurve(to: CGPoint(x: 401, y: 15),
                          controlPoint1: CGPoint(x: 401, y: 19.49),
                          controlPoint2: CGPoint(x: 401, y: 15))
        plusPath.addLine(to: CGPoint(x: 411, y: 15))
        plusPath.addLine(to: CGPoint(x: 411, y: 15))
        plusPath.close()
        UIColor.black.setFill()
        plusPath.fill()
    }

}
