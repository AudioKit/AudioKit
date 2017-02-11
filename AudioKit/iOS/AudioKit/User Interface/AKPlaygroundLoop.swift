//
//  AKPlaygroundLoop.swift
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright © 2017 Aurelius Prochazka. All rights reserved.
//

import Foundation

/// Class to handle updating via CADisplayLink
public class AKPlaygroundLoop: NSObject {
    private var internalHandler: () -> Void = {}
    private var duration = 1.0
    
    /// Repeat this loop at a given period with a code block
    ///
    /// - parameter every: Period, or interval between block executions
    /// - parameter handler: Code block to execute
    ///
    public init(every dur: Double, handler: @escaping () -> Void) {
        duration = dur
        internalHandler = handler
        super.init()
        update()
    }
    
    /// Repeat this loop at a given frequency with a code block
    ///
    /// - parameter frequency: Frequency of block executions in Hz
    /// - parameter handler: Code block to execute
    ///
    public init(frequency: Double, handler: @escaping () -> Void) {
        duration = 1.0 / frequency
        internalHandler = handler
        super.init()
        update()
    }
    
    /// Callback function
    @objc func update() {
        self.internalHandler()
        self.perform(#selector(update),
                     with: nil,
                     afterDelay: duration,
                     inModes: [RunLoopMode.commonModes])
        
    }
}
