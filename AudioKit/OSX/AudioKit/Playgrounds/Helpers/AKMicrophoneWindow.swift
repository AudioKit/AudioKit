//
//  AKMicrophoneWindow.swift
//  AudioKit For OSX
//
//  Created by Aurelius Prochazka on 12/14/15.
//  Copyright © 2015 AudioKit. All rights reserved.
//

import Foundation

import Cocoa

/// A Window to control AKMicrophone in Playgrounds
public class AKMicrophoneWindow: NSWindow {
    
    private let windowWidth = 200
    private let padding = 30
    private let sliderHeight = 20
    private let numberOfComponents = 1
    
    public let volumeSlider: NSSlider
    
    private let volumeTextField: NSTextField
    
    private var mic: AKMicrophone
    
    /// Initialize the AKMicrophone window
    public init(_ control: AKMicrophone, title: String = "AKMicrophone", xOffset: Int = 420) {
        mic = control
        let sliderWidth = windowWidth - 2 * padding
        volumeSlider = newSlider(sliderWidth)
        volumeTextField = newTextField(sliderWidth)
        
        let titleHeightApproximation = 50
        let windowHeight = padding * 2 + titleHeightApproximation + numberOfComponents * 3 * sliderHeight
        
        super.init(contentRect: NSRect(x: padding + xOffset, y: padding + 300, width: windowWidth, height: windowHeight),
            styleMask: NSTitledWindowMask,
            backing: .Buffered,
            `defer`: false)
        self.hasShadow = true
        self.styleMask = NSBorderlessWindowMask | NSResizableWindowMask
        self.movableByWindowBackground = true
        self.level = 7
        self.title = title
        
        let viewRect = NSRect(x: 0, y: 0, width: windowWidth, height: windowHeight)
        let view = NSView(frame: viewRect)
        
        let topTitle = NSTextField()
        topTitle.stringValue = title
        topTitle.editable = false
        topTitle.drawsBackground = false
        topTitle.bezeled = false
        topTitle.alignment = NSCenterTextAlignment
        topTitle.font = NSFont(name: "Lucida Grande", size: 24)
        topTitle.sizeToFit()
        topTitle.frame.origin.x = CGFloat(windowWidth / 2) - topTitle.frame.width / 2
        topTitle.frame.origin.y = CGFloat(windowHeight - padding) - topTitle.frame.height
        view.addSubview(topTitle)
        
        makeTextField(volumeTextField, view: view, below: topTitle, distance: 2,
            stringValue: "Volume: \(mic.volume)")
        makeSlider(volumeSlider, view: view, below: topTitle, distance: 3, target: self,
            action: "updateVolume",
            currentValue: mic.volume,
            minimumValue: 0,
            maximumValue: 1)
        
        self.contentView!.addSubview(view)
        self.makeKeyAndOrderFront(nil)
    }
    
    internal func updateVolume() {
        mic.volume = volumeSlider.doubleValue
        volumeTextField.stringValue =
        "Volume \(String(format: "%0.4f", mic.volume)) "
    }
    
    /// Required Initializer
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

