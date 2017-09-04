//
//  AKButton.swift
//  AudioKit for iOS
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright © 2017 Aurelius Prochazka. All rights reserved.
//

/// Different looks the button can have
public enum AKButtonStyle {
    /// Rectangular button
    case standard
    /// Button with rounded ends
    case round
}

/// A button, mainly used for playgrounds, but could be useful in your own projects
@IBDesignable open class AKButton: UIView {
    // Default corner radius
    static var standardCornerRadius: CGFloat = 3.0

    public var callback: (AKButton) -> Void = { _ in }

    private var isHighlighted = false {
        didSet {
            setNeedsDisplay()
        }
    }

    private var highlightAnimationTimer: Timer?
    private var highlightAnimationAlpha: CGFloat = 1.0

    /// Text to display on the button
    @IBInspectable open var title: String {
        didSet {
            setNeedsDisplay()
        }
    }

    /// Background color of the button
    @IBInspectable open var color: UIColor {
        didSet {
            setNeedsDisplay()
        }
    }

    /// Button border color
    @IBInspectable open var borderColor: UIColor? {
        didSet {
            setNeedsDisplay()
        }
    }

    /// Color when the button is highlighted
    @IBInspectable open var highlightedColor: UIColor? {
        didSet {
            setNeedsDisplay()
        }
    }

    /// Button border width
    @IBInspectable open var borderWidth: CGFloat = 3.0 {
        didSet {
            setNeedsDisplay()
        }
    }

    /// Text color
    @IBInspectable open var textColor: UIColor? {
        didSet {
            setNeedsDisplay()
        }
    }

    /// Button style
    open var style: AKButtonStyle = .standard {
        didSet {
            setNeedsDisplay()
        }
    }

    /// Handle new touches
    override open func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        callback(self)

        transform = CGAffineTransform(scaleX: 0.98, y: 0.98)
        isHighlighted = true
    }

    /// Handle touch events
    open override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        transform = CGAffineTransform.identity
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
        setNeedsDisplay()
        if highlightAnimationAlpha == 1.0, let highlightAnimationTimer = highlightAnimationTimer {
            highlightAnimationTimer.invalidate()
            self.highlightAnimationTimer = nil
        }
    }

    /// Initialize the button
    public init(title: String,
                color: AKColor = AKStylist.sharedInstance.nextColor,
                frame: CGRect = CGRect(x: 0, y: 0, width: 440, height: 60),
                callback: @escaping (AKButton) -> Void) {
        self.title = title
        self.color = color
        self.callback = callback
        super.init(frame: frame)

        clipsToBounds = true
    }

    /// Initialization with no details
    override public init(frame: CGRect) {
        self.title = ""
        self.color = AKStylist.sharedInstance.nextColor
        super.init(frame: frame)

        self.backgroundColor = AKColor.clear
        contentMode = .redraw
    }

    /// Initialization within Interface Builder
    required public init?(coder: NSCoder) {
        self.title = ""
        self.color = AKStylist.sharedInstance.nextColor
        super.init(coder: coder)

        self.clipsToBounds = true
        self.backgroundColor = AKColor.clear
        contentMode = .redraw
    }

    /// Actions to perform to make sure the view is renderable in Interface Builder
    override open func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()

        clipsToBounds = true
    }

    /// Require constraint-based layout
    open class override var requiresConstraintBasedLayout: Bool {
        return true
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
        //// General Declarations
        let context = UIGraphicsGetCurrentContext()

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
        let outerPath = UIBezierPath(roundedRect: outerRect,
                                     byRoundingCorners: .allCorners,
                                     cornerRadii: CGSize(width: cornerRadius, height: cornerRadius))

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

        let labelFontAttributes = [NSAttributedStringKey.font: UIFont.boldSystemFont(ofSize: 24),
                                   NSAttributedStringKey.foregroundColor: textColorForTheme,
                                   NSAttributedStringKey.paragraphStyle: labelStyle]

        let labelInset: CGRect = rect.insetBy(dx: 10, dy: 0)
        let labelTextHeight: CGFloat = NSString(string: title).boundingRect(
            with: CGSize(width: labelInset.width, height: CGFloat.infinity),
            options: NSStringDrawingOptions.usesLineFragmentOrigin,
            attributes: labelFontAttributes,
            context: nil).size.height
        context?.saveGState()
        context?.clip(to: labelInset)
        NSString(string: title).draw(in: CGRect(x: labelInset.minX,
                                                y: labelInset.minY + (labelInset.height - labelTextHeight) / 2,
                                                width: labelInset.width,
                                                height: labelTextHeight),
                                     withAttributes: labelFontAttributes)
        context?.restoreGState()

    }
}
