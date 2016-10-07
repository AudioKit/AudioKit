//
//  Loop.swift
//  AudioKitParticles
//
//  Created by Aurelius Prochazka on 2/9/16.
//  Copyright © 2016 Simon Gladman. All rights reserved.
//

import QuartzCore

/// Class to handle updating via CADisplayLink
open class Loop {
    fileprivate var internalHandler: () -> () = {}
    fileprivate var trigger = 60
    fileprivate var counter = 0
    
    /// Repeat this loop at a given period with a code block
    ///
    /// - parameter every: Period, or interval between block executions
    /// - parameter handle: Code block to execute
    ///
    public init(every duration: Double, handler:@escaping ()->()) {
        trigger =  Int(60 * duration)
        internalHandler = handler
        let displayLink = CADisplayLink(target: self, selector: #selector(update))
        displayLink.preferredFramesPerSecond = 60
        displayLink.add(to: RunLoop.current, forMode: RunLoopMode.commonModes)
    }
    
    /// Repeat this loop at a given frequency with a code block
    ///
    /// - parameter frequency: Frequency of block executions in Hz
    /// - parameter handle: Code block to execute
    ///
    public init(frequency: Double, handler:@escaping ()->()) {
        trigger =  Int(60 / frequency)
        internalHandler = handler
        let displayLink = CADisplayLink(target: self, selector: #selector(update))
        displayLink.preferredFramesPerSecond = 60
        displayLink.add(to: RunLoop.current, forMode: RunLoopMode.commonModes)
    }
    
    /// Callback function for CADisplayLink
    @objc func update() {
        if counter < trigger {
            counter += 1
            return
        }
        counter = 0
        self.internalHandler()
    }
}
