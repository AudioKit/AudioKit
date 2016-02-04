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
    public var positionIndex = 1
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
        positionIndex += 1
        lastButton = nil
    }
    
    
    public func addTitle(text: String) -> UILabel {
        let newLabel = UILabel(frame: CGRectMake(0, 0, self.bounds.width, 2 * elementHeight))
        newLabel.text = text
        newLabel.textAlignment = .Center
        newLabel.frame.origin.y = 0
        newLabel.font = UIFont.boldSystemFontOfSize(24)
        self.addSubview(newLabel)
        positionIndex += 1
        return newLabel
    }
    
    public func addButton(label: String, action: Selector) -> UIButton {
        
        let newButton = UIButton(type: .Custom)
        newButton.frame = CGRectMake(0, 0, self.bounds.width, elementHeight)
        newButton.setTitleColor(UIColor.whiteColor(), forState: .Normal)
        newButton.backgroundColor = UIColor.blueColor()
        newButton.setTitle("  \(label)  ", forState: .Normal)
        newButton.setNeedsDisplay()
        // Line up multiple buttons in a row
        if let button = lastButton {
            newButton.frame.origin.x += button.frame.origin.x + button.frame.width + 10
            positionIndex -= 1
        }
        
        newButton.frame.origin.y = CGFloat(positionIndex * horizontalSpacing)
        newButton.addTarget(self, action: action, forControlEvents: .TouchDown)
        newButton.sizeToFit()
        self.addSubview(newButton)
        positionIndex += 1
        lastButton = newButton
        return newButton
    }
    
    public func addLabel(text: String) -> UILabel {
        lastButton = nil
        let newLabel = UILabel(frame: CGRectMake(0, 0, self.bounds.width, elementHeight))
        newLabel.text = text
        newLabel.font = UIFont.systemFontOfSize(18)
        newLabel.frame.origin.y = CGFloat(positionIndex * horizontalSpacing)
        self.addSubview(newLabel)
        positionIndex += 1
        return newLabel
    }
    
    public func addSlider(action: Selector, value: Double = 0, minimum: Double = 0, maximum: Double = 1) -> UISlider {
        lastButton = nil
        let newSlider = UISlider(frame: CGRectMake(0, 0, self.bounds.width, 20))
        newSlider.frame.origin.y = CGFloat(positionIndex * horizontalSpacing - 10)
        newSlider.minimumValue = Float(minimum)
        newSlider.maximumValue = Float(maximum)
        newSlider.value = Float(value)
        newSlider.setNeedsDisplay()
        newSlider.addTarget(self, action: action, forControlEvents: .ValueChanged)
        self.addSubview(newSlider)
        positionIndex += 1
        return newSlider
    }
    
    
    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}