//
//  TouchView.swift
//  AudioKitDemo
//
//  Created by Nicholas Arner on 3/13/15.
//  Copyright (c) 2015 AudioKit. All rights reserved.
//


class TouchView: NSView {
    
    override func drawRect(dirtyRect: NSRect) {
        NSColor(calibratedRed: 0.090, green: 0.671, blue: 0.094, alpha: 1.000).setFill()
        NSRectFill(dirtyRect)
        super.drawRect(dirtyRect)
    }
}