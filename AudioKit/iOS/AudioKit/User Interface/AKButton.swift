//
//  AKButton.swift
//  AudioKit for iOS
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright © 2017 Aurelius Prochazka. All rights reserved.
//

open class AKButton: UIView {
    internal var callback: () -> (String)
    open var title: String {
        didSet {
            setNeedsDisplay()
        }
    }
    open var color: UIColor {
        didSet {
            setNeedsDisplay()
        }
    }

    override open func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let newTitle = callback()
        if newTitle != "" { title = newTitle }
    }

    @IBInspectable open var fontSize: CGFloat = 24
    @IBInspectable open var font: UIFont = UIFont.boldSystemFont(ofSize: 24)

    public init(title: String,
                color: UIColor = #colorLiteral(red: 0.029, green: 1.000, blue: 0.000, alpha: 1.000),
                frame: CGRect = CGRect(x: 0, y: 0, width: 440, height: 60),
                font: UIFont = UIFont.boldSystemFont(ofSize: 24),
                fontSize: CGFloat = 24,
                callback: @escaping () -> (String)) {
        self.title = title
        self.callback = callback
        self.color = color
        self.fontSize = fontSize
        self.font = font
        super.init(frame: frame)
    }

    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func drawButton() {
        //// General Declarations
        let context = UIGraphicsGetCurrentContext()

        let outerPath = UIBezierPath(rect: self.bounds)
        color.setFill()
        outerPath.fill()

        let labelRect = self.bounds
        let labelStyle = NSMutableParagraphStyle()
        labelStyle.alignment = .center

        // Font with fontName and fontSize
        let finalFontName = font.fontName
        let finalFont = UIFont.init(name: finalFontName, size: fontSize) as Any
        let buttonLabelStyle = NSMutableParagraphStyle()
        buttonLabelStyle.alignment = .center
        let labelFontAttributes = [NSFontAttributeName: finalFont,
                                       NSForegroundColorAttributeName: UIColor.black,
                                       NSParagraphStyleAttributeName: buttonLabelStyle] as [String : Any]

        let labelInset: CGRect = labelRect.insetBy(dx: 0, dy: 0)
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

    override open func draw(_ rect: CGRect) {
        drawButton()
    }
}
