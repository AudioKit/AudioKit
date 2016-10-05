//
//  AKPlaygroundLoop.swift
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright (c) 2015 Aurelius Prochazka. All rights reserved.
//

import Foundation
import QuartzCore
public typealias Closure = () -> ()

/// Class to handle updating via CADisplayLink
open class AKPlaygroundLoop {
    fileprivate var internalHandler: Closure = {}
    fileprivate var trigger = 60
    fileprivate var counter = 0

    /// Repeat this loop at a given period with a code block
    ///
    /// - parameter every: Period, or interval between block executions
    /// - parameter handler: Code block to execute
    ///
    public init(every duration: Double, handler: @escaping Closure) {
        trigger =  Int(60 * duration)
        internalHandler = handler
        let displayLink = CADisplayLink(target: self, selector: #selector(update))
        if #available(iOS 10.0, *) {
            displayLink.preferredFramesPerSecond = 1
        }
        displayLink.add(to: RunLoop.current, forMode: RunLoopMode.commonModes)
    }

    /// Repeat this loop at a given frequency with a code block
    ///
    /// - parameter frequency: Frequency of block executions in Hz
    /// - parameter handler: Code block to execute
    ///
    public init(frequency: Double, handler: @escaping Closure) {
        trigger =  Int(60 / frequency)
        internalHandler = handler
        let displayLink = CADisplayLink(target: self, selector: #selector(update))
        if #available(iOS 10.0, *) {
            displayLink.preferredFramesPerSecond = 1
        }
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
