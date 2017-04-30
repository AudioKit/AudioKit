//
//  AKPropertySlider.swift
//  AudioKit for iOS
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright © 2017 Aurelius Prochazka. All rights reserved.
//

/// Simple slider interface for AudioKit properties
@IBDesignable open class AKPropertySlider: UIView {

    /// Current value of the slider
    @IBInspectable open var value: Double = 0 {
        didSet {
            setNeedsDisplay()
        }
    }
    @IBInspectable open var minimum: Double = 0
    @IBInspectable open var maximum: Double = 1
    @IBInspectable open var property: String = "Property"
    @IBInspectable open var format: String = "%0.3f"
    @IBInspectable open var bgColor: UIColor = UIColor(colorLiteralRed: 0.9, green: 0.9, blue: 0.9, alpha: 1)
    @IBInspectable open var sliderColor: UIColor = .red
    @IBInspectable open var textColor: UIColor = .black
    @IBInspectable open var fontSize: CGFloat = 24
    @IBInspectable open var font: UIFont = UIFont.boldSystemFont(ofSize: 24)

    open var callback: ((Double) -> Void)?
    open var lastTouch = CGPoint.zero

    public init(property: String,
                format: String = "%0.3f",
                value: Double,
                minimum: Double = 0,
                maximum: Double = 1,
                color: UIColor = UIColor.red,
                frame: CGRect = CGRect(x: 0, y: 0, width: 440, height: 60),
                font: UIFont = UIFont.boldSystemFont(ofSize: 24),
                fontSize: CGFloat = 24,
                callback: @escaping (_ x: Double) -> Void) {
        super.init(frame: frame)
        self.value = value
        self.minimum = minimum
        self.maximum = maximum
        self.property = property
        self.format = format
        self.sliderColor = color
        self.font = font
        self.fontSize = fontSize
        self.layer.borderColor = UIColor.init(colorLiteralRed: 0, green: 0, blue: 0, alpha: 0.5).cgColor
        self.layer.borderWidth = 1
        self.callback = callback

        setNeedsDisplay()
    }

    override public init(frame: CGRect) {
        super.init(frame: frame)
        contentMode = .redraw
    }

    required public init?(coder: NSCoder) {
        super.init(coder: coder)
        self.isUserInteractionEnabled = true
        contentMode = .redraw
    }

    override open func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()
        clipsToBounds = true
    }

    open class override var requiresConstraintBasedLayout: Bool {
        return true
    }

    override open func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first {
            let touchLocation = touch.location(in: self)
            lastTouch = touchLocation
            value = Double(touchLocation.x / bounds.width) * (maximum - minimum) + minimum
            setNeedsDisplay()
            callback?(value)

        }
    }

    override open func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first {
            let touchLocation = touch.location(in: self)
            if lastTouch.x != touchLocation.x {
                value = Double(touchLocation.x / bounds.width) * (maximum - minimum) + minimum
                if value > maximum { value = maximum }
                if value < minimum { value = minimum }
                setNeedsDisplay()
                callback?(value)
                lastTouch = touchLocation
            }
        }
    }
    
    override open func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first {
            let touchLocation = touch.location(in: self)
            if lastTouch.x != touchLocation.x {
                value = Double(touchLocation.x / bounds.width) * (maximum - minimum) + minimum
                if value > maximum { value = maximum }
                if value < minimum { value = minimum }
                setNeedsDisplay()
                callback?(value)
                lastTouch = touchLocation
            }
        }
    }

    open func randomize() -> Double {
        value = random(minimum, maximum)
        setNeedsDisplay()
        return value
    }

    override open func draw(_ rect: CGRect) {
        drawFlatSlider(currentValue: CGFloat(value),
            minimum: CGFloat(minimum),
            maximum: CGFloat(maximum),
            propertyName: property,
            currentValueText: String(format: format, value)
        )
    }

    func drawFlatSlider(currentValue: CGFloat = 0,
                        initialValue: CGFloat = 0,
                        minimum: CGFloat = 0,
                        maximum: CGFloat = 1,
                        propertyName: String = "Property Name",
                        currentValueText: String = "0.0") {
        //// General Declarations
        let context = UIGraphicsGetCurrentContext()

        let width = self.frame.width
        let height = self.frame.height

        //// Variable Declarations
        let currentWidth: CGFloat = currentValue < minimum ? 0 :
            (currentValue < maximum ? (currentValue - minimum) / (maximum - minimum) * width : width)

        //// sliderArea Drawing
        let sliderAreaPath = UIBezierPath(rect: CGRect(x: 0, y: 0, width: width, height: height))
        bgColor.setFill()
        sliderAreaPath.fill()

        //// valueRectangle Drawing
        let valueRectanglePath = UIBezierPath(rect: CGRect(x: 0, y: 0, width: currentWidth, height: height))
        sliderColor.setFill()
        valueRectanglePath.fill()

        //// nameLabel Drawing
        let nameLabelRect = CGRect(x: 0, y: 0, width: width, height: height)
        let nameLabelStyle = NSMutableParagraphStyle()
        nameLabelStyle.alignment = .left

        // Font with fontName and fontSize
        let finalFontName = font.fontName
        let finalFont = UIFont.init(name: finalFontName, size: fontSize) as Any
        let nameLabelFontAttributes = [NSFontAttributeName: finalFont,
                                       NSForegroundColorAttributeName: textColor,
                                       NSParagraphStyleAttributeName: nameLabelStyle] as [String : Any]

        let nameLabelInset: CGRect = nameLabelRect.insetBy(dx: 10, dy: 0)
        let nameLabelTextHeight: CGFloat = NSString(string: propertyName).boundingRect(
            with: CGSize(width: nameLabelInset.width, height: CGFloat.infinity),
            options: NSStringDrawingOptions.usesLineFragmentOrigin,
            attributes: nameLabelFontAttributes,
            context: nil).size.height
        context?.saveGState()
        context?.clip(to: nameLabelInset)
        NSString(string: propertyName).draw(
            in: CGRect(x: nameLabelInset.minX,
                       y: nameLabelInset.minY + (nameLabelInset.height - nameLabelTextHeight) / 2,
                       width: nameLabelInset.width,
                       height: nameLabelTextHeight),
            withAttributes: nameLabelFontAttributes)
        context?.restoreGState()

        //// valueLabel Drawing
        let valueLabelRect = CGRect(x: 0, y: 0, width: width, height: height)
        let valueLabelStyle = NSMutableParagraphStyle()
        valueLabelStyle.alignment = .right

        let valueLabelFontAttributes = [NSFontAttributeName: finalFont,
                                        NSForegroundColorAttributeName: textColor,
                                        NSParagraphStyleAttributeName: valueLabelStyle] as [String : Any]

        let valueLabelInset: CGRect = valueLabelRect.insetBy(dx: 10, dy: 0)
        let valueLabelTextHeight: CGFloat = NSString(string: currentValueText).boundingRect(
            with: CGSize(width: valueLabelInset.width, height: CGFloat.infinity),
            options: NSStringDrawingOptions.usesLineFragmentOrigin,
            attributes: valueLabelFontAttributes,
            context: nil).size.height
        context?.saveGState()
        context?.clip(to: valueLabelInset)
        NSString(string: currentValueText).draw(
            in: CGRect(x: valueLabelInset.minX,
                       y: valueLabelInset.minY + (valueLabelInset.height - valueLabelTextHeight) / 2,
                       width: valueLabelInset.width,
                       height: valueLabelTextHeight),
            withAttributes: valueLabelFontAttributes)
        context?.restoreGState()
    }

}
