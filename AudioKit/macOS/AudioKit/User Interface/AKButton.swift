//
//  AKButton.swift
//  AudioKit for macOS
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright © 2017 Aurelius Prochazka. All rights reserved.
//

import Foundation

public class AKButton: NSView {
    internal var callback: () -> (String)
    public var title: String {
        didSet {
            needsDisplay = true
        }
    }
    public  var color: NSColor {
        didSet {
            needsDisplay = true
        }
    }

    override public func mouseDown(with theEvent: NSEvent) {
        let newTitle = callback()
        if newTitle != "" { title = newTitle }
    }

    public init(title: String,
                color: NSColor = #colorLiteral(red: 0.029, green: 1.000, blue: 0.000, alpha: 1.000),
                frame: CGRect = CGRect(x: 0, y: 0, width: 440, height: 60),
                callback: @escaping () -> (String)) {
        self.title = title
        self.callback = callback
        self.color = color
        super.init(frame: frame)
    }

    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func drawButton() {
        //// General Declarations
        let context = unsafeBitCast(NSGraphicsContext.current()?.graphicsPort, to: CGContext.self)

        let outerPath = NSBezierPath(rect: CGRect(x: 0, y: 0, width: 440, height: 60))
        color.setFill()
        outerPath.fill()

        let labelRect = CGRect(x: 0, y: 0, width: 440, height: 60)
        let labelStyle = NSMutableParagraphStyle()
        labelStyle.alignment = .center

        let labelFontAttributes = [NSFontAttributeName: NSFont.boldSystemFont(ofSize: 24),
                                   NSForegroundColorAttributeName: NSColor.black,
                                   NSParagraphStyleAttributeName: labelStyle]

        let labelInset: CGRect = labelRect.insetBy(dx: 10, dy: 0)
        let labelTextHeight: CGFloat = NSString(string: title).boundingRect(
            with: CGSize(width: labelInset.width, height: CGFloat.infinity),
            options: NSStringDrawingOptions.usesLineFragmentOrigin,
            attributes: labelFontAttributes,
            context: nil).size.height
        context.saveGState()
        context.clip(to: labelInset)
        NSString(string: title).draw(in: CGRect(x: labelInset.minX,
                                                y: labelInset.minY + (labelInset.height - labelTextHeight) / 2,
                                                width: labelInset.width,
                                                height: labelTextHeight),
                                     withAttributes: labelFontAttributes)
        context.restoreGState()

    }

    override public func draw(_ rect: CGRect) {
        drawButton()
    }
}
