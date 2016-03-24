//
//  AKPlaygroundView.swift
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright (c) 2015 Aurelius Prochazka. All rights reserved.
//

import UIKit

public typealias Slider = UISlider
public typealias Label  = UILabel

public class AKPlaygroundView: UIView {
    
    public var elementHeight: CGFloat = 30
    public var yPosition: Int = 0
    public var horizontalSpacing = 40
    public var lastButton: UIButton?
    
    public override init(frame frameRect: CGRect) {
        super.init(frame: frameRect)
        self.backgroundColor = UIColor.whiteColor()
        setup()
    }
    
    public func setup() {
    }
    
    public func addLineBreak() {
        lastButton = nil
    }
    
    
    public func addTitle(text: String) -> UILabel {
        let newLabel = UILabel(frame: CGRect(x: 0, y: 0, width: self.bounds.width, height: 2 * elementHeight))
        newLabel.text = text
        newLabel.textAlignment = .Center
        newLabel.frame.origin.y = 0
        newLabel.font = UIFont.boldSystemFontOfSize(24)
        self.addSubview(newLabel)
        yPosition += horizontalSpacing
        return newLabel
    }
    
    public func addButton(label: String, action: Selector) -> UIButton {
        
        let newButton = UIButton(type: .Custom)
        newButton.frame = CGRect(x: 0, y: 0, width: self.bounds.width, height: elementHeight)
        newButton.setTitleColor(UIColor.whiteColor(), forState: .Normal)
        newButton.backgroundColor = UIColor.blueColor()
        newButton.setTitle("  \(label)  ", forState: .Normal)
        newButton.setNeedsDisplay()
        // Line up multiple buttons in a row
        if let button = lastButton {
            newButton.frame.origin.x += button.frame.origin.x + button.frame.width + 10
            yPosition -= horizontalSpacing
        }
        
        newButton.frame.origin.y = CGFloat(yPosition)
        newButton.addTarget(self, action: action, forControlEvents: .TouchDown)
        newButton.sizeToFit()
        self.addSubview(newButton)
        yPosition += horizontalSpacing

        lastButton = newButton
        return newButton
    }
    
    public func addLabel(text: String) -> UILabel {
        lastButton = nil
        let newLabel = UILabel(frame: CGRect(x: 0, y: 0, width: self.bounds.width, height: elementHeight))
        newLabel.text = text
        newLabel.font = UIFont.systemFontOfSize(18)
        newLabel.frame.origin.y = CGFloat(yPosition)
        self.addSubview(newLabel)
        yPosition += horizontalSpacing

        return newLabel
    }
    
    public func addSlider(action: Selector, value: Double = 0, minimum: Double = 0, maximum: Double = 1) -> UISlider {
        lastButton = nil
        let newSlider = UISlider(frame: CGRect(x: 0, y: 0, width: self.bounds.width, height: 20))
        newSlider.frame.origin.y = CGFloat(yPosition)
        newSlider.minimumValue = Float(minimum)
        newSlider.maximumValue = Float(maximum)
        newSlider.value = Float(value)
        newSlider.setNeedsDisplay()
        newSlider.addTarget(self, action: action, forControlEvents: .ValueChanged)
        self.addSubview(newSlider)
        yPosition += horizontalSpacing

        return newSlider
    }
    
    
    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
