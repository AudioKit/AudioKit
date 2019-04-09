//
//  AKButton.swift
//  AudioKit for macOS
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright © 2017 Aurelius Prochazka. All rights reserved.
//

/// A button, mainly used for playgrounds, but could be useful in your own projects
import AudioKit

public enum AKButtonStyle {
    case standard
    case round
}

@IBDesignable open class AKButton: AKView {

    // Default corner radius
    static var standardCornerRadius: CGFloat = 3.0

    public var callback: (AKButton) -> Void = { _ in }

    private var isHighlighted = false {
        didSet {
            needsDisplay = true
        }
    }

    private var highlightAnimationTimer: Timer?
    private var highlightAnimationAlpha: CGFloat = 1.0

    /// Text to display on the button
    @IBInspectable open var title: String {
        didSet {
            needsDisplay = true
        }
    }

    /// Button fill color
    @IBInspectable open var color: NSColor {
        didSet {
            needsDisplay = true
        }
    }

    /// Button fill color when highlighted
    @IBInspectable open var highlightedColor: NSColor? {
        didSet {
            needsDisplay = true
        }
    }

    /// Button border color
    @IBInspectable open var borderColor: NSColor? {
        didSet {
            needsDisplay = true
        }
    }

    // Button border width
    @IBInspectable open var borderWidth: CGFloat = 3.0 {
        didSet {
            needsDisplay = true
        }
    }

    /// Text color
    @IBInspectable open var textColor: NSColor? {
        didSet {
            needsDisplay = true
        }
    }

    open var style: AKButtonStyle = .standard {
        didSet {
            needsDisplay = true
        }
    }

    open override func mouseDown(with event: NSEvent) {
        callback(self)
        isHighlighted = true
    }

    open override func mouseUp(with event: NSEvent) {
        isHighlighted = false

        if let highlightAnimationTimer = highlightAnimationTimer {
            highlightAnimationTimer.invalidate()
            self.highlightAnimationTimer = nil
        }
        self.highlightAnimationAlpha = 0.6
        highlightAnimationTimer = Timer.scheduledTimer(timeInterval: 0.002, target: self, selector: #selector(highlightAnimationTimerDidFire), userInfo: nil, repeats: true)
    }

    @objc private func highlightAnimationTimerDidFire() {
        highlightAnimationAlpha += 0.01
        needsDisplay = true
        if highlightAnimationAlpha == 1.0, let highlightAnimationTimer = highlightAnimationTimer {
            highlightAnimationTimer.invalidate()
            self.highlightAnimationTimer = nil
        }
    }

    /// Initialize the button
    public init(title: String,
                color: AKColor = AKStylist.sharedInstance.nextColor,
                frame: CGRect = CGRect(width: 440, height: 60),
                callback: @escaping (AKButton) -> Void) {
        self.title = title
        self.callback = callback
        self.color = color
        super.init(frame: frame)

        self.wantsLayer = true
    }

    /// Initialization with no details
    override public init(frame: CGRect) {
        self.title = "Title"
        self.color = AKStylist.sharedInstance.nextColor
        super.init(frame: frame)

        self.wantsLayer = true
    }

    /// Initialization within Interface Builder
    required public init?(coder: NSCoder) {
        self.title = "Title"
        self.color = AKStylist.sharedInstance.nextColor
        super.init(coder: coder)

        self.wantsLayer = true
    }

    /// Actions to perform to make sure the view is renderable in Interface Builder
    override open func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()

        self.wantsLayer = true
    }

    // Default border color per theme
    var borderColorForTheme: AKColor {
        if let borderColor = borderColor { return borderColor }

        switch AKStylist.sharedInstance.theme {
        case .basic: return AKColor(white: 0.3, alpha: 1.0)
        case .midnight: return AKColor.white
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

    /// Draw the button
    override open func draw(_ rect: CGRect) {
        drawButton(rect: rect)
    }

    func drawButton(rect: CGRect) {
        let cornerRadius: CGFloat = {
            switch self.style {
            case .standard: return AKButton.standardCornerRadius
            case .round: return rect.height / 2.0
            }
        }()

        let outerRect = CGRect(x: rect.origin.x + borderWidth / 2.0,
                               y: rect.origin.y + borderWidth / 2.0,
                               width: rect.width - borderWidth,
                               height: rect.height - borderWidth)
        let outerPath = NSBezierPath(roundedRect: outerRect, xRadius: cornerRadius, yRadius: cornerRadius)

        // Set fill color based on highlight state
        if isHighlighted {
            if let highlightedColor = highlightedColor {
                highlightedColor.setFill()
            } else {
                color.withAlphaComponent(0.6).setFill()
            }
        } else {
            if highlightAnimationTimer != nil {
                color.withAlphaComponent(highlightAnimationAlpha).setFill()
            } else {
                color.setFill()
            }
        }

        outerPath.fill()
        borderColorForTheme.setStroke()
        outerPath.lineWidth = borderWidth
        outerPath.stroke()

        let labelStyle = NSMutableParagraphStyle()
        labelStyle.alignment = .center

        let labelFontAttributes: [NSAttributedString.Key: Any] = [.font: NSFont.boldSystemFont(ofSize: 24),
                                   .foregroundColor: textColorForTheme,
                                   .paragraphStyle: labelStyle]

        let labelInset: CGRect = rect.insetBy(dx: 10, dy: 0)
        let labelTextHeight: CGFloat = NSString(string: title).boundingRect(
            with: CGSize(width: labelInset.width, height: .infinity),
            options: .usesLineFragmentOrigin,
            attributes: labelFontAttributes,
            context: nil).size.height
        NSString(string: title).draw(in: CGRect(x: labelInset.minX,
                                                y: labelInset.minY + (labelInset.height - labelTextHeight) / 2,
                                                width: labelInset.width,
                                                height: labelTextHeight),
                                     withAttributes: labelFontAttributes)
    }
}
