//
//  AKPresetLoaderView.swift
//  AudioKit for iOS
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright © 2018 AudioKit. All rights reserved.
//

/// Preset view scroller
@IBDesignable open class AKPresetLoaderView: UIView {
    // Default corner radius
    static var standardCornerRadius: CGFloat = 3.0

    var presetOuterPath = UIBezierPath()
    var upOuterPath = UIBezierPath()
    var downOuterPath = UIBezierPath()
    var turboScrollPath = UIBezierPath()

    var currentIndex = 0

    /// Text to display as a label
    @IBInspectable open var label: String = "Preset"

    /// The presets to scroll through
    open var presets = [String]()

    /// Function to call when the preset is changed
    open var callback: (String) -> Void
    var isPresetLoaded = false

    /// Font size
    @IBInspectable open var fontSize: CGFloat = 24

    /// Font
    open var font: UIFont = UIFont.boldSystemFont(ofSize: 24)

    open var bgColor: AKColor? {
        didSet {
            setNeedsDisplay()
        }
    }

    open var textColor: AKColor? {
        didSet {
            setNeedsDisplay()
        }
    }

    open var borderColor: AKColor? {
        didSet {
            setNeedsDisplay()
        }
    }

    @IBInspectable open var borderWidth: CGFloat = 3.0 {
        didSet {
            setNeedsDisplay()
        }
    }

    /// Initialize the preset loader view
    @objc public init(presets: [String],
                      frame: CGRect = CGRect(x: 0, y: 0, width: 440, height: 60),
                      font: UIFont = UIFont.boldSystemFont(ofSize: 24),
                      fontSize: CGFloat = 24,
                      initialIndex: Int = 0,
                      callback: @escaping (String) -> Void) {
        self.callback = callback
        self.presets = presets
        self.font = font
        self.fontSize = fontSize
        super.init(frame: frame)

        self.backgroundColor = UIColor.clear

        if self.presets.isNotEmpty && initialIndex < self.presets.count {
            isPresetLoaded = true
            self.currentIndex = initialIndex
            setNeedsDisplay()
        }
    }

    /// Initialization with no details
    public override init(frame: CGRect) {
        self.callback = { filename in return }
        self.presets = ["Preset One", "Preset Two", "Preset Three"]

        super.init(frame: frame)

        self.backgroundColor = UIColor.clear
        contentMode = .redraw
    }

    /// Initialize in Interface Builder
    public required init?(coder aDecoder: NSCoder) {
        self.callback = { filename in return }
        self.presets = ["Preset One", "Preset Two", "Preset Three"]

        super.init(coder: aDecoder)

        self.backgroundColor = UIColor.clear
        contentMode = .redraw
    }

    // Default background color per theme
    var bgColorForTheme: AKColor {
        if let bgColor = bgColor {
            return bgColor

        }

        switch AKStylist.sharedInstance.theme {
        case .basic:
            return AKColor(white: 0.8, alpha: 1.0)
        case .midnight:
            return AKColor(white: 0.7, alpha: 1.0)
        }
    }

    // Default border color per theme
    var borderColorForTheme: AKColor {
        if let borderColor = borderColor {
            return borderColor
        }

        switch AKStylist.sharedInstance.theme {
        case .basic:
            return AKColor(white: 0.3, alpha: 1.0).withAlphaComponent(0.8)
        case .midnight:
            return AKColor.white.withAlphaComponent(0.8)
        }
    }

    // Default text color per theme
    var textColorForTheme: AKColor {
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

    func drawPresetLoader(presetName: String = "None", isPresetLoaded: Bool = false) {
        //// General Declarations
        let rect = self.bounds
        let cornerRadius: CGFloat = AKPresetLoaderView.standardCornerRadius

        //// Color Declarations
        let green = AKStylist.sharedInstance.colorForTrueValue
        let red = AKStylist.sharedInstance.colorForFalseValue
        let gray = bgColorForTheme

        //// Variable Declarations
        let expression: AKColor = isPresetLoaded ? green : red

        //// background Drawing
        let backgroundPath = UIBezierPath(rect: CGRect(x: borderWidth,
                                                       y: borderWidth,
                                                       width: rect.width - borderWidth * 2.0,
                                                       height: rect.height - borderWidth * 2.0))
        gray.setFill()
        backgroundPath.fill()

        //// presetButton
        //// presetOuter Drawing
        presetOuterPath = UIBezierPath(rect: CGRect(x: borderWidth,
                                                    y: borderWidth,
                                                    width: rect.width * 0.25,
                                                    height: rect.height - borderWidth * 2.0))
        expression.setFill()
        presetOuterPath.fill()

        // presetButton border Path
        let presetButtonBorderPath = UIBezierPath()
        presetButtonBorderPath.move(to: CGPoint(x: rect.width * 0.25 + borderWidth, y: borderWidth))
        presetButtonBorderPath.addLine(to: CGPoint(x: rect.width * 0.25 + borderWidth, y: rect.height - borderWidth))
        borderColorForTheme.setStroke()
        presetButtonBorderPath.lineWidth = borderWidth / 2.0
        presetButtonBorderPath.stroke()

        //// presetLabel Drawing
        let presetLabelRect = CGRect(x: 0, y: 0, width: rect.width * 0.25, height: rect.height)
        let presetLabelTextContent = NSString(string: label)
        let presetLabelStyle = NSMutableParagraphStyle()
        presetLabelStyle.alignment = .center

        let presetLabelFontAttributes = [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 24),
                                         NSAttributedString.Key.foregroundColor: textColorForTheme,
                                         NSAttributedString.Key.paragraphStyle: presetLabelStyle]

        let presetLabelInset: CGRect = presetLabelRect.insetBy(dx: 10, dy: 0)
        let presetLabelTextHeight: CGFloat = presetLabelTextContent.boundingRect(
            with: CGSize(width: presetLabelInset.width, height: CGFloat.infinity),
            options: NSStringDrawingOptions.usesLineFragmentOrigin,
            attributes: presetLabelFontAttributes, context: nil).size.height
        let presetLabelTextRect: CGRect = CGRect(
            x: presetLabelInset.minX,
            y: presetLabelInset.minY + (presetLabelInset.height - presetLabelTextHeight) / 2,
            width: presetLabelInset.width,
            height: presetLabelTextHeight)
        presetLabelTextContent.draw(in: presetLabelTextRect.offsetBy(dx: 0, dy: 0),
                                    withAttributes: presetLabelFontAttributes)

        //// upButton
        //// upOuter Drawing
        downOuterPath = UIBezierPath(rect: CGRect(x: rect.width * 0.9,
                                                  y: rect.height * 0.5,
                                                  width: rect.width * 0.07,
                                                  height: rect.height * 0.5))

        //// upInner Drawing
        let downArrowRect = CGRect(x: rect.width * 0.9,
                                   y: rect.height * 0.58,
                                   width: rect.width * 0.07,
                                   height: rect.height * 0.3)
        let downInnerPath = UIBezierPath()
        downInnerPath.move(to: CGPoint(x: downArrowRect.minX + cornerRadius / 2.0,
                                       y: downArrowRect.minY))
        downInnerPath.addLine(to: CGPoint(x: downArrowRect.maxX - cornerRadius / 2.0,
                                          y: downArrowRect.minY))
        downInnerPath.addCurve(to: CGPoint(x: downArrowRect.maxX - cornerRadius / 2.0,
                                           y: downArrowRect.minY + cornerRadius / 2.0),
                               controlPoint1: CGPoint(x: downArrowRect.maxX,
                                                      y: downArrowRect.minY),
                               controlPoint2: CGPoint(x: downArrowRect.maxX,
                                                      y: downArrowRect.minY))
        downInnerPath.addLine(to: CGPoint(x: downArrowRect.midX + cornerRadius / 2.0,
                                          y: downArrowRect.maxY - cornerRadius / 2.0))
        downInnerPath.addCurve(to: CGPoint(x: downArrowRect.midX - cornerRadius / 2.0,
                                           y: downArrowRect.maxY - cornerRadius / 2.0),
                               controlPoint1: CGPoint(x: downArrowRect.midX,
                                                      y: downArrowRect.maxY),
                               controlPoint2: CGPoint(x: downArrowRect.midX,
                                                      y: downArrowRect.maxY))
        downInnerPath.addLine(to: CGPoint(x: downArrowRect.minX + cornerRadius / 2.0,
                                          y: downArrowRect.minY + cornerRadius / 2.0))
        downInnerPath.addCurve(to: CGPoint(x: downArrowRect.minX + cornerRadius / 2.0,
                                           y: downArrowRect.minY),
                               controlPoint1: CGPoint(x: downArrowRect.minX,
                                                      y: downArrowRect.minY),
                               controlPoint2: CGPoint(x: downArrowRect.minX,
                                                      y: downArrowRect.minY))
        textColorForTheme.setStroke()
        downInnerPath.lineWidth = borderWidth
        downInnerPath.stroke()

        upOuterPath = UIBezierPath(rect: CGRect(x: rect.width * 0.9,
                                                y: 0,
                                                width: rect.width * 0.07,
                                                height: rect.height * 0.5))

        //// downInner Drawing
        let upArrowRect = CGRect(x: rect.width * 0.9,
                                 y: rect.height * 0.12,
                                 width: rect.width * 0.07,
                                 height: rect.height * 0.3)
        let upInnerPath = UIBezierPath()
        upInnerPath.move(to: CGPoint(x: upArrowRect.minX + cornerRadius / 2.0,
                                     y: upArrowRect.maxY))
        upInnerPath.addLine(to: CGPoint(x: upArrowRect.maxX - cornerRadius / 2.0,
                                        y: upArrowRect.maxY))
        upInnerPath.addCurve(to: CGPoint(x: upArrowRect.maxX - cornerRadius / 2.0,
                                         y: upArrowRect.maxY - cornerRadius / 2.0),
                             controlPoint1: CGPoint(x: upArrowRect.maxX,
                                                    y: upArrowRect.maxY),
                             controlPoint2: CGPoint(x: upArrowRect.maxX,
                                                    y: upArrowRect.maxY))
        upInnerPath.addLine(to: CGPoint(x: upArrowRect.midX + cornerRadius / 2.0,
                                        y: upArrowRect.minY + cornerRadius / 2.0))
        upInnerPath.addCurve(to: CGPoint(x: upArrowRect.midX - cornerRadius / 2.0,
                                         y: upArrowRect.minY + cornerRadius / 2.0),
                             controlPoint1: CGPoint(x: upArrowRect.midX,
                                                    y: upArrowRect.minY),
                             controlPoint2: CGPoint(x: upArrowRect.midX,
                                                    y: upArrowRect.minY))
        upInnerPath.addLine(to: CGPoint(x: upArrowRect.minX + cornerRadius / 2.0,
                                        y: upArrowRect.maxY - cornerRadius / 2.0))
        upInnerPath.addCurve(to: CGPoint(x: upArrowRect.minX + cornerRadius / 2.0,
                                         y: upArrowRect.maxY),
                             controlPoint1: CGPoint(x: upArrowRect.minX,
                                                    y: upArrowRect.maxY),
                             controlPoint2: CGPoint(x: upArrowRect.minX,
                                                    y: upArrowRect.maxY))
        textColorForTheme.setStroke()
        upInnerPath.lineWidth = borderWidth
        upInnerPath.stroke()

        //// nameLabel Drawing
        let nameLabelRect = CGRect(x: rect.width * 0.25, y: 0, width: rect.width * 0.75, height: rect.height)
        let nameLabelStyle = NSMutableParagraphStyle()
        nameLabelStyle.alignment = .left

        let nameLabelFontAttributes = [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 24),
                                       NSAttributedString.Key.foregroundColor: textColorForTheme,
                                       NSAttributedString.Key.paragraphStyle: nameLabelStyle]

        let nameLabelInset: CGRect = nameLabelRect.insetBy(dx: rect.width * 0.04, dy: 0)
        let nameLabelTextHeight: CGFloat = NSString(string: presetName).boundingRect(
            with: CGSize(width: nameLabelInset.width, height: CGFloat.infinity),
            options: NSStringDrawingOptions.usesLineFragmentOrigin,
            attributes: nameLabelFontAttributes, context: nil).size.height
        let nameLabelTextRect: CGRect = CGRect(
            x: nameLabelInset.minX,
            y: nameLabelInset.minY + (nameLabelInset.height - nameLabelTextHeight) / 2,
            width: nameLabelInset.width,
            height: nameLabelTextHeight)
        NSString(string: presetName).draw(in: nameLabelTextRect.offsetBy(dx: 0, dy: 0),
                                          withAttributes: nameLabelFontAttributes)

        let outerRect = CGRect(x: rect.origin.x + borderWidth / 2.0,
                               y: rect.origin.y + borderWidth / 2.0,
                               width: rect.width - borderWidth,
                               height: rect.height - borderWidth)
        let outerPath = UIBezierPath(roundedRect: outerRect,
                                     byRoundingCorners: UIRectCorner.allCorners,
                                     cornerRadii: CGSize(width: cornerRadius, height: cornerRadius))
        borderColorForTheme.setStroke()
        outerPath.lineWidth = borderWidth
        outerPath.stroke()
    }

    open override func draw(_ rect: CGRect) {
        let presetName = isPresetLoaded ? presets[currentIndex] : "None"
        drawPresetLoader(presetName: presetName, isPresetLoaded: isPresetLoaded)
    }

    /// Handle new touches
    open override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {

        if presets.isEmpty {
            return
        }
        if let touch = touches.first {
            isPresetLoaded = false

            // preset buttons
            let touchLocation = touch.location(in: self)
            if upOuterPath.contains(touchLocation) {
                currentIndex -= 1
                isPresetLoaded = true
            }
            if downOuterPath.contains(touchLocation) {
                currentIndex += 1
                isPresetLoaded = true
            }

            // clamp
            if currentIndex < 0 { currentIndex = presets.count - 1 }
            if currentIndex >= presets.count { currentIndex = 0 }

            // preset callback
            if isPresetLoaded {
                callback(presets[currentIndex])
                setNeedsDisplay()
            }
        }
    }

    /// Handle moved touches
    open override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        if presets.isEmpty {
            return
        }

        if let touch = touches.first {
            // turbo scroll
            let touchLocation = touch.location(in: self)
            if turboScrollPath.contains(touchLocation) {
                let previousTouchLocation = touch.previousLocation(in: self)
                let delta = previousTouchLocation.x - touchLocation.x
                let iDelta = Int(delta)
                if iDelta != 0 {
                    currentIndex += iDelta
                    isPresetLoaded = true
                }
            }

            // clamp
            if currentIndex < 0 { currentIndex = presets.count - 1 }
            if currentIndex >= presets.count { currentIndex = 0 }

            // preset callback
            if isPresetLoaded {
                callback(presets[currentIndex])
                setNeedsDisplay()
            }
        }
    }
}
