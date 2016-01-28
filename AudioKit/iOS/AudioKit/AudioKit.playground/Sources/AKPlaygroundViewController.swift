//
//  AKPlaygroundViewController.swift
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright (c) 2015 Aurelius Prochazka. All rights reserved.
//

import UIKit

public class AKPlaygroundViewController: UIViewController {
    
    var positionIndex = 0
    public var elementHeight = CGFloat(30.0)
    public var horizontalSpacing = 40
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .whiteColor()
    }
    
    public func addTitle(text: String) -> UILabel {
        let newLabel = UILabel(frame: CGRectMake(0, 0, view.frame.width / 2.2, elementHeight))
        newLabel.text = text
        newLabel.center.x += 10
        newLabel.center.y += CGFloat(horizontalSpacing * positionIndex)
        newLabel.font =  UIFont.boldSystemFontOfSize(24)
        view.addSubview(newLabel)
        positionIndex += 1
        return newLabel
    }
    
    public func addSwitch(action: Selector) -> UISwitch {
        let newSwitch = UISwitch()
        newSwitch.addTarget(self, action: "toggle:", forControlEvents: .TouchUpInside)
        newSwitch.center.x += 10
        newSwitch.center.y += CGFloat(horizontalSpacing * positionIndex)
        view.addSubview(newSwitch)
        positionIndex += 1
        return newSwitch
    }
    
    public func addSlider(action: Selector, value: Double = 0, minimum: Double = 0, maximum: Double = 1) -> UISlider {
        let newSlider = UISlider(frame: CGRectMake(0, 0, view.frame.width / 2.2, elementHeight))
        newSlider.center.x += 10
        newSlider.center.y += CGFloat(horizontalSpacing * positionIndex)
        newSlider.minimumValue = Float(minimum)
        newSlider.maximumValue = Float(maximum)
        newSlider.value = Float(value)
        newSlider.setNeedsDisplay()
        newSlider.addTarget(self, action: action, forControlEvents: .ValueChanged)
        view.addSubview(newSlider)
        positionIndex += 1
        return newSlider
    }
    
    public func addLabel(text: String) -> UILabel {
        let newLabel = UILabel(frame: CGRectMake(0, 0, view.frame.width / 2.2, elementHeight))
        newLabel.text = text
        newLabel.center.x += 10
        newLabel.center.y += CGFloat(horizontalSpacing * positionIndex)
        view.addSubview(newLabel)
        positionIndex += 1
        return newLabel
    }
    
}