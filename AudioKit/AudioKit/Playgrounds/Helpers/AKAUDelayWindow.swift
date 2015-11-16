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

/// A Window to control AKAUDelay in Playgrounds
public class AKAUDelayWindow: NSWindow {
    
    private let windowWidth = 400
    private let padding = 30
    private let sliderHeight = 20
    private let numberOfComponents = 4
    
    /// Slider to control time
    public let timeSlider:          NSSlider
    /// Slider to control feedback
    public let feedbackSlider:      NSSlider
    /// Slider to control low pass cutoff frequency
    public let lowPassCutoffSlider: NSSlider
    /// Slider to control dry/wet mix
    public let dryWetMixSlider:     NSSlider
    
    private let timeTextField:          NSTextField
    private let feedbackTextField:      NSTextField
    private let lowPassCutoffTextField: NSTextField
    private let dryWetMixTextField:     NSTextField
    
    private var delay: AKAUDelay
    
    /// Initiate the AKAUDelay window
    public init(_ control: AKAUDelay) {
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
        lowPassCutoffSlider.floatValue = delay.lowPassCutoff
        lowPassCutoffSlider.frame.origin.y = lowPassCutoffTextField.frame.origin.y - CGFloat(sliderHeight)
        view.addSubview(lowPassCutoffSlider)
        
        dryWetMixTextField.stringValue = "Dry/Wet Mix: \(delay.dryWetMix)%"
        dryWetMixTextField.editable = false
        dryWetMixTextField.drawsBackground = false
        dryWetMixTextField.bezeled = false
        dryWetMixTextField.frame.origin.y = lowPassCutoffSlider.frame.origin.y - 2 * CGFloat(sliderHeight)
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
    
    private func updateTime() {
        delay.time = Double(timeSlider.floatValue)
        timeTextField.stringValue = "Delay Time: \(String(format: "%0.4f", delay.time)) seconds"
    }
    
    private func updateFeedback() {
        delay.feedback = feedbackSlider.floatValue
        feedbackTextField.stringValue = "Feedback: \(String(format: "%0.1f", delay.feedback))%"
    }
    
    private func updateLowPassCutoff() {
        delay.lowPassCutoff = lowPassCutoffSlider.floatValue
        lowPassCutoffTextField.stringValue = "Low Pass Cutoff: \(String(format: "%0.0f", delay.lowPassCutoff)) Hz"
    }
    
    private func updateDryWetMix() {
        delay.dryWetMix = dryWetMixSlider.floatValue
        dryWetMixTextField.stringValue = "Dry/Wet Mix: \(String(format: "%0.1f", delay.dryWetMix))%"
    }
    
    /// Required Initializer
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

#endif
