//
//  AKPlaygroundView.swift
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright (c) 2016 Aurelius Prochazka. All rights reserved.
//
import UIKit

public typealias Slider    = UISlider
public typealias Label     = UILabel
public typealias TextField = UITextField

public class AKPlaygroundView: UIView {
    
    public var elementHeight: CGFloat = 30
    public var yPosition: Int = 25
    public var spacing = 25
    public var lastButton: UIButton?
    
    public override init(frame frameRect: CGRect) {
        super.init(frame: frameRect)
        self.backgroundColor = UIColor.whiteColor()
        setup()
    }
    
    public convenience init(height: Int) {
        self.init(frame: CGRect(x: 0, y: 0, width: 500, height: height))
    }
    
    public func setup() {
    }
    
    public func addLineBreak() {
        lastButton = nil
    }
    
    
    public func addTitle(text: String) -> UILabel {
        let newLabel = UILabel(frame: CGRect(x: 0, y: 0, width: self.bounds.width - 60, height: elementHeight))
        newLabel.text = text
        newLabel.textAlignment = .Center
        newLabel.font = UIFont.boldSystemFontOfSize(24)
        self.addSubview(newLabel)
        
        return newLabel
    }
    
    public func addButton(label: String, action: Selector) -> UIButton {
        
        let newButton = UIButton(type: .Custom)
        newButton.frame = CGRect(x: 10, y: 0, width: self.bounds.width, height: elementHeight)
        newButton.setTitleColor(UIColor.whiteColor(), forState: .Normal)
        newButton.backgroundColor = UIColor.blueColor()
        newButton.setTitle(" \(label) ", forState: .Normal)
        newButton.setNeedsDisplay()
        // Line up multiple buttons in a row
        if let button = lastButton {
            newButton.frame.origin.x += button.frame.origin.x + button.frame.width + 10
            yPosition -= spacing + Int(button.frame.height)
        }
        
        newButton.addTarget(self, action: action, forControlEvents: .TouchDown)
        newButton.sizeToFit()
        self.addSubview(newButton)
        
        lastButton = newButton
        return newButton
    }
    
    public func addLabel(text: String) -> UILabel {
        lastButton = nil
        let newLabel = UILabel(frame:
            CGRect(x: 0, y: 0, width: self.bounds.width - 60, height: elementHeight))
        newLabel.text = text
        newLabel.font = UIFont.systemFontOfSize(18)
        self.addSubview(newLabel)
        
        return newLabel
    }
    
    public override func addSubview(view: UIView) {
        view.frame.origin.y = CGFloat(yPosition)
        if view.frame.origin.x < 30 {
            view.frame.origin.x = 30
        }
        print(yPosition)
        super.addSubview(view)
        yPosition += Int(view.frame.height) + spacing
    }
    
    
    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public static let audioResourceFileNames = [
        "Acid Full.mp3",
        "Acid Drums.mp3",
        "Acid Bass.mp3",
        "80s Synth.mp3",
        "Lo-Fi Synth.mp3",
        "African.mp3",
        "mixloop.wav",
        "counting.mp3"]

}
