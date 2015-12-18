//
//  AKPlaygroundHelpers.swift
//  AudioKit For iOS
//
//  Created by Aurelius Prochazka on 12/9/15.
//  Copyright © 2015 AudioKit. All rights reserved.
//

import Foundation

#if os(iOS)
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
    
#else
    
    public class AKPlaygroundLoop {
        // each instance has it's own handler
        private var handler: (timer: NSTimer) -> () = { (timer: NSTimer) in }
        
        public class func start(every duration: NSTimeInterval, handler:(timer: NSTimer)->()) {
            let t = AKPlaygroundLoop()
            t.handler = handler
            NSTimer.scheduledTimerWithTimeInterval(duration, target: t, selector: "processHandler:", userInfo: nil, repeats: true)
        }
        
        @objc private func processHandler(timer: NSTimer) {
            self.handler(timer: timer)
        }
    }
    
#endif