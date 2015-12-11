//
//  AKPlaygroundHelpers.swift
//  AudioKit For iOS
//
//  Created by Aurelius Prochazka on 12/9/15.
//  Copyright © 2015 AudioKit. All rights reserved.
//

import Foundation

public class AKPlaygroundLoop {
    
    private var internalHandler: () -> () = {}
    private var trigger = 60
    private var counter = 0
    public init(every: Double, handler:()->()) {
        trigger =  Int(60 * every)
        internalHandler = handler
        let displayLink = CADisplayLink(target: self, selector: "update")
        displayLink.frameInterval = 1
        displayLink.addToRunLoop(NSRunLoop.currentRunLoop(), forMode: NSRunLoopCommonModes)
    }
    public init(frequency: Double, handler:()->()) {
        trigger =  Int(60 / frequency)
        internalHandler = handler
        let displayLink = CADisplayLink(target: self, selector: "update")
        displayLink.frameInterval = 1
        displayLink.addToRunLoop(NSRunLoop.currentRunLoop(), forMode: NSRunLoopCommonModes)
    }
    @objc func update() {
        if counter < trigger {
            counter++
            return
        }
        counter = 0
        self.internalHandler()
    }
}

