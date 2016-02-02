//
//  AKPlaygroundView.swift
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright (c) 2016 Aurelius Prochazka. All rights reserved.
//

import Cocoa

public typealias Slider = NSSlider

public class AKPlaygroundView: NSView {
    
    public var elementHeight: CGFloat = 30
    public var positionIndex = 2
    public var horizontalSpacing = 40
    public var lastButton: NSButton?
    
    public override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        setup()
    }
    
    public func setup() {
    }
    
    func addLineBreak() {
        positionIndex += 1
        lastButton = nil
    }

    
    public func addTitle(text: String) -> NSTextField {
        let newLabel = NSTextField(frame: CGRectMake(0, 0, self.bounds.width, 2 * elementHeight))
        newLabel.stringValue = text
        newLabel.editable = false
        newLabel.drawsBackground = false
        newLabel.bezeled = false
        newLabel.alignment = NSCenterTextAlignment
        newLabel.frame.origin.y = self.bounds.height - CGFloat(2 * horizontalSpacing)
        newLabel.font = NSFont.boldSystemFontOfSize(24)
        self.addSubview(newLabel)
        positionIndex += 1
        return newLabel
    }
    
    public func addButton(label: String, action: Selector) -> NSButton {
        let newButton = NSButton(frame: CGRectMake(0, 0, self.bounds.width, elementHeight))
        newButton.title = "\(label)    "
        newButton.font = NSFont.systemFontOfSize(18)
        
        // Line up multiple buttons in a row
        if let button = lastButton {
            newButton.frame.origin.x += button.frame.origin.x + button.frame.width + 10
            positionIndex -= 1
        }
        
        newButton.frame.origin.y = self.bounds.height -  CGFloat(positionIndex * horizontalSpacing)
        newButton.sizeToFit()
        newButton.bezelStyle = NSBezelStyle.ShadowlessSquareBezelStyle
        newButton.target = self
        newButton.action = action
        self.addSubview(newButton)
        positionIndex += 1
        lastButton = newButton
        return newButton
    }
    
    public func addLabel(text: String) -> NSTextField {
        lastButton = nil
        let newLabel = NSTextField(frame: CGRectMake(0, 0, self.bounds.width, elementHeight))
        newLabel.stringValue = text
        newLabel.editable = false
        newLabel.drawsBackground = false
        newLabel.bezeled = false
        newLabel.font = NSFont.systemFontOfSize(18)
        newLabel.frame.origin.y = self.bounds.height -  CGFloat(positionIndex * horizontalSpacing)
        self.addSubview(newLabel)
        positionIndex += 1
        return newLabel
    }
    
    public func addSlider(action: Selector, value: Double = 0, minimum: Double = 0, maximum: Double = 1) -> NSSlider {
        lastButton = nil
        let newSlider = NSSlider(frame: CGRectMake(0, 0, self.bounds.width, 20))
        newSlider.frame.origin.y = self.bounds.height -  CGFloat(positionIndex * horizontalSpacing - 10)
        newSlider.minValue = Double(minimum)
        newSlider.maxValue = Double(maximum)
        newSlider.floatValue = Float(value)
        newSlider.setNeedsDisplay()
        newSlider.target = self
        newSlider.action = action
        self.addSubview(newSlider)
        positionIndex += 1
        return newSlider
    }
    
    
    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}