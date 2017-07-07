//
//  AKPropertySlider.swift
//  AudioKit for macOS
//
//  Created by Aurelius Prochazka on 7/26/16.
//  Copyright © 2017 Aurelius Prochazka. All rights reserved.
//

public class AKPropertySlider: NSView {
    override public func acceptsFirstMouse(for theEvent: NSEvent?) -> Bool {
        return true
    }
    public var callback: (Double) -> Void
    var initialValue: Double = 0
    public var value: Double = 0 {
        didSet {
            needsDisplay = true
        }
    }
    public var minimum: Double = 0
    public var maximum: Double = 0
    public var property: String = ""
    var format = ""
    var color = NSColor.red

    public init(property: String,
                format: String = "%0.3f",
                value: Double,
                minimum: Double = 0,
                maximum: Double = 1,
                color: NSColor = NSColor.red,
                frame: CGRect = CGRect(x: 0, y: 0, width: 440, height: 60),
                callback: @escaping (_ x: Double) -> Void) {
        self.value = value
        self.initialValue = value
        self.minimum = minimum
        self.maximum = maximum
        self.property = property
        self.format = format
        self.color = color

        self.callback = callback
        super.init(frame: frame)

        needsDisplay = true
    }

    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override public func mouseDown(with theEvent: NSEvent) {
        let loc = convert(theEvent.locationInWindow, from: nil)
        let center = convert(loc, from: nil)
        value = Double(center.x / bounds.width) * (maximum - minimum) + minimum
        needsDisplay = true
        callback(value)
    }
    override public func mouseDragged(with theEvent: NSEvent) {

        let loc = convert(theEvent.locationInWindow, from: nil)
        let center = convert(loc, from: nil)
        value = Double(center.x / bounds.width) * (maximum - minimum) + minimum
        if value > maximum { value = maximum }
        if value < minimum { value = minimum }
        needsDisplay = true
        callback(value)
    }

    public func randomize() -> Double {
        value = random(minimum, maximum)
        needsDisplay = true
        return value
    }

    override public func draw(_ dirtyRect: NSRect) {
        drawFlatSlider(currentValue: CGFloat(value),
                       initialValue: CGFloat(initialValue),
                       minimum: CGFloat(minimum),
                       maximum: CGFloat(maximum),
                       propertyName: property,
                       currentValueText: String(format: format, value))
    }

    func drawFlatSlider(currentValue: CGFloat = 0,
                        initialValue: CGFloat = 0,
                        minimum: CGFloat = 0,
                        maximum: CGFloat = 1,
                        propertyName: String = "Property Name",
                        currentValueText: String = "0.0") {
        //// General Declarations
        let context = unsafeBitCast(NSGraphicsContext.current()?.graphicsPort, to: CGContext.self)

        //// Color Declarations
        let backgroundColor = #colorLiteral(red: 0.835, green: 0.842, blue: 0.836, alpha: 0.925)
        let sliderColor = color // #colorLiteral(red: 1, green: 0, blue: 0.062, alpha: 1)

        //// Variable Declarations
        let height: CGFloat = self.frame.height
        let width: CGFloat = self.frame.width
        let currentWidth: CGFloat = currentValue < minimum ? 0 : (currentValue < maximum ?
            (currentValue - minimum) / (maximum - minimum) * self.frame.width : self.frame.width)
        let initialX: CGFloat = initialValue < minimum ? 9 : 9 + (initialValue < maximum ?
            (initialValue - minimum) / (maximum - minimum) * self.frame.width : self.frame.width)

        //// sliderArea Drawing
        let sliderAreaPath = NSBezierPath(rect: NSRect(x: 0, y: 0, width: width, height: height))
        backgroundColor.setFill()
        sliderAreaPath.fill()

        //// valueRectangle Drawing
        let valueRectanglePath = NSBezierPath(rect: NSRect(x: 0, y: 0, width: currentWidth, height: height))
        sliderColor.setFill()
        valueRectanglePath.fill()

        //// initialValueBezier Drawing
        NSGraphicsContext.saveGraphicsState()
        context.translateBy(x: (initialX - 8), y: 0)

        let initialValueBezierPath = NSBezierPath()
        initialValueBezierPath.move(to: NSPoint(x: 0, y: height))
        initialValueBezierPath.line(to: NSPoint(x: 0.25, y: 0))
        NSColor.white.setFill()
        initialValueBezierPath.fill()
        NSColor.black.setStroke()
        initialValueBezierPath.lineWidth = 0.5
        initialValueBezierPath.setLineDash([2, 2], count: 2, phase: 0)
        initialValueBezierPath.stroke()

        NSGraphicsContext.restoreGraphicsState()

        //// nameLabel Drawing
        let nameLabelRect = NSRect(x: 0, y: 0, width: width, height: height)
        let nameLabelStyle = NSMutableParagraphStyle()
        nameLabelStyle.alignment = .left

        let nameLabelFontAttributes = [NSFontAttributeName: NSFont(name: "HelveticaNeue", size: 24)!,
                                       NSForegroundColorAttributeName: NSColor.black,
                                       NSParagraphStyleAttributeName: nameLabelStyle]

        let nameLabelInset: CGRect = nameLabelRect.insetBy(dx: 10, dy: 0)
        let nameLabelTextHeight: CGFloat = NSString(string: propertyName).boundingRect(
            with: NSSize(width: nameLabelInset.width, height: CGFloat.infinity),
            options: NSStringDrawingOptions.usesLineFragmentOrigin,
            attributes: nameLabelFontAttributes).size.height
        let nameLabelTextRect: NSRect = NSRect(
            x: nameLabelInset.minX,
            y: nameLabelInset.minY + (nameLabelInset.height - nameLabelTextHeight) / 2,
            width: nameLabelInset.width,
            height: nameLabelTextHeight)
        NSGraphicsContext.saveGraphicsState()
        NSRectClip(nameLabelInset)
        NSString(string: propertyName).draw(in: nameLabelTextRect.offsetBy(dx: 0, dy: 0),
                                            withAttributes: nameLabelFontAttributes)
        NSGraphicsContext.restoreGraphicsState()

        //// valueLabel Drawing
        let valueLabelRect = NSRect(x: 0, y: 0, width: width, height: height)
        let valueLabelStyle = NSMutableParagraphStyle()
        valueLabelStyle.alignment = .right

        let valueLabelFontAttributes = [NSFontAttributeName: NSFont(name: "HelveticaNeue", size: 24)!,
                                        NSForegroundColorAttributeName: NSColor.black,
                                        NSParagraphStyleAttributeName: valueLabelStyle]

        let valueLabelInset: CGRect = valueLabelRect.insetBy(dx: 10, dy: 0)
        let valueLabelTextHeight: CGFloat = NSString(string: currentValueText).boundingRect(
            with: NSSize(width: valueLabelInset.width, height: CGFloat.infinity),
            options: NSStringDrawingOptions.usesLineFragmentOrigin,
            attributes: valueLabelFontAttributes).size.height
        let valueLabelTextRect: NSRect = NSRect(
            x: valueLabelInset.minX,
            y: valueLabelInset.minY + (valueLabelInset.height - valueLabelTextHeight) / 2,
            width: valueLabelInset.width,
            height: valueLabelTextHeight)
        NSGraphicsContext.saveGraphicsState()
        NSRectClip(valueLabelInset)
        NSString(string: currentValueText).draw(in: valueLabelTextRect.offsetBy(dx: 0, dy: 0),
                                                withAttributes: valueLabelFontAttributes)
        NSGraphicsContext.restoreGraphicsState()
    }

}
