//
//  AKPlaygroundView.swift
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright (c) 2016 Aurelius Prochazka. All rights reserved.
//

import Cocoa

public typealias Label  = AKLabel
public typealias Slider = AKSlider

public class AKLabel: NSTextField {
    
    override public init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
    }
    
    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    public var text: String = "" {
        didSet {
        stringValue = text
        }
    }
}


public class AKSlider: NSSlider {
    
    override public init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
    }
    
    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    public var value: Float {
        get {
            return floatValue
        }
        set {
            floatValue = value
        }
    }
}

public class AKPlaygroundView: NSView {
    
    public var elementHeight: CGFloat = 30
    public var yPosition: Int = 80
    public var horizontalSpacing = 40
    public var lastButton: NSButton?
    
    override public init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        setup()
    }
    
    public func setup() {
    }
    
    override public func drawRect(dirtyRect: NSRect) {
        NSColor.whiteColor().setFill()
        NSRectFill(dirtyRect)
        super.drawRect(dirtyRect)
    }
    
    public func addLineBreak() {
        lastButton = nil
    }
    
    
    public func addTitle(text: String) -> NSTextField {
        let newLabel = NSTextField(frame: CGRect(x: 0, y: 0, width: self.bounds.width, height: 2 * elementHeight))
        newLabel.stringValue = text
        newLabel.editable = false
        newLabel.drawsBackground = false
        newLabel.bezeled = false
        newLabel.alignment = NSCenterTextAlignment
        newLabel.frame.origin.y = self.bounds.height - CGFloat(2 * horizontalSpacing)
        newLabel.font = NSFont.boldSystemFontOfSize(24)
        self.addSubview(newLabel)
        yPosition += horizontalSpacing
        return newLabel
    }
    
    public func addButton(label: String, action: Selector) -> NSButton {
        let newButton = NSButton(frame: CGRect(x: 0, y: 0, width: self.bounds.width, height: elementHeight))
        newButton.title = "\(label)    "
        newButton.font = NSFont.systemFontOfSize(18)
        
        // Line up multiple buttons in a row
        if let button = lastButton {
            newButton.frame.origin.x += button.frame.origin.x + button.frame.width + 10
            yPosition -= horizontalSpacing
        }
        
        newButton.frame.origin.y = self.bounds.height -  CGFloat(yPosition)
        newButton.sizeToFit()
        newButton.bezelStyle = NSBezelStyle.ShadowlessSquareBezelStyle
        newButton.target = self
        newButton.action = action
        self.addSubview(newButton)
        yPosition += horizontalSpacing
        lastButton = newButton
        return newButton
    }
    
    public func addLabel(text: String) -> AKLabel {
        lastButton = nil
        let newLabel = AKLabel(frame: CGRect(x: 0, y: 0, width: self.bounds.width, height: elementHeight))
        newLabel.stringValue = text
        newLabel.editable = false
        newLabel.drawsBackground = false
        newLabel.bezeled = false
        newLabel.font = NSFont.systemFontOfSize(18)
        newLabel.frame.origin.y = self.bounds.height -  CGFloat(yPosition)
        self.addSubview(newLabel)
        yPosition += horizontalSpacing
        return newLabel
    }
    
    public func addSlider(action: Selector, value: Double = 0, minimum: Double = 0, maximum: Double = 1) -> AKSlider {
        lastButton = nil
        let newSlider = AKSlider(frame: CGRect(x: 0, y: 0, width: self.bounds.width, height: 20))
        newSlider.frame.origin.y = self.bounds.height -  CGFloat(yPosition)
        newSlider.minValue = Double(minimum)
        newSlider.maxValue = Double(maximum)
        newSlider.floatValue = Float(value)
        newSlider.setNeedsDisplay()
        newSlider.target = self
        newSlider.action = action
        self.addSubview(newSlider)
        yPosition += horizontalSpacing
        return newSlider
    }
    
    
    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
