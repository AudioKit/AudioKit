//
//  AKButton.swift
//  AudioKit for iOS
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright © 2017 Aurelius Prochazka. All rights reserved.
//

/// A button, mainly used for playgrounds, but could be useful in your own projects

public enum AKButtonStyle {
    case standard
    case round
}

@IBDesignable open class AKButton: UIView {
    // Default side
    static var defaultSize = CGSize(width: 440.0, height: 60.0)
    
    // Default corner radius
    static var standardCornerRadius: CGFloat = 3.0
    
    public var callback: () -> (String)

    /// Text to display on the button
    @IBInspectable open var title: String {
        didSet {
            setNeedsDisplay()
        }
    }
    
    /// Background color of the button
    @IBInspectable open var color: AKColor {
        didSet {
            setNeedsDisplay()
        }
    }

    /// Button border color
    @IBInspectable open var borderColor: AKColor? {
        didSet {
            setNeedsDisplay()
        }
    }
    
    // Button border width
    @IBInspectable open var borderWidth: CGFloat = 3.0 {
        didSet {
            setNeedsDisplay()
        }
    }
    
    
    /// Text color
    @IBInspectable open var textColor: AKColor? {
        didSet {
            setNeedsDisplay()
        }
    }
    
    open var style: AKButtonStyle = .standard {
        didSet {
            setNeedsDisplay()
        }
    }
    
    
    /// Handle new touches
    override open func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let newTitle = callback()
        if newTitle != "" { title = newTitle }
        
        transform = CGAffineTransform(scaleX: 0.98, y: 0.98)
        
        
    }
    
    open override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        transform = CGAffineTransform.identity
    }

    /// Initialize the button
    public init(title: String,
                color: AKColor = AKStylist.sharedInstance.nextColor,
                frame: CGRect = CGRect(x: 0, y: 0, width: AKButton.defaultSize.width, height: AKButton.defaultSize.height),
                callback: @escaping () -> (String)) {
        self.title = title
        self.callback = callback
        self.color = color
        super.init(frame: frame)
        
        clipsToBounds = true
    }

    
    /// Initialization within Interface Builder
    required public init?(coder: NSCoder) {
        self.callback = { return "" }
        self.title = "Title"
        self.color = AKStylist.sharedInstance.nextColor
        super.init(coder: coder)

        self.clipsToBounds = true
        self.backgroundColor = AKColor.clear
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
            case .round: return rect.height/2.0
            }
        }()
        
        let outerRect = CGRect(x: rect.origin.x + borderWidth / 2.0, y: rect.origin.y + borderWidth / 2.0, width: rect.width - borderWidth, height: rect.height - borderWidth)
        let outerPath = UIBezierPath(roundedRect: outerRect, byRoundingCorners: .allCorners, cornerRadii: CGSize(width: cornerRadius, height: cornerRadius))
        color.setFill()
        outerPath.fill()
        borderColorForTheme.setStroke()
        outerPath.lineWidth = borderWidth
        outerPath.stroke()        

        let labelStyle = NSMutableParagraphStyle()
        labelStyle.alignment = .center

        let labelFontAttributes = [NSFontAttributeName: UIFont.boldSystemFont(ofSize: 24),
                                   NSForegroundColorAttributeName: textColorForTheme,
                                   NSParagraphStyleAttributeName: labelStyle]

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
