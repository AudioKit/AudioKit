//
//  AKPlaygroundView.swift
//  AudioKit for iOS
//
//  Created by Aurelius Prochazka on 7/30/16.
//  Copyright © 2016 AudioKit. All rights reserved.
//

import UIKit
public typealias Label = UILabel

public class AKPlaygroundView: UIView {
    
    public var elementHeight: CGFloat = 30
    public var yPosition: Int = 25
    public var spacing = 25
    
    public override init(frame frameRect: CGRect) {
        super.init(frame: frameRect)
        self.backgroundColor = UIColor.whiteColor()
        setup()
    }
    
    public convenience init() {
        self.init(frame: CGRect(x: 0, y: 0, width: 500, height: 1000))
    }
    
    public func setup() {}
    
    public func addTitle(text: String) -> UILabel {
        let newLabel = UILabel(frame: CGRect(x: 0, y: 0, width: self.bounds.width - 60, height: elementHeight))
        newLabel.text = text
        newLabel.textAlignment = .Center
        newLabel.font = UIFont.boldSystemFontOfSize(24)
        self.addSubview(newLabel)
        
        return newLabel
    }
    
    public func addLabel(text: String) -> UILabel {
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
        super.addSubview(view)
        yPosition += Int(view.frame.height) + spacing
        
        frame = CGRect(x: frame.origin.x, y: frame.origin.y, width: frame.size.width, height: CGFloat(yPosition))
    }
    
    
    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    // TO BE DEPRECATED:
    
    public func addButton(label: String, action: Selector) {
        
        let newButton = UIButton(type: .Custom)
        newButton.frame = CGRect(x: 10, y: 0, width: self.bounds.width, height: elementHeight)
        newButton.setTitleColor(UIColor.whiteColor(), forState: .Normal)
        newButton.backgroundColor = UIColor.blueColor()
        newButton.setTitle(" \(label) ", forState: .Normal)
        newButton.setNeedsDisplay()
        
        newButton.addTarget(self, action: action, forControlEvents: .TouchDown)
        newButton.sizeToFit()
        self.addSubview(newButton)        
    }
}