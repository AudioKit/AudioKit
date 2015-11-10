//
//  AKAUPeakLimiterWindow.swift
//  AudioKit
//
//  Created by Aurelius Prochazka on 11/8/15.
//  Copyright © 2015 AudioKit. All rights reserved.
//

#if os(OSX)
    import Foundation
    import Cocoa
    
    public class AKPeakLimiterWindow: NSWindow {
        
        let windowWidth = 400
        let padding = 30
        let sliderHeight = 20
        let numberOfComponents = 3
        
        public let attackTimeSlider: NSSlider
        public let decayTimeSlider:  NSSlider
        public let preGainSlider:    NSSlider
        
        let attackTimeTextField: NSTextField
        let decayTimeTextField:  NSTextField
        let preGainTextField:    NSTextField
        
        var peakLimiter: AKAUPeakLimiter
        
        public init(_ control: AKAUPeakLimiter) {
            peakLimiter = control
            let sliderWidth = windowWidth - 2 * padding
            
            attackTimeSlider = NSSlider(frame: NSRect(x: padding, y: 0, width: sliderWidth, height: sliderHeight))
            decayTimeSlider  = NSSlider(frame: NSRect(x: padding, y: 0, width: sliderWidth, height: sliderHeight))
            preGainSlider    = NSSlider(frame: NSRect(x: padding, y: 0, width: sliderWidth, height: sliderHeight))

            attackTimeTextField = NSTextField(frame: NSRect(x: padding, y: 0, width: sliderWidth, height: sliderHeight))
            decayTimeTextField  = NSTextField(frame: NSRect(x: padding, y: 0, width: sliderWidth, height: sliderHeight))
            preGainTextField    = NSTextField(frame: NSRect(x: padding, y: 0, width: sliderWidth, height: sliderHeight))

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
            self.title = "AKAUPeakLimiter"
            
            let viewRect = NSRect(x: 0, y: 0, width: windowWidth, height: windowHeight)
            let view = NSView(frame: viewRect)
            
            let topTitle = NSTextField()
            topTitle.stringValue = "AKAUPeakLimiter"
            topTitle.editable = false
            topTitle.drawsBackground = false
            topTitle.bezeled = false
            topTitle.alignment = NSCenterTextAlignment
            topTitle.font = NSFont(name: "Lucida Grande", size: 24)
            topTitle.sizeToFit()
            topTitle.frame.origin.x = CGFloat(windowWidth / 2) - topTitle.frame.width / 2
            topTitle.frame.origin.y = CGFloat(windowHeight - padding) - topTitle.frame.height
            view.addSubview(topTitle)
            
            
            attackTimeTextField.stringValue = "PeakLimiter attackTime: \(peakLimiter.attackTime) seconds"
            attackTimeTextField.editable = false
            attackTimeTextField.drawsBackground = false
            attackTimeTextField.bezeled = false
            attackTimeTextField.frame.origin.y = topTitle.frame.origin.y -  2 * CGFloat(sliderHeight)
            view.addSubview(attackTimeTextField)
            
            attackTimeSlider.target = self
            attackTimeSlider.action = "updateAttackTime"
            attackTimeSlider.minValue = 0
            attackTimeSlider.maxValue = 0.03
            attackTimeSlider.floatValue = Float(peakLimiter.attackTime)
            attackTimeSlider.frame.origin.y = attackTimeTextField.frame.origin.y - CGFloat(sliderHeight)
            view.addSubview(attackTimeSlider)
            
            decayTimeTextField.stringValue = "decayTime: \(peakLimiter.decayTime) seconds"
            decayTimeTextField.editable = false
            decayTimeTextField.drawsBackground = false
            decayTimeTextField.bezeled = false
            decayTimeTextField.frame.origin.y = attackTimeSlider.frame.origin.y - 2 * CGFloat(sliderHeight)
            view.addSubview(decayTimeTextField)
            
            decayTimeSlider.target = self
            decayTimeSlider.action = "updateDecayTime"
            decayTimeSlider.minValue = 0
            decayTimeSlider.maxValue = 0.06
            decayTimeSlider.floatValue = peakLimiter.decayTime
            decayTimeSlider.frame.origin.y = decayTimeTextField.frame.origin.y - CGFloat(sliderHeight)
            view.addSubview(decayTimeSlider)
            
            preGainTextField.stringValue = "Pre-Gain: \(peakLimiter.preGain) dB"
            preGainTextField.editable = false
            preGainTextField.drawsBackground = false
            preGainTextField.bezeled = false
            preGainTextField.frame.origin.y = decayTimeSlider.frame.origin.y - 2 * CGFloat(sliderHeight)
            view.addSubview(preGainTextField)
            
            preGainSlider.target = self
            preGainSlider.action = "updatePreGain"
            preGainSlider.minValue = -40
            preGainSlider.maxValue = 40
            preGainSlider.floatValue = peakLimiter.preGain
            preGainSlider.frame.origin.y = preGainTextField.frame.origin.y - CGFloat(sliderHeight)
            view.addSubview(preGainSlider)
            
            self.contentView!.addSubview(view)
            self.makeKeyAndOrderFront(nil)
        }
        
        internal func updateAttackTime() {
            peakLimiter.attackTime = attackTimeSlider.floatValue
            attackTimeTextField.stringValue = "Attack Time: \(String(format: "%0.4f", peakLimiter.attackTime)) seconds"
        }
        
        internal func updateDecayTime() {
            peakLimiter.decayTime = decayTimeSlider.floatValue
            decayTimeTextField.stringValue = "Decay Time: \(String(format: "%0.4f", peakLimiter.decayTime)) seconds"
        }
        
        internal func updatePreGain() {
            peakLimiter.preGain = preGainSlider.floatValue
            preGainTextField.stringValue = "PreGain: \(String(format: "%0.1f", peakLimiter.preGain))dB"
        }
        
        required public init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
    }
    
#endif
