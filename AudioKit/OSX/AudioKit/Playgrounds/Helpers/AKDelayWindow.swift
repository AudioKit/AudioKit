//
//  AKDelayWindow.swift
//  AudioKit
//
//  Created by Aurelius Prochazka on 11/8/15.
//  Copyright © 2015 AudioKit. All rights reserved.
//

import Foundation
import Cocoa

/// A Window to control AKDelay in Playgrounds
public class AKDelayWindow: NSWindow {
    
    private let windowWidth = 400
    private let padding = 30
    private let sliderHeight = 20
    private let numberOfComponents = 4
    
    /// Slider to control time
    public let timeSlider: NSSlider
    /// Slider to control feedback
    public let feedbackSlider: NSSlider
    /// Slider to control low pass cutoff frequency
    public let lowPassCutoffSlider: NSSlider
    /// Slider to control dry/wet mix
    public let dryWetMixSlider: NSSlider
    
    private let timeTextField: NSTextField
    private let feedbackTextField: NSTextField
    private let lowPassCutoffTextField: NSTextField
    private let dryWetMixTextField: NSTextField
    
    private var delay: AKDelay
    
    /// Initiate the AKDelay window
    public init(_ control: AKDelay) {
        delay = control
        let sliderWidth = windowWidth - 2 * padding
        timeSlider          = NSSlider(frame: NSRect(x: padding, y: 0, width: sliderWidth, height: sliderHeight))
        feedbackSlider      = NSSlider(frame: NSRect(x: padding, y: 0, width: sliderWidth, height: sliderHeight))
        lowPassCutoffSlider = NSSlider(frame: NSRect(x: padding, y: 0, width: sliderWidth, height: sliderHeight))
        dryWetMixSlider     = NSSlider(frame: NSRect(x: padding, y: 0, width: sliderWidth, height: sliderHeight))
        
        timeTextField          = NSTextField(frame: NSRect(x: padding, y: 0, width: sliderWidth, height: sliderHeight))
        feedbackTextField      = NSTextField(frame: NSRect(x: padding, y: 0, width: sliderWidth, height: sliderHeight))
        lowPassCutoffTextField = NSTextField(frame: NSRect(x: padding, y: 0, width: sliderWidth, height: sliderHeight))
        dryWetMixTextField     = NSTextField(frame: NSRect(x: padding, y: 0, width: sliderWidth, height: sliderHeight))
        
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
        self.title = "AKDelay"
        
        let viewRect = NSRect(x: 0, y: 0, width: windowWidth, height: windowHeight)
        let view = NSView(frame: viewRect)
        
        let topTitle = NSTextField()
        topTitle.stringValue = "AKDelay"
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
        timeSlider.doubleValue = delay.time
        timeSlider.frame.origin.y = timeTextField.frame.origin.y - CGFloat(sliderHeight)
        view.addSubview(timeSlider)
        
        feedbackTextField.stringValue = "Feedback: \(delay.feedback)"
        feedbackTextField.editable = false
        feedbackTextField.drawsBackground = false
        feedbackTextField.bezeled = false
        feedbackTextField.frame.origin.y = timeSlider.frame.origin.y - 2 * CGFloat(sliderHeight)
        view.addSubview(feedbackTextField)
        
        feedbackSlider.target = self
        feedbackSlider.action = "updateFeedback"
        feedbackSlider.minValue = 0
        feedbackSlider.maxValue = 1
        feedbackSlider.doubleValue = delay.feedback
        feedbackSlider.frame.origin.y = feedbackTextField.frame.origin.y - CGFloat(sliderHeight)
        view.addSubview(feedbackSlider)
        
        lowPassCutoffTextField.stringValue = "Low Pass Cutoff: \(delay.lowPassCutoff) Hz"
        lowPassCutoffTextField.editable = false
        lowPassCutoffTextField.drawsBackground = false
        lowPassCutoffTextField.bezeled = false
        lowPassCutoffTextField.frame.origin.y = feedbackSlider.frame.origin.y - 2 * CGFloat(sliderHeight)
        view.addSubview(lowPassCutoffTextField)
        
        lowPassCutoffSlider.target = self
        lowPassCutoffSlider.action = "updateLowPassCutoff"
        lowPassCutoffSlider.minValue = 0
        lowPassCutoffSlider.maxValue = 20000
        lowPassCutoffSlider.doubleValue = delay.lowPassCutoff
        lowPassCutoffSlider.frame.origin.y = lowPassCutoffTextField.frame.origin.y - CGFloat(sliderHeight)
        view.addSubview(lowPassCutoffSlider)
        
        dryWetMixTextField.stringValue = "Dry/Wet Mix: \(delay.dryWetMix)"
        dryWetMixTextField.editable = false
        dryWetMixTextField.drawsBackground = false
        dryWetMixTextField.bezeled = false
        dryWetMixTextField.frame.origin.y = lowPassCutoffSlider.frame.origin.y - 2 * CGFloat(sliderHeight)
        view.addSubview(dryWetMixTextField)
        
        dryWetMixSlider.target = self
        dryWetMixSlider.action = "updateDryWetMix"
        dryWetMixSlider.minValue = 0
        dryWetMixSlider.maxValue = 1
        dryWetMixSlider.doubleValue = delay.dryWetMix
        dryWetMixSlider.frame.origin.y = dryWetMixTextField.frame.origin.y - CGFloat(sliderHeight)
        view.addSubview(dryWetMixSlider)
        
        self.contentView!.addSubview(view)
        self.makeKeyAndOrderFront(nil)
    }
    
    internal func updateTime() {
        delay.time = Double(timeSlider.doubleValue)
        timeTextField.stringValue = "Delay Time: \(String(format: "%0.4f", delay.time)) seconds"
    }
    
    internal func updateFeedback() {
        delay.feedback = feedbackSlider.doubleValue
        feedbackTextField.stringValue = "Feedback: \(String(format: "%0.3f", delay.feedback))"
    }
    
    internal func updateLowPassCutoff() {
        delay.lowPassCutoff = lowPassCutoffSlider.doubleValue
        lowPassCutoffTextField.stringValue = "Low Pass Cutoff: \(String(format: "%0.0f", delay.lowPassCutoff)) Hz"
    }
    
    internal func updateDryWetMix() {
        delay.dryWetMix = dryWetMixSlider.doubleValue
        dryWetMixTextField.stringValue = "Dry/Wet Mix: \(String(format: "%0.3f", delay.dryWetMix))"
    }
    
    /// Required Initializer
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

