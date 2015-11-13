//
//  AKAudioPlayerWindow.swift
//  AudioKit
//
//  Created by Aurelius Prochazka on 11/9/15.
//  Copyright © 2015 AudioKit. All rights reserved.
//

#if os(OSX)
import Foundation
import Cocoa

public class AKAudioPlayerWindow: NSWindow {
    
    let windowWidth = 200
    let padding = 30
    let sliderHeight = 20
    let numberOfComponents = 1
    
    public let playButton: NSButton
    public let stopButton: NSButton

    var player: AKAudioPlayer
    
    public init(_ control: AKAudioPlayer) {
        player = control
        let sliderWidth = windowWidth - 2 * padding
        playButton      = NSButton(frame: NSRect(x: padding, y: 0, width: sliderWidth, height: sliderHeight))
        
        stopButton      = NSButton(frame: NSRect(x: padding, y: 0, width: sliderWidth, height: sliderHeight))
        
        
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
        self.title = "AKAudioPlayer"
        
        let viewRect = NSRect(x: 0, y: 0, width: windowWidth, height: windowHeight)
        let view = NSView(frame: viewRect)
        
        let topTitle = NSTextField()
        topTitle.stringValue = "AKAudioPlayer"
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
        
        stopButton.target = self
        stopButton.action = "stop"
        stopButton.title = "Stop"
        stopButton.frame.origin.y = playButton.frame.origin.y - 2 * CGFloat(sliderHeight)
        view.addSubview(stopButton)

        
        self.contentView!.addSubview(view)
        self.makeKeyAndOrderFront(nil)
    }
    
    internal func play() {
        player.play()
    }
    
    internal func stop() {
        player.stop()
    }
    
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

#endif
