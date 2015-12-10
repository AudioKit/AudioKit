//
//  AKPlaygroundHelpers.swift
//  AudioKit For iOS
//
//  Created by Aurelius Prochazka on 12/9/15.
//  Copyright © 2015 AudioKit. All rights reserved.
//

import Foundation


public class Timer {
    // each instance has it's own handler
    private var handler: (timer: NSTimer) -> () = { (timer: NSTimer) in }
    
    public class func start(duration: NSTimeInterval, repeats: Bool, handler:(timer: NSTimer)->()) {
        let t = Timer()
        t.handler = handler
        NSTimer.scheduledTimerWithTimeInterval(duration, target: t, selector: "processHandler:", userInfo: nil, repeats: repeats)
    }
    
    @objc private func processHandler(timer: NSTimer) {
        self.handler(timer: timer)
    }
}
