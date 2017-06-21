//
//  AKPresetLoaderView.swift
//  AudioKit for iOS
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright © 2017 Aurelius Prochazka. All rights reserved.
//

/// Preset view scoller
open class AKPresetLoaderView: UIView {

    var presetOuterPath = UIBezierPath()
    var upOuterPath = UIBezierPath()
    var downOuterPath = UIBezierPath()
    var turboScrollPath = UIBezierPath()

    var currentIndex = 0

    /// Text to display as a label
    open var label = "Preset"

    /// The presets to scroll through
    open var presets = [String]()

    /// Function to call when the preset is changed
    open var callback: (String) -> Void
    var isPresetLoaded = false

    /// Font size
    @IBInspectable open var fontSize: CGFloat = 24

    /// Font
    @IBInspectable open var font: UIFont = UIFont.boldSystemFont(ofSize: 24)

    /// Initialize the preset loader view
    public init(presets: [String],
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
        if !self.presets.isEmpty && initialIndex < self.presets.count {
            isPresetLoaded = true
            self.currentIndex = initialIndex
            setNeedsDisplay()
        }
    }

    /// Initialize in Interface Builder
    required public init?(coder aDecoder: NSCoder) {
        self.callback = {filename in return}
        self.presets = []
        super.init(coder: aDecoder)
    }

    func drawPresetLoader(presetName: String = "None", isPresetLoaded: Bool = false) {
        //// General Declarations
        let context = UIGraphicsGetCurrentContext()

        //// Color Declarations
        let red = #colorLiteral(red: 1.000, green: 0.000, blue: 0.062, alpha: 1.000)
        let gray = #colorLiteral(red: 0.835, green: 0.842, blue: 0.836, alpha: 0.925)
        let darkgray = #colorLiteral(red: 0.735, green: 0.742, blue: 0.736, alpha: 0.5)
        let green = #colorLiteral(red: 0.029, green: 1, blue: 0, alpha: 0.4921599912)
        let dark = #colorLiteral(red: 0.000, green: 0.000, blue: 0.000, alpha: 1.000)

        //// Variable Declarations
        let expression = isPresetLoaded ? green : red

        // Layout
        let hitpointWidth: CGFloat = 60
        let hitpointHeight: CGFloat = 60
        let hitpointHeight2: CGFloat = 0.5 * self.bounds.size.height
        let presetLabelWidth: CGFloat = 95 - 30 - 30 + 10

        // turboScroll area for touches
        turboScrollPath = UIBezierPath(rect: CGRect(x: 0, y: 0, width: self.bounds.size.width - hitpointWidth, height: self.bounds.size.height))

        //// background Drawing
        let backgroundPath = UIBezierPath(rect: CGRect(x: 0, y: 0, width: self.bounds.size.width, height: self.bounds.size.height))
        darkgray.setFill()
        backgroundPath.fill()

        //// presetButton
        //// presetOuter Drawing
        presetOuterPath = UIBezierPath(rect: CGRect(x: 0, y: 0, width: presetLabelWidth, height: self.bounds.size.height))
        expression.setFill()
        presetOuterPath.fill()

        // Font
        let finalFontName = font.fontName
        let finalFont = UIFont(name: finalFontName, size: fontSize) as Any

        //// presetLabel Drawing
        let presetLabelRect = CGRect(x: 0, y: 0, width: presetLabelWidth, height: self.bounds.size.height)
        let presetLabelTextContent = NSString(string: label)
        let presetLabelStyle = NSMutableParagraphStyle()
        presetLabelStyle.alignment = .left
        let presetLabelFontAttributes = [NSFontAttributeName: finalFont,
                                         NSForegroundColorAttributeName: UIColor.black,
                                         NSParagraphStyleAttributeName: presetLabelStyle]

        let presetLabelInset: CGRect = presetLabelRect.insetBy(dx: 10 - 10, dy: 0)
        let presetLabelTextHeight: CGFloat = presetLabelTextContent.boundingRect(
            with: CGSize(width: presetLabelInset.width, height: CGFloat.infinity),
            options: NSStringDrawingOptions.usesLineFragmentOrigin,
            attributes: presetLabelFontAttributes,
            context: nil).size.height
        context?.saveGState()
        context?.clip(to: presetLabelInset)
        presetLabelTextContent.draw(in: CGRect(x: presetLabelInset.minX,
                                               y: presetLabelInset.minY +
                                                (presetLabelInset.height - presetLabelTextHeight) / 2,
                                               width: presetLabelInset.width,
                                               height: presetLabelTextHeight),
                                    withAttributes: presetLabelFontAttributes)
        context?.restoreGState()

        //// upButton
        //// upOuter Drawing
        let originX: CGFloat = 380 - 30 + 15 + 5
        let buttonX: CGFloat = self.bounds.size.width - hitpointWidth
        upOuterPath = UIBezierPath(rect: CGRect(x: Int(buttonX + 381 - originX), y: 0, width: Int(hitpointWidth), height: Int(hitpointHeight2)))
        gray.setFill()
        upOuterPath.fill()

        //// upInner Drawing
        let upInnerPath = UIBezierPath()
        upInnerPath.move(to: CGPoint(x: Int(buttonX + 395.75 - originX), y: Int(2 * hitpointHeight2 * 22.5 / hitpointHeight)))
        upInnerPath.addLine(to: CGPoint(x: Int(buttonX + 425.25 - originX), y: Int(2 * hitpointHeight2 * 22.5 / hitpointHeight)))
        upInnerPath.addLine(to: CGPoint(x: Int(buttonX + 410.5 - originX), y: Int(2 * hitpointHeight2 * 7.5 / hitpointHeight)))
        upInnerPath.addLine(to: CGPoint(x: Int(buttonX + 410.5 - originX), y: Int(2 * hitpointHeight2 * 7.5 / hitpointHeight)))
        upInnerPath.addLine(to: CGPoint(x: Int(buttonX + 395.75 - originX), y: Int(2 * hitpointHeight2 * 22.5 / hitpointHeight)))
        upInnerPath.close()
        dark.setFill()
        upInnerPath.fill()

        //// downButton
        //// downOuter Drawing
        downOuterPath = UIBezierPath(rect: CGRect(x: Int(buttonX + 381 - originX), y: Int(hitpointHeight2), width: Int(hitpointWidth), height: Int(hitpointHeight2)))
        gray.setFill()
        downOuterPath.fill()

        //// downInner Drawing
        let downInnerPath = UIBezierPath()
        downInnerPath.move(to: CGPoint(x: Int(buttonX + 410.5 - originX), y: Int(2 * hitpointHeight2 * 52.5 / hitpointHeight)))
        downInnerPath.addLine(to: CGPoint(x: Int(buttonX + 410.5 - originX), y: Int(2 * hitpointHeight2 * 52.5 / hitpointHeight)))
        downInnerPath.addLine(to: CGPoint(x: Int(buttonX + 425.25 - originX), y: Int(2 * hitpointHeight2 * 37.5 / hitpointHeight)))
        downInnerPath.addLine(to: CGPoint(x: Int(buttonX + 395.75 - originX), y: Int(2 * hitpointHeight2 * 37.5 / hitpointHeight)))
        downInnerPath.addLine(to: CGPoint(x: Int(buttonX + 410.5 - originX), y: Int(2 * hitpointHeight2 * 52.5 / hitpointHeight)))
        downInnerPath.close()
        dark.setFill()
        downInnerPath.fill()

        //// nameLabel Drawing
        // Font with fontName and fontSize
        let nameLabelRect = CGRect(x: presetLabelWidth, y: 0, width: self.bounds.size.width - presetLabelWidth, height: hitpointHeight)
        let nameLabelStyle = NSMutableParagraphStyle()
        nameLabelStyle.alignment = .left
        let nameLabelFontAttributes = [NSFontAttributeName: finalFont,
                                       NSForegroundColorAttributeName: UIColor.black,
                                       NSParagraphStyleAttributeName: nameLabelStyle] as [String : Any]
        let nameLabelInset: CGRect = nameLabelRect.insetBy(dx: 10 - 10, dy: 0)
        let nameLabelTextHeight: CGFloat = NSString(string: presetName).boundingRect(
            with: CGSize(width: nameLabelInset.width,
                         height: CGFloat.infinity),
            options: NSStringDrawingOptions.usesLineFragmentOrigin,
            attributes: nameLabelFontAttributes,
            context: nil).size.height
        context?.saveGState()
        context?.clip(to: nameLabelInset)
        NSString(string: presetName).draw(in: CGRect(x: nameLabelInset.minX,
                                                     y: nameLabelInset.minY +
                                                        (nameLabelInset.height - nameLabelTextHeight) / 2,
                                                     width: nameLabelInset.width,
                                                     height: nameLabelTextHeight),
                                          withAttributes: nameLabelFontAttributes)
        context?.restoreGState()
    }

    /// Draw the preset loader
    override open func draw(_ rect: CGRect) {

        if !presets.isEmpty {
            let displayName = String(currentIndex) + ": " + presets[currentIndex]
            let presetName = isPresetLoaded ? displayName : "None"
            drawPresetLoader(presetName: presetName, isPresetLoaded: isPresetLoaded)
        } else {
            AKLog("presets is empty")
        }
    }

    /// Handle new touches
    override open func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {

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
    override open func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
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
