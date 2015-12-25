//
//  AKPlaygroundHelpers.swift
//  AudioKit For iOS
//
//  Created by Aurelius Prochazka on 12/9/15.
//  Copyright © 2015 AudioKit. All rights reserved.
//

import Foundation

#if os(iOS)
    
    /// Class to handle updating via CADisplayLink
    public class AKPlaygroundLoop {
        private var internalHandler: () -> () = {}
        private var trigger = 60
        private var counter = 0
        
        /** Repeat this loop at a given period with a code block
         
         - parameter every: Period, or interval between block executions
         - parameter handle: Code block to execute
         */
        public init(every duration: Double, handler:()->()) {
            trigger =  Int(60 * duration)
            internalHandler = handler
            let displayLink = CADisplayLink(target: self, selector: "update")
            displayLink.frameInterval = 1
            displayLink.addToRunLoop(NSRunLoop.currentRunLoop(), forMode: NSRunLoopCommonModes)
        }
        
        /** Repeat this loop at a given frequency with a code block
         
         - parameter frequency: Frequency of block executions in Hz
         - parameter handle: Code block to execute
         */
        public init(frequency: Double, handler:()->()) {
            trigger =  Int(60 / frequency)
            internalHandler = handler
            let displayLink = CADisplayLink(target: self, selector: "update")
            displayLink.frameInterval = 1
            displayLink.addToRunLoop(NSRunLoop.currentRunLoop(), forMode: NSRunLoopCommonModes)
        }
        
        /// Callback function for CADisplayLink
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
    
    /// Class to handle updating via NSTimer
    public class AKPlaygroundLoop {
        // each instance has it's own handler
        private var handler: (timer: NSTimer) -> () = { (timer: NSTimer) in }
        
        /** Repeat this loop at a given period with a code block
         
         - parameter every: Period, or interval between block executions
         - parameter handle: Code block to execute
         */
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