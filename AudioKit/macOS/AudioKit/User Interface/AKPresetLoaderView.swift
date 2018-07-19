//
//  AKPresetLoaderView.swift
//  AudioKit for macOS
//
//  Created by Aurelius Prochazka, revision history on Githbub.
//  Copyright © 2017 Aurelius Prochazka. All rights reserved.
//

public class AKPresetLoaderView: NSView {
    // Default corner radius
    static var standardCornerRadius: CGFloat = 3.0

    var player: AKPlayer?
    var presetOuterPath = NSBezierPath()
    var upOuterPath = NSBezierPath()
    var downOuterPath = NSBezierPath()

    var currentIndex = -1
    var presets = [String]()
    var callback: (String) -> Void
    var isPresetLoaded = false

    open var bgColor: AKColor? {
        didSet {
            needsDisplay = true
        }
    }

    open var textColor: AKColor? {
        didSet {
            needsDisplay = true
        }
    }

    open var borderColor: AKColor? {
        didSet {
            needsDisplay = true
        }
    }

    open var borderWidth: CGFloat = 3.0 {
        didSet {
            needsDisplay = true
        }
    }

    public init(presets: [String],
                frame: CGRect = CGRect(x: 0, y: 0, width: 440, height: 60),
                callback: @escaping (String) -> Void) {
        self.callback = callback
        self.presets = presets
        super.init(frame: frame)
    }

    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override public func mouseDown(with theEvent: NSEvent) {
        isPresetLoaded = false
        let touchLocation = convert(theEvent.locationInWindow, from: nil)
        if upOuterPath.contains(touchLocation) {
            currentIndex -= 1
            isPresetLoaded = true
        }
        if downOuterPath.contains(touchLocation) {
            currentIndex += 1
            isPresetLoaded = true
        }
        if currentIndex < 0 { currentIndex = presets.count - 1 }
        if currentIndex >= presets.count { currentIndex = 0 }

        if isPresetLoaded {
            callback(presets[currentIndex])
            needsDisplay = true
        }
    }

    // Default background color per theme
    var bgColorForTheme: AKColor {
        if let bgColor = bgColor { return bgColor }

        switch AKStylist.sharedInstance.theme {
        case .basic: return AKColor(white: 0.8, alpha: 1.0)
        case .midnight: return AKColor(white: 0.7, alpha: 1.0)
        }
    }

    // Default border color per theme
    var borderColorForTheme: AKColor {
        if let borderColor = borderColor { return borderColor }

        switch AKStylist.sharedInstance.theme {
        case .basic: return AKColor(white: 0.3, alpha: 1.0).withAlphaComponent(0.8)
        case .midnight: return AKColor.white.withAlphaComponent(0.8)
        }
    }

    // Default text color per theme
    var textColorForTheme: AKColor {
        if let textColor = textColor { return textColor }

        switch AKStylist.sharedInstance.theme {
        case .basic: return AKColor(white: 0.3, alpha: 1.0)
        case .midnight: return AKColor.white
        }
    }

    func drawPresetLoader(presetName: String = "None", isPresetLoaded: Bool = false) {
        //// General Declarations
        let rect = self.bounds
        _ = unsafeBitCast(NSGraphicsContext.current?.graphicsPort, to: CGContext.self)

        let cornerRadius: CGFloat = AKPresetLoaderView.standardCornerRadius

        //// Color Declarations
        let green = AKStylist.sharedInstance.colorForTrueValue
        let red = AKStylist.sharedInstance.colorForFalseValue
        let gray = bgColorForTheme

        //// Variable Declarations
        let expression: NSColor = isPresetLoaded ? green : red

        //// background Drawing
        let backgroundPath = NSBezierPath(rect: NSRect(x: borderWidth,
                                                       y: borderWidth,
                                                       width: rect.width - borderWidth * 2.0,
                                                       height: rect.height - borderWidth * 2.0))
        gray.setFill()
        backgroundPath.fill()

        //// presetButton
        //// presetOuter Drawing
        presetOuterPath = NSBezierPath(rect: NSRect(x: borderWidth, y: borderWidth, width: rect.width * 0.25, height: rect.height - borderWidth * 2.0))
        expression.setFill()
        presetOuterPath.fill()

        // presetButton border Path
        let presetButtonBorderPath = NSBezierPath()
        presetButtonBorderPath.move(to: NSPoint(x: rect.width * 0.25 + borderWidth, y: borderWidth))
        presetButtonBorderPath.line(to: NSPoint(x: rect.width * 0.25 + borderWidth, y: rect.height - borderWidth))
        borderColorForTheme.setStroke()
        presetButtonBorderPath.lineWidth = borderWidth / 2.0
        presetButtonBorderPath.stroke()

        //// presetLabel Drawing
        let presetLabelRect = NSRect(x: 0, y: 0, width: rect.width * 0.25, height: rect.height)
        let presetLabelTextContent = NSString(string: "Preset")
        let presetLabelStyle = NSMutableParagraphStyle()
        presetLabelStyle.alignment = .center

        let presetLabelFontAttributes = [NSAttributedStringKey.font: NSFont.boldSystemFont(ofSize: 24),
                                         NSAttributedStringKey.foregroundColor: textColorForTheme,
                                         NSAttributedStringKey.paragraphStyle: presetLabelStyle]

        let presetLabelInset: CGRect = presetLabelRect.insetBy(dx: 10, dy: 0)
        let presetLabelTextHeight: CGFloat = presetLabelTextContent.boundingRect(
            with: NSSize(width: presetLabelInset.width, height: CGFloat.infinity),
            options: .usesLineFragmentOrigin,
            attributes: presetLabelFontAttributes).size.height
        let presetLabelTextRect: NSRect = NSRect(
            x: presetLabelInset.minX,
            y: presetLabelInset.minY + (presetLabelInset.height - presetLabelTextHeight) / 2,
            width: presetLabelInset.width,
            height: presetLabelTextHeight)
        NSGraphicsContext.saveGraphicsState()
        __NSRectClip(presetLabelInset)
        presetLabelTextContent.draw(in: presetLabelTextRect.offsetBy(dx: 0, dy: 0),
                                    withAttributes: presetLabelFontAttributes)
        NSGraphicsContext.restoreGraphicsState()

        //// upButton
        //// upOuter Drawing
        upOuterPath = NSBezierPath(rect: NSRect(x: rect.width * 0.9, y: rect.height * 0.5, width: rect.width * 0.07, height: rect.height * 0.5))

        //// upInner Drawing
        let upperArrowRect = NSRect(x: rect.width * 0.9, y: rect.height * 0.58, width: rect.width * 0.07, height: rect.height * 0.3)
        let upInnerPath = NSBezierPath()
        upInnerPath.move(to: NSPoint(x: upperArrowRect.minX + cornerRadius / 2.0, y: upperArrowRect.minY))
        upInnerPath.line(to: NSPoint(x: upperArrowRect.maxX - cornerRadius / 2.0, y: upperArrowRect.minY))
        upInnerPath.curve(to: NSPoint(x: upperArrowRect.maxX - cornerRadius / 2.0, y: upperArrowRect.minY + cornerRadius / 2.0), controlPoint1: NSPoint(x: upperArrowRect.maxX, y: upperArrowRect.minY), controlPoint2: NSPoint(x: upperArrowRect.maxX, y: upperArrowRect.minY))
        upInnerPath.line(to: NSPoint(x: upperArrowRect.midX + cornerRadius / 2.0, y: upperArrowRect.maxY - cornerRadius / 2.0))
        upInnerPath.curve(to: NSPoint(x: upperArrowRect.midX - cornerRadius / 2.0, y: upperArrowRect.maxY - cornerRadius / 2.0), controlPoint1: NSPoint(x: upperArrowRect.midX, y: upperArrowRect.maxY), controlPoint2: NSPoint(x: upperArrowRect.midX, y: upperArrowRect.maxY))
        upInnerPath.line(to: NSPoint(x: upperArrowRect.minX + cornerRadius / 2.0, y: upperArrowRect.minY + cornerRadius / 2.0))
        upInnerPath.curve(to: NSPoint(x: upperArrowRect.minX + cornerRadius / 2.0, y: upperArrowRect.minY), controlPoint1: NSPoint(x: upperArrowRect.minX, y: upperArrowRect.minY), controlPoint2: NSPoint(x: upperArrowRect.minX, y: upperArrowRect.minY))
        textColorForTheme.setStroke()
        upInnerPath.lineWidth = borderWidth
        upInnerPath.stroke()

        downOuterPath = NSBezierPath(rect: NSRect(x: rect.width * 0.9, y: 0, width: rect.width * 0.07, height: rect.height * 0.5))

        //// downInner Drawing
        let downArrowRect = NSRect(x: rect.width * 0.9, y: rect.height * 0.12, width: rect.width * 0.07, height: rect.height * 0.3)
        let downInnerPath = NSBezierPath()
        downInnerPath.move(to: NSPoint(x: downArrowRect.minX + cornerRadius / 2.0, y: downArrowRect.maxY))
        downInnerPath.line(to: NSPoint(x: downArrowRect.maxX - cornerRadius / 2.0, y: downArrowRect.maxY))
        downInnerPath.curve(to: NSPoint(x: downArrowRect.maxX - cornerRadius / 2.0, y: downArrowRect.maxY - cornerRadius / 2.0), controlPoint1: NSPoint(x: downArrowRect.maxX, y: downArrowRect.maxY), controlPoint2: NSPoint(x: downArrowRect.maxX, y: downArrowRect.maxY))
        downInnerPath.line(to: NSPoint(x: downArrowRect.midX + cornerRadius / 2.0, y: downArrowRect.minY + cornerRadius / 2.0))
        downInnerPath.curve(to: NSPoint(x: downArrowRect.midX - cornerRadius / 2.0, y: downArrowRect.minY + cornerRadius / 2.0), controlPoint1: NSPoint(x: downArrowRect.midX, y: downArrowRect.minY), controlPoint2: NSPoint(x: downArrowRect.midX, y: downArrowRect.minY))
        downInnerPath.line(to: NSPoint(x: downArrowRect.minX + cornerRadius / 2.0, y: downArrowRect.maxY - cornerRadius / 2.0))
        downInnerPath.curve(to: NSPoint(x: downArrowRect.minX + cornerRadius / 2.0, y: downArrowRect.maxY), controlPoint1: NSPoint(x: downArrowRect.minX, y: downArrowRect.maxY), controlPoint2: NSPoint(x: downArrowRect.minX, y: downArrowRect.maxY))
        textColorForTheme.setStroke()
        downInnerPath.lineWidth = borderWidth
        downInnerPath.stroke()

        //// nameLabel Drawing
        let nameLabelRect = NSRect(x: rect.width * 0.25, y: 0, width: rect.width * 0.75, height: rect.height)
        let nameLabelStyle = NSMutableParagraphStyle()
        nameLabelStyle.alignment = .left

        let nameLabelFontAttributes = [NSAttributedStringKey.font: NSFont.boldSystemFont(ofSize: 24),
                                       NSAttributedStringKey.foregroundColor: textColorForTheme,
                                       NSAttributedStringKey.paragraphStyle: nameLabelStyle]

        let nameLabelInset: CGRect = nameLabelRect.insetBy(dx: rect.width * 0.04, dy: 0)
        let nameLabelTextHeight: CGFloat = NSString(string: presetName).boundingRect(
            with: NSSize(width: nameLabelInset.width, height: CGFloat.infinity),
            options: .usesLineFragmentOrigin,
            attributes: nameLabelFontAttributes).size.height
        let nameLabelTextRect: NSRect = NSRect(
            x: nameLabelInset.minX,
            y: nameLabelInset.minY + (nameLabelInset.height - nameLabelTextHeight) / 2,
            width: nameLabelInset.width,
            height: nameLabelTextHeight)
        NSGraphicsContext.saveGraphicsState()
        __NSRectClip(nameLabelInset)
        NSString(string: presetName).draw(in: nameLabelTextRect.offsetBy(dx: 0, dy: 0),
                                          withAttributes: nameLabelFontAttributes)
        NSGraphicsContext.restoreGraphicsState()

        let outerRect = CGRect(x: rect.origin.x + borderWidth / 2.0,
                               y: rect.origin.y + borderWidth / 2.0,
                               width: rect.width - borderWidth,
                               height: rect.height - borderWidth)

        let outerPath = NSBezierPath(roundedRect: outerRect, xRadius: cornerRadius, yRadius: cornerRadius)
        borderColorForTheme.setStroke()
        outerPath.lineWidth = borderWidth
        outerPath.stroke()
    }

    override public func draw(_ rect: CGRect) {
        let presetName = isPresetLoaded ? presets[currentIndex] : "None"
        drawPresetLoader(presetName: presetName, isPresetLoaded: isPresetLoaded)
    }
}
