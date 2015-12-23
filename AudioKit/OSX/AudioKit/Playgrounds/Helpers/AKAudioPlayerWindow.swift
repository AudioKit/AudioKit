//
//  AKAudioPlayerWindow.swift
//  AudioKit
//
//  Created by Aurelius Prochazka on 11/9/15.
//  Copyright © 2015 AudioKit. All rights reserved.
//

import Foundation
import Cocoa

/// A Window to control AKAudioPlayer in Playgrounds
public class AKAudioPlayerWindow: NSWindow {
    
    private let windowWidth = 200
    private let padding = 30
    private let sliderHeight = 20
    private let numberOfComponents = 3
    
    private let playButton: NSButton
    private let pauseButton: NSButton
    private let stopButton: NSButton
    public let volumeSlider: NSSlider
    public let panSlider: NSSlider
    
    private let volumeTextField: NSTextField
    private let panTextField: NSTextField
    
    private var player: AKAudioPlayer
    
    /// Initialize the AKAudioplayer window
    public init(_ control: AKAudioPlayer, title: String = "AKAudioPlayer", xOffset: Int = 420) {
        player = control
        let sliderWidth = windowWidth - 2 * padding
        playButton  = NSButton(frame: NSRect(x: padding, y: 0, width: sliderWidth, height: sliderHeight))
        pauseButton = NSButton(frame: NSRect(x: padding, y: 0, width: sliderWidth, height: sliderHeight))
        stopButton  = NSButton(frame: NSRect(x: padding, y: 0, width: sliderWidth, height: sliderHeight))
        volumeSlider = newSlider(sliderWidth)
        panSlider    = newSlider(sliderWidth)
        volumeTextField = newTextField(sliderWidth)
        panTextField    = newTextField(sliderWidth)
        
        let titleHeightApproximation = 50
        let windowHeight = padding * 2 + titleHeightApproximation + numberOfComponents * 3 * sliderHeight
        
        super.init(contentRect: NSRect(x: padding + xOffset, y: padding, width: windowWidth, height: windowHeight),
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
        
        playButton.target = self
        playButton.action = "play"
        playButton.title = "Play"
        playButton.frame.origin.y = topTitle.frame.origin.y - 2 * CGFloat(sliderHeight)
        view.addSubview(playButton)
        
        pauseButton.target = self
        pauseButton.action = "pause"
        pauseButton.title = "Pause"
        pauseButton.frame.origin.y = playButton.frame.origin.y - 2 * CGFloat(sliderHeight)
        view.addSubview(pauseButton)
        
        stopButton.target = self
        stopButton.action = "stop"
        stopButton.title = "Stop"
        stopButton.frame.origin.y = pauseButton.frame.origin.y - 2 * CGFloat(sliderHeight)
        view.addSubview(stopButton)
        
        makeTextField(volumeTextField, view: view, below: topTitle, distance: 8,
            stringValue: "Volume: \(player.volume)")
        makeSlider(volumeSlider, view: view, below: topTitle, distance: 9, target: self,
            action: "updateVolume",
            currentValue: player.volume,
            minimumValue: 0,
            maximumValue: 2)
        
        makeTextField(panTextField, view: view, below: topTitle, distance: 10,
            stringValue: "Pan: \(player.pan)")
        makeSlider(panSlider, view: view, below: topTitle, distance: 11, target: self,
            action: "updatePan",
            currentValue: player.pan,
            minimumValue: -1,
            maximumValue: 1)
        
        
        self.contentView!.addSubview(view)
        self.makeKeyAndOrderFront(nil)
    }
    
    internal func play() {
        player.play()
    }
    
    internal func pause() {
        player.pause()
    }
    
    internal func stop() {
        player.stop()
    }
    
    internal func updateVolume() {
        player.volume = volumeSlider.doubleValue
        volumeTextField.stringValue =
        "Volume \(String(format: "%0.4f", player.volume)) "
    }
    
    internal func updatePan() {
        player.pan = panSlider.doubleValue
        panTextField.stringValue =
        "Pan \(String(format: "%0.4f", player.pan)) "
    }
    
    /// Required Initializer
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

