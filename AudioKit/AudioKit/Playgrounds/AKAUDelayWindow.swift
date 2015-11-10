//
//  AKAUDelayWindow.swift
//  AudioKit
//
//  Created by Aurelius Prochazka on 11/8/15.
//  Copyright © 2015 AudioKit. All rights reserved.
//

#if os(OSX)
import Foundation
import Cocoa

public class AKDelayWindow: NSWindow {
    
    let windowWidth = 400
    let padding = 30
    let sliderHeight = 20
    let numberOfComponents = 3
    
    public let timeSlider:      NSSlider
    public let feedbackSlider:  NSSlider
    public let dryWetMixSlider: NSSlider
    
    let timeTextField:      NSTextField
    let feedbackTextField:  NSTextField
    let dryWetMixTextField: NSTextField
    
    var delay: AKAUDelay
    
    public init(_ control: AKAUDelay) {
        delay = control
        let sliderWidth = windowWidth - 2 * padding
        timeSlider      = NSSlider(frame: NSRect(x: padding, y: 0, width: sliderWidth, height: sliderHeight))
        feedbackSlider  = NSSlider(frame: NSRect(x: padding, y: 0, width: sliderWidth, height: sliderHeight))
        dryWetMixSlider = NSSlider(frame: NSRect(x: padding, y: 0, width: sliderWidth, height: sliderHeight))
     
        timeTextField      = NSTextField(frame: NSRect(x: padding, y: 0, width: sliderWidth, height: sliderHeight))
        feedbackTextField  = NSTextField(frame: NSRect(x: padding, y: 0, width: sliderWidth, height: sliderHeight))
        dryWetMixTextField = NSTextField(frame: NSRect(x: padding, y: 0, width: sliderWidth, height: sliderHeight))
        
        let titleHeightApproximation = 50
        let windowHeight = padding * 2 + titleHeightApproximation + numberOfComponents * 3 * sliderHeight
        
        super.init(contentRect: NSRect(x: padding, y: padding, width: windowWidth, height: windowHeight),
            styleMask: NSTitledWindowMask,
            backing: .Buffered,
            `defer`: false)
        self.hasShadow = true
        self.styleMask = NSBorderlessWindowMask | NSResizableWindowMask
        self.movableByWindowBackground = true
        self.level = 7
        self.title = "AKAUDelay"
        
        let viewRect = NSRect(x: 0, y: 0, width: windowWidth, height: windowHeight)
        let view = NSView(frame: viewRect)
        
        let topTitle = NSTextField()
        topTitle.stringValue = "AKAUDelay"
        topTitle.editable = false
        topTitle.drawsBackground = false
        topTitle.bezeled = false
        topTitle.alignment = NSCenterTextAlignment
        topTitle.font = NSFont(name: "Lucida Grande", size: 24)
        topTitle.sizeToFit()
        topTitle.frame.origin.x = CGFloat(windowWidth / 2) - topTitle.frame.width / 2
        topTitle.frame.origin.y = CGFloat(windowHeight - padding) - topTitle.frame.height
        view.addSubview(topTitle)
        

        timeTextField.stringValue = "Delay Time: \(delay.time) seconds"
        timeTextField.editable = false
        timeTextField.drawsBackground = false
        timeTextField.bezeled = false
        timeTextField.frame.origin.y = topTitle.frame.origin.y -  2 * CGFloat(sliderHeight)
        view.addSubview(timeTextField)
        
        timeSlider.target = self
        timeSlider.action = "updateTime"
        timeSlider.minValue = 0
        timeSlider.maxValue = 1
        timeSlider.floatValue = Float(delay.time)
        timeSlider.frame.origin.y = timeTextField.frame.origin.y - CGFloat(sliderHeight)
        view.addSubview(timeSlider)
        
        feedbackTextField.stringValue = "Feedback: \(delay.feedback)%"
        feedbackTextField.editable = false
        feedbackTextField.drawsBackground = false
        feedbackTextField.bezeled = false
        feedbackTextField.frame.origin.y = timeSlider.frame.origin.y - 2 * CGFloat(sliderHeight)
       view.addSubview(feedbackTextField)
        
        feedbackSlider.target = self
        feedbackSlider.action = "updateFeedback"
        feedbackSlider.minValue = 0
        feedbackSlider.maxValue = 100
        feedbackSlider.floatValue = delay.feedback
        feedbackSlider.frame.origin.y = feedbackTextField.frame.origin.y - CGFloat(sliderHeight)
        view.addSubview(feedbackSlider)
        
        dryWetMixTextField.stringValue = "Dry/Wet Mix: \(delay.dryWetMix)%"
        dryWetMixTextField.editable = false
        dryWetMixTextField.drawsBackground = false
        dryWetMixTextField.bezeled = false
        dryWetMixTextField.frame.origin.y = feedbackSlider.frame.origin.y - 2 * CGFloat(sliderHeight)
        view.addSubview(dryWetMixTextField)
        
        dryWetMixSlider.target = self
        dryWetMixSlider.action = "updateDryWetMix"
        dryWetMixSlider.minValue = 0
        dryWetMixSlider.maxValue = 100
        dryWetMixSlider.floatValue = delay.dryWetMix
        dryWetMixSlider.frame.origin.y = dryWetMixTextField.frame.origin.y - CGFloat(sliderHeight)
        view.addSubview(dryWetMixSlider)
        
        self.contentView!.addSubview(view)
        self.makeKeyAndOrderFront(nil)
    }
    
    internal func updateTime() {
        delay.time = Double(timeSlider.floatValue)
        timeTextField.stringValue = "Delay Time: \(String(format: "%0.4f", delay.time)) seconds"
    }
    
    internal func updateFeedback() {
        delay.feedback = feedbackSlider.floatValue
        feedbackTextField.stringValue = "Feedback: \(String(format: "%0.1f", delay.feedback))%"
    }
    
    internal func updateDryWetMix() {
        delay.dryWetMix = dryWetMixSlider.floatValue
        dryWetMixTextField.stringValue = "Dry/Wet Mix: \(String(format: "%0.1f", delay.dryWetMix))%"
    }
    
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

#endif
